#!/usr/bin/env python3
import base64
import datetime
import hashlib
import json
import sqlite3
import uuid

DB = "/opt/infrastructure/data/netbird_management/store.db"
GROUP_NAME = "Home"
KEY_NAME = "Ansible generated setup key"

setup_key = str(uuid.uuid4()).upper()
con = sqlite3.connect(DB)
group = con.execute(
    "select id, account_id from groups where name = ?", (GROUP_NAME,)
).fetchone()
if not group:
    raise SystemExit("NetBird group 'Home' does not exist")

group_id, account_id = group
now = datetime.datetime.now(datetime.timezone.utc)
expires = now + datetime.timedelta(days=30)
con.execute(
    """insert into setup_keys
       (id, account_id, key, key_secret, name, type, created_at, expires_at,
        updated_at, revoked, used_times, auto_groups, usage_limit, ephemeral,
        allow_extra_dns_labels)
       values (?, ?, ?, ?, ?, ?, ?, ?, ?, 0, 0, ?, 0, 0, 0)""",
    (
        uuid.uuid4().hex[:21],
        account_id,
        base64.b64encode(hashlib.sha256(setup_key.encode()).digest()).decode(),
        setup_key[:5] + "****",
        KEY_NAME,
        "reusable",
        now.isoformat(),
        expires.isoformat(),
        now.isoformat(),
        json.dumps([group_id]),
    ),
)
con.commit()
print(setup_key)
