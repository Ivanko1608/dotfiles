#!/usr/bin/env python3
# Claude plan usage for the waybar custom/claude-usage module.
# Reads the OAuth token Claude Code keeps in ~/.claude/.credentials.json and
# asks Anthropic for the current 5-hour session and weekly limit usage.
# Never refreshes the token itself (that would rotate Claude Code's refresh
# token); running `claude` refreshes it.

import json
import os
import time
import urllib.request
from datetime import datetime

CREDENTIALS = os.path.expanduser("~/.claude/.credentials.json")
CACHE = os.path.join(os.environ.get("XDG_RUNTIME_DIR", "/tmp"), "waybar-claude-usage.json")
WIDTH = 6  # bar length in characters
EIGHTHS = " ▏▎▍▌▋▊▉"


def emit(text, tooltip, cls):
    print(json.dumps({"text": text, "tooltip": tooltip, "class": cls}))


def fetch():
    oauth = json.load(open(CREDENTIALS))["claudeAiOauth"]
    if oauth["expiresAt"] / 1000 < time.time():
        raise RuntimeError("Login expired, run claude to refresh it")
    req = urllib.request.Request(
        "https://api.anthropic.com/api/oauth/usage",
        headers={
            "Authorization": "Bearer " + oauth["accessToken"],
            "anthropic-beta": "oauth-2025-04-20",
        },
    )
    return json.load(urllib.request.urlopen(req, timeout=10))


def bar(label, pct):
    # Filled part in a severity color on a dim track
    color = "#f7768e" if pct >= 90 else "#e0af68" if pct >= 75 else "#a9b1d6"
    track = "#3b4261"
    eighths = round(min(pct, 100) / 100 * WIDTH * 8)
    full, part = divmod(eighths, 8)
    cells = f"<span color='{color}'>{'█' * full}</span>"
    if part:
        cells += f"<span color='{color}' bgcolor='{track}'>{EIGHTHS[part]}</span>"
    cells += f"<span color='{track}'>{'█' * (WIDTH - full - bool(part))}</span>"
    return f"{label} {cells} {pct}%"


def until(iso):
    reset = datetime.fromisoformat(iso).astimezone()
    mins = max(0, int((reset - datetime.now().astimezone()).total_seconds() // 60))
    left = f"{mins // 60}h {mins % 60:02d}m" if mins < 24 * 60 else f"{mins // 1440}d {mins % 1440 // 60}h"
    return f"resets {reset:%a %H:%M} (in {left})"


def main():
    stale = None
    try:
        usage = fetch()
        with open(CACHE, "w") as f:
            json.dump(usage, f)
    except Exception as e:
        try:
            usage = json.load(open(CACHE))
            stale = str(e)
        except Exception:
            emit("Claude --", f"Claude usage unavailable\n{e}", "error")
            return

    session = usage.get("five_hour") or {}
    week = usage.get("seven_day") or {}
    s = round(session.get("utilization") or 0)
    w = round(week.get("utilization") or 0)

    lines = [f"Session  {s:>3}%  {until(session['resets_at'])}" if session.get("resets_at") else f"Session  {s:>3}%"]
    lines.append(f"Weekly   {w:>3}%  {until(week['resets_at'])}" if week.get("resets_at") else f"Weekly   {w:>3}%")
    if stale:
        lines.append(f"\nLast known values, update failed:\n{stale}")

    emit(f"{bar('5h', s)}  {bar('wk', w)}", "\n".join(lines), "stale" if stale else "ok")


main()
