"""Overshoot CLI."""

from __future__ import annotations

import argparse


def _cmd_serve(args: argparse.Namespace) -> None:
    import uvicorn

    from overshoot.api.main import create_app

    print(f'overshoot — launching server on http://{args.host}:{args.port}')
    app = create_app()
    uvicorn.run(app, host=args.host, port=args.port)


def main() -> None:
    parser = argparse.ArgumentParser(prog='overshoot')
    subparsers = parser.add_subparsers(dest='command')

    serve_parser = subparsers.add_parser('serve', help='Run the FastAPI server')
    serve_parser.add_argument('--port', type=int, default=8050)
    serve_parser.add_argument('--host', default='127.0.0.1')

    args = parser.parse_args()

    if args.command is None:
        args.port = 8050
        args.host = '127.0.0.1'
        _cmd_serve(args)
    elif args.command == 'serve':
        _cmd_serve(args)


if __name__ == '__main__':
    main()
