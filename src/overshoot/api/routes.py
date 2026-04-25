"""API routes for overshoot."""

from __future__ import annotations

from fastapi import APIRouter

router = APIRouter()


@router.get('/hello')
def hello():
    return {'message': 'hello from overshoot'}
