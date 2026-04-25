"""FastAPI application factory for overshoot."""

from __future__ import annotations

from pathlib import Path

from fastapi import FastAPI
from fastapi.responses import FileResponse

from overshoot.api.routes import router


def create_app() -> FastAPI:
    app = FastAPI(title='Overshoot')
    app.include_router(router, prefix='/api')

    @app.get('/health')
    def health():
        return 'ok'

    static_dir = _find_static_dir()
    if static_dir is not None:
        @app.get('/{path:path}', include_in_schema=False)
        async def spa_fallback(path: str):
            file_path = static_dir / path
            if file_path.is_file():
                return FileResponse(str(file_path))
            return FileResponse(str(static_dir / 'index.html'))

    return app


def _find_static_dir() -> Path | None:
    candidates = [
        Path(__file__).parent.parent.parent.parent / 'frontend' / 'dist',
        Path('/app/frontend/dist'),
    ]
    for candidate in candidates:
        if candidate.exists() and (candidate / 'index.html').exists():
            return candidate
    return None
