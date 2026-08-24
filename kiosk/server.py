import asyncio
import json
import os

import mysql.connector
import websockets

import config

DB_HOST = os.environ.get("GCV_DB_HOST", config.DB_HOST)
DB_NAME = os.environ.get("GCV_DB_NAME", config.DB_NAME)
DB_USER = os.environ.get("GCV_DB_USER", config.DB_USER)
DB_PASSWORD = os.environ.get("GCV_DB_PASSWORD", config.DB_PASSWORD)
WS_HOST = "127.0.0.1"
WS_PORT = int(os.environ.get("GCV_KIOSK_WS_PORT", config.KIOSK_WS_PORT))
POLL_SECONDS = 3

if not DB_PASSWORD or DB_PASSWORD == "REPLACE_ME":
    raise SystemExit("kiosk/config.py has no DB_PASSWORD set. Copy config.example.py to config.py and fill it in.")

clients = set()
last_payload = None


def fetch_pending():
    conn = mysql.connector.connect(
        host=DB_HOST, database=DB_NAME, user=DB_USER, password=DB_PASSWORD,
    )
    try:
        cur = conn.cursor(dictionary=True)
        cur.execute(
            "SELECT id, vehicle_no, transporter, material FROM vehicle_entries "
            "WHERE is_inside = 0 AND DATE(submitted_at) = CURDATE() "
            "ORDER BY submitted_at DESC"
        )
        rows = cur.fetchall()
        cur.close()
        return rows
    finally:
        conn.close()


async def broadcast(payload):
    if not clients:
        return
    message = json.dumps(payload)
    await asyncio.gather(*(c.send(message) for c in list(clients)), return_exceptions=True)


async def poll_loop():
    global last_payload
    while True:
        try:
            rows = fetch_pending()
            payload = {"type": "vehicles", "vehicles": rows}
            if payload != last_payload:
                last_payload = payload
                await broadcast(payload)
        except Exception as exc:
            await broadcast({"type": "error", "message": str(exc)})
        await asyncio.sleep(POLL_SECONDS)


async def handle_client(websocket):
    clients.add(websocket)
    try:
        if last_payload:
            await websocket.send(json.dumps(last_payload))
        async for _ in websocket:
            pass  # kiosk is read-only; any inbound message is ignored
    finally:
        clients.discard(websocket)


async def main():
    async with websockets.serve(handle_client, WS_HOST, WS_PORT):
        await poll_loop()


if __name__ == "__main__":
    asyncio.run(main())
