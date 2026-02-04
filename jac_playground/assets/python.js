// ----------------------------------------------------------------------------
// Globals
// ----------------------------------------------------------------------------
var pyodide = null;
var breakpoints_buff = [];
var dbg = null;  // The debugger instance.

var sharedInts = null;
var continueExecution = false;

// Do not Remove or modify this path variable, it should be exactly as below for the deployment.
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
      logMessage(`Execution finished`);
      self.postMessage({ type: 'execEnd' });
      break;

    case 'convertCode':
      logMessage(`Starting ${data.conversionType} conversion...`);
      await convertCode(data.conversionType, data.inputCode);
      logMessage(`Conversion finished`);
      break;

    case 'executePython':
      logMessage("Starting Python execution...");
      await executePython(data.code);
      logMessage(`Python execution finished`);
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
  // const response = await fetch(fileName);
  return await response.text();
};

async function readFileAsBytes(fileName) {
  const response = await fetch(PLAYGROUND_PATH + fileName);
  // const response = await fetch(fileName);
  const buffer = await response.arrayBuffer();
  return new Uint8Array(buffer);
}


// ----------------------------------------------------------------------------
// Jaclang Initialization
// ----------------------------------------------------------------------------
async function loadPyodideAndJacLang() {
  try {
    // Install required packages via micropip
    await pyodide.loadPackage("sqlite3");
    await pyodide.loadPackage("micropip");
    await pyodide.runPythonAsync(`
import micropip
await micropip.install(['pluggy', 'jaclang==0.9.11'])
    `);
    const success = await checkJaclangLoaded(pyodide);
    // Run the debugger module.
    await pyodide.runPythonAsync(
      await readFileAsString("/static/assets/debugger.py")
    );
    return success;

  } catch (error) {
    console.error("Error loading JacLang:", error);
    return false;
  }
}

async function loadPythonResources(pyodide) {
  // No longer needed: JacLang is installed from PyPI
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

  logMessage(`before ui: line=$${line}`);
  self.postMessage({ type: 'breakHit', line: line });

  continueExecution = false;
  while (!continueExecution) {
    Atomics.wait(sharedInts, 0, 0); // Block until the UI responds.
    sharedInts[0] = 0;  // Reset the shared memory.

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

      case 3: // Continue execution
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

      case 7: // Terminate execution
        if (dbg) {
          try {
            // Set a timeout for termination to avoid hanging
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
            // Ensure cleanup
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
  console.log("*********Starting code execution.");

  // Clear the .jac/data folder before each execution
  // This prevents state from persisting between runs
  await pyodide.runPythonAsync(`
import os
import shutil

# Find and clear the .jac/data folder
def clear_jac_data():
    # Check common locations for .jac folder
    possible_paths = [
        '.jac/data',
        os.path.expanduser('~/.jac/data'),
        '/home/pyodide/.jac/data',
        '/.jac/data'
    ]

    for jac_data_path in possible_paths:
        if os.path.exists(jac_data_path) and os.path.isdir(jac_data_path):
            try:
                shutil.rmtree(jac_data_path)
            except Exception as e:
                pass

clear_jac_data()
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

  // Correctly instantiate the Debugger class from Pyodide
  let dbg = pyodide.globals.get('Debugger')();
  dbg.cb_break = callbackBreak;
  dbg.cb_graph = callbackGraph;
  pyodide.globals.set('debugger', dbg);

  dbg.clear_breakpoints();
  for (const bp of breakpoints_buff) {
    dbg.set_breakpoint(bp);
    logMessage(`Breakpoint set at line ${bp}`);
  }

  // Run the main script
  logMessage("Execution started.");
  try {
    await pyodide.runPythonAsync(
      await readFileAsString("/static/assets/main_playground.py")
    );
  } catch (error) {
    // Handle any remaining execution errors
    if (error.message && (
        error.message.includes("DebuggerTerminated") ||
        error.message.includes("terminated") ||
        error.message.includes("Not a directory") ||
        error.message.includes("No such file")
    )) {
      logMessage("Execution terminated by user.");
    } else {
      logMessage(`Execution error: ${error.message}`);
      throw error; // Re-throw if it's not a termination error
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

  // Run the conversion script
  logMessage("Conversion started.");
  try {
    await pyodide.runPythonAsync(
      await readFileAsString("/static/assets/main_conversion.py")
    );
  } catch (error) {
    logMessage(`Conversion error: ${error.message}`);
    // Send error result back to main thread
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

  // Run the Python execution script
  logMessage("Python execution started.");
  try {
    await pyodide.runPythonAsync(
      await readFileAsString("/static/assets/main_python_execution.py")
    );
  } catch (error) {
    logMessage(`Python execution error: ${error.message}`);
    // Send error to stderr callback
    callbackStderr(`Python execution error: ${error.message}`);
  }
  logMessage("Python execution finished.");
}
