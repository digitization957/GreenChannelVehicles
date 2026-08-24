"""Template for kiosk/config.py — copy this file to config.py and fill in the real password.

kiosk/config.py is gitignored on purpose: it holds the live DB credentials that get baked
into the built .exe. Never commit the real file.
"""

DB_HOST = "mazpngpappmysql01.mysql.database.azure.com"
DB_NAME = "gcv_db"
DB_USER = "ngpdbadm"
DB_PASSWORD = "REPLACE_ME"

KIOSK_WS_PORT = 8765
KIOSK_HTTP_PORT = 8766
