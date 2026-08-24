"""Live kiosk DB config — gitignored on purpose, holds the real DB credentials that get
baked into the built .exe. Never commit this file."""

DB_HOST = "mazpngpappmysql01.mysql.database.azure.com"
DB_NAME = "gcv_db"
DB_USER = "ngpdbadm"
DB_PASSWORD = "%%89evqezbJB"

KIOSK_WS_PORT = 8765
KIOSK_HTTP_PORT = 8766
