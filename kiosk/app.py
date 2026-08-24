import asyncio
import http.server
import pathlib
import socketserver
import sys
import threading

import webview

import server


def resource_path(*parts):
    base = pathlib.Path(getattr(sys, "_MEIPASS", pathlib.Path(__file__).parent))
    return base.joinpath(*parts)


UI_DIR = resource_path("ui")
HTTP_PORT = 8766


def serve_ui():
    class Handler(http.server.SimpleHTTPRequestHandler):
        extensions_map = {**http.server.SimpleHTTPRequestHandler.extensions_map, ".webp": "image/webp"}

        def __init__(self, *args, **kwargs):
            super().__init__(*args, directory=str(UI_DIR), **kwargs)

        def log_message(self, *args):
            pass

    with socketserver.TCPServer(("127.0.0.1", HTTP_PORT), Handler) as httpd:
        httpd.serve_forever()


def serve_ws():
    asyncio.run(server.main())


def main():
    threading.Thread(target=serve_ui, daemon=True).start()
    threading.Thread(target=serve_ws, daemon=True).start()

    webview.create_window(
        "Gate Watch",
        f"http://127.0.0.1:{HTTP_PORT}/index.html",
        fullscreen=True,
        frameless=True,
        resizable=False,
        confirm_close=False,
    )

    webview.start(debug=False)


if __name__ == "__main__":
    main()
