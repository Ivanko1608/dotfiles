# graphify
- **graphify** (`~/.claude/skills/graphify/SKILL.md`) - any input to knowledge graph. Trigger: `/graphify`
When the user types `/graphify`, use the installed graphify skill or instructions before doing anything else.

# Subagents
- Spawn subagents on Sonnet (default via `CLAUDE_CODE_SUBAGENT_MODEL` in settings.json). Pass `model: "opus"` only when a Sonnet subagent is struggling (failed, stuck, or clearly out of its depth) on that task.
