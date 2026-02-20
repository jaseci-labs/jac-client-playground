// ----------------------------------------------------------------------------
// Globals
// ----------------------------------------------------------------------------
var pyodide = null;
var breakpoints_buff = [];
var dbg = null;

var sharedInts = null;
var continueExecution = false;

// Do not remove or modify this path variable, it should be exactly as below for deployment.
const PLAYGROUND_PATH = "";

const LOG_PATH = "/tmp/logs.log";


// ----------------------------------------------------------------------------
// Message passing protocol
// ----------------------------------------------------------------------------
onmessage = async (event) => {
  const data = event.data;
  switch (data.type) {

    case 'initialize':
      sharedInts = new Int32Array(data.sharedBuffer);
      importScripts("https://cdn.jsdelivr.net/pyodide/v0.28.0/full/pyodide.js");
      logMessage("Loading Pyodide...");
      pyodide = await loadPyodide();
      logMessage("Pyodide loaded.");
      const success = await loadPyodideAndJacLang();
      logMessage(`Pyodide and JacLang loaded: success=${success}`);
      self.postMessage({ type: 'initialized', success: success });
      break;

    case 'setBreakpoints':
      if (dbg) {
        dbg.clear_breakpoints();
        for (const bp of data.breakpoints) {
          dbg.set_breakpoint(bp);
          logMessage(`Breakpoint set at line ${bp}`);
        }
      } else {
        breakpoints_buff = data.breakpoints;
      }
      break;

    case 'startExecution':
      logMessage("Starting execution...");
      await startExecution(data.code);
      logMessage("Execution finished");
      self.postMessage({ type: 'execEnd' });
      break;

    case 'convertCode':
      logMessage(`Starting ${data.conversionType} conversion...`);
      await convertCode(data.conversionType, data.inputCode);
      logMessage("Conversion finished");
      break;

    case 'executePython':
      logMessage("Starting Python execution...");
      await executePython(data.code);
      logMessage("Python execution finished");
      self.postMessage({ type: 'execEnd' });
      break;

    default:
      console.error("Unknown message type:", data.type);
  }
};


// ----------------------------------------------------------------------------
// Utility functions
// ----------------------------------------------------------------------------
function logMessage(message) {
  console.log("[PythonThread] " + message);
}

async function readFileAsString(fileName) {
  const response = await fetch(PLAYGROUND_PATH + fileName);
  return await response.text();
}

async function readFileAsBytes(fileName) {
  const response = await fetch(PLAYGROUND_PATH + fileName);
  const buffer = await response.arrayBuffer();
  return new Uint8Array(buffer);
}


// ----------------------------------------------------------------------------
// JacLang Initialization
// ----------------------------------------------------------------------------
async function loadPyodideAndJacLang() {
  try {
    await pyodide.loadPackage("sqlite3");

    logMessage("Fetching jaclang.zip...");
    const zipBytes = await readFileAsBytes("/static/assets/jaclang.zip");

    logMessage("Extracting jaclang bundle...");
    pyodide.globals.set("_zip_bytes", zipBytes);
    await pyodide.runPythonAsync(`
import sys, zipfile, io

zip_data = _zip_bytes.to_py().tobytes()
with zipfile.ZipFile(io.BytesIO(zip_data)) as zf:
    zf.extractall('/tmp/jaclang_bundle')

sys.path.insert(0, '/tmp/jaclang_bundle')
sys.path.insert(0, '/tmp/jaclang_bundle/jaclang/vendor')
    `);
    pyodide.globals.delete("_zip_bytes");

    const success = await checkJaclangLoaded(pyodide);
    await pyodide.runPythonAsync(
      await readFileAsString("/static/assets/debugger.py")
    );
    return success;

  } catch (error) {
    console.error("Error loading JacLang:", error);
    return false;
  }
}

async function checkJaclangLoaded(pyodide) {
  try {
    await pyodide.runPythonAsync(`from jaclang.cli.commands import execution`);
    console.log("JacLang is available.");
    return true;
  } catch (error) {
    console.error("JacLang is not available:", error);
    return false;
  }
}


// ----------------------------------------------------------------------------
// Execution
// ----------------------------------------------------------------------------
function callbackBreak(dbg, line) {
  logMessage(`before ui: line=${line}`);
  self.postMessage({ type: 'breakHit', line: line });

  continueExecution = false;
  while (!continueExecution) {
    Atomics.wait(sharedInts, 0, 0);
    sharedInts[0] = 0;

    switch (sharedInts[1]) {
      case 1: // Clear breakpoints
        if (dbg) {
          dbg.clear_breakpoints();
          logMessage("Breakpoints cleared.");
        }
        break;

      case 2: // Set breakpoint
        const lineNumber = sharedInts[2];
        if (dbg) {
          dbg.set_breakpoint(lineNumber);
          logMessage(`Breakpoint set at line ${lineNumber}`);
        }
        break;

      case 3: // Continue
        dbg.do_continue();
        continueExecution = true;
        break;

      case 4: // Step over
        if (dbg) {
          dbg.do_step_over();
          logMessage("Stepped over.");
        }
        continueExecution = true;
        break;

      case 5: // Step into
        if (dbg) {
          dbg.do_step_into();
          logMessage("Stepped into.");
        }
        continueExecution = true;
        break;

      case 6: // Step out
        if (dbg) {
          dbg.do_step_out();
          logMessage("Stepped out.");
        }
        continueExecution = true;
        break;

      case 7: // Terminate
        if (dbg) {
          try {
            setTimeout(() => {
              if (dbg) {
                dbg = null;
                logMessage("Forced cleanup after timeout.");
              }
            }, 1000);
            dbg.do_terminate();
            logMessage("Execution stopped.");
          } catch (error) {
            logMessage("Execution terminated (cleanup warning ignored).");
          } finally {
            dbg = null;
          }
        }
        continueExecution = true;
        break;
    }
  }
  logMessage("after ui");
}

function callbackStdout(output) {
  self.postMessage({ type: 'stdout', output: output });
}

function callbackStderr(output) {
  self.postMessage({ type: 'stderr', output: output });
}

function callbackGraph(graph) {
  self.postMessage({ type: 'jacGraph', graph: graph });
}

async function startExecution(safeCode) {
  // Clear .jac/data folder to prevent state persisting between runs
  await pyodide.runPythonAsync(`
import os, shutil

for p in ['.jac/data', os.path.expanduser('~/.jac/data'), '/home/pyodide/.jac/data', '/.jac/data']:
    if os.path.isdir(p):
        shutil.rmtree(p, ignore_errors=True)
  `);

  safeCode += `
with entry {
    print("<==START PRINT GRAPH==>");
    graph_json = printgraph(format='json');
    print(graph_json);
    print("<==END PRINT GRAPH==>");
}
  `;

  pyodide.globals.set('SAFE_CODE', safeCode);
  pyodide.globals.set('CB_STDOUT', callbackStdout);
  pyodide.globals.set('CB_STDERR', callbackStderr);

  let dbg = pyodide.globals.get('Debugger')();
  dbg.cb_break = callbackBreak;
  dbg.cb_graph = callbackGraph;
  pyodide.globals.set('debugger', dbg);

  dbg.clear_breakpoints();
  for (const bp of breakpoints_buff) {
    dbg.set_breakpoint(bp);
    logMessage(`Breakpoint set at line ${bp}`);
  }

  logMessage("Execution started.");
  try {
    await pyodide.runPythonAsync(
      await readFileAsString("/static/assets/main_playground.py")
    );
  } catch (error) {
    if (error.message && (
        error.message.includes("DebuggerTerminated") ||
        error.message.includes("terminated") ||
        error.message.includes("Not a directory") ||
        error.message.includes("No such file")
    )) {
      logMessage("Execution terminated by user.");
    } else {
      logMessage(`Execution error: ${error.message}`);
      throw error;
    }
  }
  logMessage("Execution finished.");
  dbg = null;
}

async function convertCode(conversionType, inputCode) {
  pyodide.globals.set('CONVERSION_TYPE', conversionType);
  pyodide.globals.set('INPUT_CODE', inputCode);
  pyodide.globals.set('CB_STDOUT', callbackStdout);
  pyodide.globals.set('CB_STDERR', callbackStderr);
  pyodide.globals.set('CB_RESULT', callbackConversionResult);

  logMessage("Conversion started.");
  try {
    await pyodide.runPythonAsync(
      await readFileAsString("/static/assets/main_conversion.py")
    );
  } catch (error) {
    logMessage(`Conversion error: ${error.message}`);
    callbackConversionResult(`// Error during conversion:\n// ${error.message}`);
  }
  logMessage("Conversion finished.");
}

function callbackConversionResult(result) {
  self.postMessage({ type: 'conversionResult', result: result });
}

async function executePython(pythonCode) {
  pyodide.globals.set('PYTHON_CODE', pythonCode);
  pyodide.globals.set('CB_STDOUT', callbackStdout);
  pyodide.globals.set('CB_STDERR', callbackStderr);

  logMessage("Python execution started.");
  try {
    await pyodide.runPythonAsync(
      await readFileAsString("/static/assets/main_python_execution.py")
    );
  } catch (error) {
    logMessage(`Python execution error: ${error.message}`);
    callbackStderr(`Python execution error: ${error.message}`);
  }
  logMessage("Python execution finished.");
}
