#!/usr/bin/env python3
import sqlite3
import sys

DB = sys.argv[1] if len(sys.argv) > 1 else "/opt/infrastructure/data/netbird_management/idp.db"

con = sqlite3.connect(DB)
connector_ids = [row[0] for row in con.execute("select id from connector where type = 'google'")]
if not connector_ids:
    print("no external Google connectors found")
    raise SystemExit(0)

placeholders = ",".join("?" * len(connector_ids))
for table, column in (
    ("auth_request", "connector_id"),
    ("auth_code", "connector_id"),
    ("refresh_token", "connector_id"),
    ("auth_session", "connector_id"),
    ("offline_session", "conn_id"),
    ("user_identity", "connector_id"),
):
    con.execute(f"delete from {table} where {column} in ({placeholders})", connector_ids)
con.execute("delete from connector where type = 'google'")
con.commit()
print(f"removed {len(connector_ids)} external Google connector(s)")
