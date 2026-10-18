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

# Global instructions

## Working style
- Change one file at a time; the user reviews every diff in nvim before the next.
- Never print file contents in chat. Summarize what changed and why, and map it to the task/requirement it serves.
- No code comments unless asked, or unless something is genuinely non-obvious: a magic number, a deliberate trade-off, a known-unsafe choice kept on purpose. Then explain *why*, never *what*. Field comments go on the line above the field, not trailing.
- Don't silently keep bad code from a starter/existing codebase. Flag it; if it stays, say why.
- Separate concerns into separate commits: feature work, unrelated fixes, and refactors never share a commit.

## Safety — hard rules
- NEVER commit, stage, or push `.env` or any file with secrets/credentials, in any repo, on any branch. Check `git status` before every commit. If `.env` is not gitignored, say so.
- Never commit or push without being asked.
- Never leak internal errors (DB errors, stack traces, file paths) to API clients. Log them server-side; return a generic message.
- Validate all external input at the boundary: query params, path values, JSON bodies. Reject bad input with 400, never let it reach the DB as a 500.
- Enforce the same limits as the schema (e.g. VARCHAR lengths) before hitting the DB.
- Cap request body size (`http.MaxBytesReader`) with a limit derived from the payload, and document how it was derived.
- Use `json.Decoder.DisallowUnknownFields()` for write endpoints.
- Parameterized queries only; never build SQL with string concatenation from input.
- Money is never `float64`. Use a decimal type end to end; serialise as a decimal string.
- NULLable DB columns map to nullable Go types (`sql.Null*`, `decimal.NullDecimal`, pointers).
- Write a response only after it is fully built: marshal first, then set headers/status, then write.
- Graceful shutdown uses a fresh timeout context, not the already-cancelled signal context.
- Never ignore errors. If an error truly can't be handled, log it and say why.

## Go idioms
- Accept interfaces, return structs. Define interfaces in the consumer package, small (1–3 methods), describing only what the consumer uses.
- Pass `context.Context` as the first parameter through every layer that does I/O (`db.WithContext(ctx)`).
- Sentinel errors are specific to one case (`ErrProductNotFound`, not `ErrNotFound`). Repositories translate driver/ORM errors into them so upper layers never import the ORM. Check with `errors.Is`.
- Wrap errors with context: `fmt.Errorf("loading product %q: %w", code, err)`.
- Library/package code returns errors; only `main` calls `log.Fatal`/`os.Exit`.
- Zero values should be useful; return `(T{}, err)` or `(nil, err)` and never use the value when `err != nil`.
- Keep the HTTP layer thin: parse → call store → map → respond. Response DTOs live in the handler package; models don't carry JSON concerns.
- Use the standard library where it suffices (Go 1.22+ `ServeMux` patterns like `GET /items/{code}` with `r.PathValue`).
- Table-driven tests with `t.Run`, `httptest`, and hand-written fakes for the store interfaces. No mocking frameworks unless the project already uses one.
- `gofmt`, `go vet` clean before handing anything over.
- No premature abstraction. Simple and explicit beats clever.
