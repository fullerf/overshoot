# overshoot

FastAPI backend + React (Vite + TypeScript) frontend.

### Quick start

1. Install `uv` (v0.8.15+) and Node.js (v20+):

   ```bash
   curl -LsSf https://astral.sh/uv/install.sh | sh
   ```

2. Install dependencies:

   ```bash
   uv sync                        # Python backend
   cd frontend && npm install     # React frontend
   cd ..
   ```

3. Run locally:

   ```bash
   ./dev-start.sh                 # backend (:8050) + frontend (:5173)
   ./dev-stop.sh                  # stop both
   ```

   Open http://localhost:5173.

### CLI

```bash
overshoot serve --port 8050
```

### Layout

```
src/overshoot/
  api/          # FastAPI app + routes
  cli.py        # `overshoot` entrypoint
frontend/
  src/app/      # React app
```
