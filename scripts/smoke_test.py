#!/usr/bin/env python3
"""Live smoke test for the Rescue Alert deployment.

Usage:
    BASE_URL=http://ubuntu03:30093 python3 scripts/smoke_test.py

Admin/session checks read deploy/.env.deploy unless SMOKE_ADMIN_USER and
SMOKE_ADMIN_PASSWORD are set. No secrets are printed.
"""

import json
import os
import sys
import urllib.error
import urllib.request
from http.cookiejar import CookieJar
from pathlib import Path

BASE_URL = os.environ.get("BASE_URL", "http://ubuntu03:30093").rstrip("/")
ROOT = Path(__file__).resolve().parent.parent
ENV_FILE = ROOT / "deploy" / ".env.deploy"

failures = []


def load_env():
    values = {}
    if ENV_FILE.exists():
        for line in ENV_FILE.read_text().splitlines():
            if "=" in line and not line.lstrip().startswith("#"):
                key, value = line.split("=", 1)
                values[key.strip()] = value.strip()
    return values


env = load_env()
ADMIN_USER = os.environ.get("SMOKE_ADMIN_USER", env.get("DJANGO_SUPERUSER_USERNAME", ""))
ADMIN_PASSWORD = os.environ.get(
    "SMOKE_ADMIN_PASSWORD", env.get("DJANGO_SUPERUSER_PASSWORD", "")
)
USER = os.environ.get("SMOKE_USER", "rescuer1")
PASSWORD = os.environ.get("SMOKE_PASSWORD", "test123")


def opener():
    return urllib.request.build_opener(
        urllib.request.HTTPCookieProcessor(CookieJar())
    )


def request(client, method, path, data=None, token=None, headers=None):
    body = json.dumps(data).encode() if data is not None else None
    req = urllib.request.Request(BASE_URL + path, data=body, method=method)
    req.add_header("Content-Type", "application/json")
    if token:
        req.add_header("Authorization", f"Bearer {token}")
    for key, value in (headers or {}).items():
        req.add_header(key, value)
    try:
        with client.open(req, timeout=20) as response:
            raw = response.read().decode()
            try:
                return response.status, json.loads(raw) if raw else {}
            except json.JSONDecodeError:
                return response.status, {"body": raw[:200]}
    except urllib.error.HTTPError as error:
        raw = error.read().decode()
        try:
            return error.code, json.loads(raw) if raw else {}
        except json.JSONDecodeError:
            return error.code, {"body": raw}
    except Exception as error:  # network failure
        return 0, {"error": str(error)}


def check(name, condition, detail=""):
    status = "PASS" if condition else "FAIL"
    print(f"[{status}] {name}" + (f" — {detail}" if detail and not condition else ""))
    if not condition:
        failures.append(name)


def csrf(client):
    # The CookieJar is attached to the opener, so inspect its handlers.
    for handler in client.handlers:
        jar = getattr(handler, "cookiejar", None)
        if jar is None:
            continue
        for cookie in jar:
            if cookie.name == "csrftoken":
                return cookie.value
    return ""


print(f"Smoke testing {BASE_URL}")

# Public pages
for path in ["/", "/get-token.html", "/api/docs/", "/admin/login/"]:
    status, _ = request(opener(), "GET", path)
    check(f"GET {path}", status == 200, f"HTTP {status}")

# Authentication is required.
status, _ = request(opener(), "GET", "/api/alerts/")
check("GET /api/alerts/ without auth", status == 401, f"HTTP {status}")

# JWT flow with a seeded volunteer.
status, login = request(
    opener(), "POST", "/api/token/", {"username": USER, "password": PASSWORD}
)
check(f"JWT login for {USER}", status == 200 and "access" in login, f"HTTP {status}")
access = login.get("access", "")
refresh = login.get("refresh", "")

if access:
    status, whoami = request(
        opener(), "GET", "/api/auth/whoami/", token=access
    )
    check("JWT whoami", status == 200 and whoami.get("authenticated") is True, f"HTTP {status}")
    status, alerts = request(opener(), "GET", "/api/alerts/", token=access)
    check(
        "JWT alerts",
        status == 200 and isinstance(alerts, list),
        f"HTTP {status}",
    )

if refresh:
    status, refreshed = request(
        opener(), "POST", "/api/token/refresh/", {"refresh": refresh}
    )
    check(
        "JWT refresh",
        status == 200 and bool(refreshed.get("access")),
        f"HTTP {status}",
    )

# Session flow for the dispatcher panel.
if ADMIN_USER and ADMIN_PASSWORD:
    admin = opener()
    status, session = request(admin, "GET", "/api/auth/session/")
    check("Session is anonymous initially", status == 200 and session.get("authenticated") is False)

    status, body = request(
        admin,
        "POST",
        "/api/auth/session/login/",
        {"username": ADMIN_USER, "password": ADMIN_PASSWORD},
        headers={"X-CSRFToken": csrf(admin)},
    )
    check("Admin session login", status == 200 and body.get("authenticated") is True, f"HTTP {status}")

    status, session = request(admin, "GET", "/api/auth/session/")
    check(
        "Admin session current user",
        status == 200
        and session.get("authenticated") is True
        and session.get("user", {}).get("username") == ADMIN_USER,
    )

    status, _ = request(
        admin,
        "POST",
        "/api/auth/session/logout/",
        headers={"X-CSRFToken": csrf(admin)},
    )
    check("Admin session logout", status == 204, f"HTTP {status}")

    # Volunteers must not be able to use the web dispatcher panel.
    volunteer = opener()
    request(volunteer, "GET", "/api/auth/session/")
    status, _ = request(
        volunteer,
        "POST",
        "/api/auth/session/login/",
        {"username": USER, "password": PASSWORD},
        headers={"X-CSRFToken": csrf(volunteer)},
    )
    check("Volunteer panel login rejected", status == 400, f"HTTP {status}")
else:
    print("[SKIP] Admin session checks: no admin credentials in deploy/.env.deploy")

print()
if failures:
    print(f"{len(failures)} check(s) failed: {', '.join(failures)}")
    sys.exit(1)
print("All smoke checks passed.")
