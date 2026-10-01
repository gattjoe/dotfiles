#!/usr/bin/env python3
"""Mirrors interactive Claude Code session transcripts to session-store
(https://github.com/gattjoe/pathfinder/tree/main/session-store), the same
remote store pi-session-store already mirrors pi sessions to.

Usage: session_store_sync.py register|sync   (hook JSON read from stdin)

register  -> SessionStart hook: POST /sessions
sync      -> Stop / SessionEnd hooks: re-read transcript_path, ship any
             lines past what's already been synced (tracked in a sidecar
             file next to the transcript, since each hook invocation is a
             fresh process with no in-memory state to dedupe against).

No token configured (~/.claude/session-store-token missing/empty) = fully
silent no-op, same contract as pi-session-store.
"""

import json
import os
import sys
import urllib.error
import urllib.request

TOKEN_FILE = os.path.expanduser("~/.claude/session-store-token")
DEFAULT_URL = "https://sessions.echobase.network"


def load_token() -> str:
    try:
        with open(TOKEN_FILE) as f:
            return f.read().strip()
    except FileNotFoundError:
        return ""


def post(url: str, token: str, path: str, body: dict) -> bool:
    """Returns True on success (2xx or 409-already-exists), False otherwise."""
    req = urllib.request.Request(
        f"{url}{path}",
        data=json.dumps(body).encode(),
        headers={"Content-Type": "application/json", "Authorization": f"Bearer {token}"},
        method="POST",
    )
    try:
        urllib.request.urlopen(req, timeout=5).read()
        return True
    except urllib.error.HTTPError as e:
        if e.code == 409:
            return True
        print(f"[session_store_sync] {path} -> HTTP {e.code}", file=sys.stderr)
        return False
    except Exception as e:
        print(f"[session_store_sync] {path} -> {e}", file=sys.stderr)
        return False


def map_entry(entry: dict) -> tuple[str, dict]:
    t = entry.get("type")
    if t in ("assistant", "user"):
        message = entry.get("message") or {}
        content = message.get("content")
        is_tool_result = isinstance(content, list) and any(
            isinstance(b, dict) and b.get("type") == "tool_result" for b in content
        )
        return ("tool_result" if is_tool_result else "message"), message
    return "meta", {"piType": t, **entry}


def register(url: str, token: str, hook_input: dict) -> None:
    session_id = hook_input.get("session_id")
    if not session_id:
        return
    post(url, token, "/sessions", {
        "id": session_id,
        "cwd": hook_input.get("cwd"),
        "source": "claude-code",
    })


def sync(url: str, token: str, hook_input: dict) -> None:
    session_id = hook_input.get("session_id")
    transcript_path = hook_input.get("transcript_path")
    if not session_id or not transcript_path or not os.path.exists(transcript_path):
        return

    register(url, token, hook_input)  # idempotent (409-tolerant) — covers resumed old sessions

    sidecar = transcript_path + ".synced-count"
    try:
        synced = int(open(sidecar).read().strip())
    except (FileNotFoundError, ValueError):
        synced = 0

    with open(transcript_path) as f:
        lines = f.readlines()

    # Stop at the first failed POST rather than skipping past it: entries are
    # chained onto the session's current leaf server-side (no parentId sent),
    # so shipping out of order would attach a later entry under the wrong
    # parent. The unsent tail is simply retried on the next Stop/SessionEnd.
    # The sidecar is saved after every line (not once at the end) because
    # SessionEnd gets cancelled after a short timeout; progress must survive that.
    def save(n: int) -> None:
        with open(sidecar, "w") as f:
            f.write(str(n))

    i = synced
    while i < len(lines):
        line = lines[i].strip()
        if line:
            try:
                entry = json.loads(line)
            except ValueError:
                entry = None
            if entry is not None:
                entry_type, payload = map_entry(entry)
                body = {"type": entry_type, "payload": payload}
                if entry.get("uuid"):
                    body["id"] = entry["uuid"]
                if not post(url, token, f"/sessions/{session_id}/entries", body):
                    break
        i += 1
        save(i)


def main() -> None:
    token = load_token()
    if not token:
        return
    mode = sys.argv[1] if len(sys.argv) > 1 else ""
    hook_input = json.loads(sys.stdin.read() or "{}")
    url = os.environ.get("SESSION_STORE_URL", DEFAULT_URL).rstrip("/")
    if mode == "register":
        register(url, token, hook_input)
    elif mode == "sync":
        sync(url, token, hook_input)


if __name__ == "__main__":
    main()
