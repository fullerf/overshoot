# Stage 1: Build frontend
FROM node:20-alpine AS frontend-build
WORKDIR /frontend
COPY frontend/package.json frontend/package-lock.json ./
RUN npm ci
COPY frontend/ ./
RUN npm run build

# Stage 2: Python runtime
FROM ghcr.io/astral-sh/uv:python3.12-bookworm

WORKDIR /app

RUN apt-get -yq update && \
    apt-get -yq install --no-install-recommends ca-certificates && \
    rm -rf /var/lib/apt/lists/*

COPY pyproject.toml uv.lock README.md LICENSE.md /app/
COPY src/ /app/src/

RUN uv sync --frozen --no-dev

COPY . /app

RUN uv pip install --no-deps -e /app

# Copy built frontend from stage 1
COPY --from=frontend-build /frontend/dist /app/frontend/dist

EXPOSE 8050

CMD ["/app/.venv/bin/overshoot", "serve", "--host", "0.0.0.0"]
