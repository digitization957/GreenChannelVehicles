import http.server
import pathlib
import socketserver
import subprocess
import sys
import threading

import webview

BASE_DIR = pathlib.Path(__file__).parent
UI_DIR = BASE_DIR / "ui"
HTTP_PORT = 8766


def serve_ui():
    class Handler(http.server.SimpleHTTPRequestHandler):
        def __init__(self, *args, **kwargs):
            super().__init__(*args, directory=str(UI_DIR), **kwargs)

        def log_message(self, *args):
            pass

    with socketserver.TCPServer(("127.0.0.1", HTTP_PORT), Handler) as httpd:
        httpd.serve_forever()


def main():
    threading.Thread(target=serve_ui, daemon=True).start()
    ws_process = subprocess.Popen([sys.executable, str(BASE_DIR / "server.py")])

    window = webview.create_window(
        "Gate Watch",
        f"http://127.0.0.1:{HTTP_PORT}/index.html",
        fullscreen=True,
        frameless=True,
        resizable=False,
        confirm_close=False,
    )
    window.events.closed += lambda: ws_process.terminate()

    webview.start(debug=False)


if __name__ == "__main__":
    main()
