#!/usr/bin/env python3
"""Self-check for session_store_sync.map_entry. Run: python3 test_session_store_sync.py"""

from session_store_sync import map_entry

assert map_entry({"type": "user", "message": {"role": "user", "content": "plain text"}}) == (
    "message", {"role": "user", "content": "plain text"}
)

tool_result_msg = {"role": "user", "content": [{"type": "tool_result", "tool_use_id": "x", "content": "ok"}]}
assert map_entry({"type": "user", "message": tool_result_msg}) == ("tool_result", tool_result_msg)

assert map_entry({"type": "assistant", "message": {"role": "assistant", "content": [{"type": "text", "text": "hi"}]}}) == (
    "message", {"role": "assistant", "content": [{"type": "text", "text": "hi"}]}
)

t, p = map_entry({"type": "attachment", "uuid": "a1"})
assert t == "meta" and p["piType"] == "attachment" and p["uuid"] == "a1"

print("ok")
