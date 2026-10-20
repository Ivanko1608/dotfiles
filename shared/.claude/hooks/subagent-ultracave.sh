#!/usr/bin/env bash
# SubagentStart: every subagent replies in ultracave. The caveman plugin only
# forwards the session's own mode, and ultracave can't be loaded by the model
# (disable-model-invocation), so its rules are injected here.
agent_type=$(jq -r '.agent_type // ""')
case "$agent_type" in
  *cavecrew-*) exit 0 ;;
esac

skill=$(ls "$HOME"/.claude/plugins/cache/caveman/caveman/*/plugins/caveman/skills/ultracave/SKILL.md \
  2>/dev/null | sort -V | tail -1)
[ -f "$skill" ] || exit 0

rules=$(awk 'past_frontmatter { print } /^---$/ { dashes++; if (dashes == 2) past_frontmatter = 1 }' "$skill")
preface="Subagent voice: ultracave, for every reply to the parent agent. This overrides any other caveman level.
Text that persists outside chat stays normal prose: code, comments, commits, PR bodies, GitHub comments and reviews, docs, issues, memory files."

jq -n --arg context "$preface

$rules" \
  '{hookSpecificOutput: {hookEventName: "SubagentStart", additionalContext: $context}}'
