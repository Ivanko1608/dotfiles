# graphify
- **graphify** (`~/.claude/skills/graphify/SKILL.md`) - any input to knowledge graph. Trigger: `/graphify`
When the user types `/graphify`, use the installed graphify skill or instructions before doing anything else.

# Subagents
- Spawn subagents on Sonnet (default via `CLAUDE_CODE_SUBAGENT_MODEL` in settings.json). Pass `model: "opus"` only when a Sonnet subagent is struggling (failed, stuck, or clearly out of its depth) on that task.

# Naming
- Functions are verb-first, in standard vocabulary: get, create, remove, parse, run, handle, `toX`, `xFromY` (`getOrCreateChat`, `removeExpiredChats`, `parseChange`, `toAnthropicTool`, `turnFromOpenAI`, `truncate`).
- No prose or preposition names (`chatFor`, `detailOf`, `changeIn`, `turnOf`), no metaphors (`forgetIdle`, `work`), no cryptic abbreviations (`def`).
- Fields name the concrete thing and reuse existing domain types (`Source store.Source`, not a new word like `Author`).
- Name length follows scope: one letter only for a loop index or a tiny closure.
- One concept, one name, everywhere: code, JSON, UI, docs.
- Fixed sets of strings are typed constants, defined once.
- Unnamed results of the same type get names or a small struct.
- Test before committing: would a stranger guess what it does from the name alone?
- Reference style: the user's hand-written `~/learning/freedom-tls` (`connect`, `handshake`, `resolve_domain`, `try_from_handshake`, `client_stream`, `server_addr`).

# Reuse before building
- Before writing a tool, script, hook, CI step or helper, look for an existing one: the standard library, the project's dependencies, installed skills and plugins (`~/.claude/skills`, `~/.claude/plugins`), and well-known tools (gitleaks, pre-commit hooks, GitHub Actions).
- Use what fits. If it's the user's own project and it falls short, extend it there instead of copying it.
- Write your own only when nothing fits, and say in one line what you checked and why it didn't fit.
