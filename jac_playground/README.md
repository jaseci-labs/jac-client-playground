  # jac-playground

## Getting Started


Local setup (recommended)

1. Clone the repository:

```bash
git clone https://github.com/jaseci-labs/jac-client-playground.git
cd jac-client-playground
```

2. Create and activate a Python virtual environment (venv) or use conda:

venv example:

```bash
python3 -m venv jac-venv
source jac-venv/bin/activate
```

conda example:

```bash
conda create -n jac-playground python=3.12 -y
conda activate jac-playground
```

3. Install the required Python packages (specific versions):

```bash
pip install jac-client jaclang
```

4. Change into the playground folder and install web dependencies used by the client:

```bash
cd jac_playground
jac add --cl
```

5. Start the local playground server:

```bash
jac start
```

6. Open the app in your browser:

```
http://localhost:8000
```

Notes:
- If you use a different Python interpreter or environment manager, adjust the venv/conda commands accordingly.
- The `jac add --cl` step installs client-side dependencies for the playground UI.
- If the environment is initializing you may see a loading badge in the top bar — wait a few seconds and the UI will become Ready.

## TypeScript Support

Create TypeScript components in `src/components/` and import them in your Jac files:

```jac
cl import from "./components/Button.tsx" { Button }
```

## Adding Dependencies

Add npm packages with the --cl flag:

```bash
jac add --cl react-router-dom
```
