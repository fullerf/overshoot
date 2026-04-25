#!/bin/bash
# Start overshoot backend + frontend for local development.
# Backend (FastAPI) runs on port 8050.
# Frontend (Vite) runs on port 5173 with API proxy to backend.
# Open http://localhost:5173 in your browser.

set -e

PIDFILE=".dev-pids"

if [ -f "$PIDFILE" ]; then
    echo "Dev servers appear to be running already. Run ./dev-stop.sh first."
    exit 1
fi

echo "Starting backend on :8050..."
uv run overshoot serve --port 8050 &
BACKEND_PID=$!

echo "Starting frontend on :5173..."
cd frontend && npm run dev &
FRONTEND_PID=$!
cd ..

echo "$BACKEND_PID" > "$PIDFILE"
echo "$FRONTEND_PID" >> "$PIDFILE"

echo ""
echo "Backend PID:  $BACKEND_PID (http://localhost:8050)"
echo "Frontend PID: $FRONTEND_PID (http://localhost:5173)"
echo ""
echo "Open http://localhost:5173 in your browser."
echo "Run ./dev-stop.sh to shut down."

wait
