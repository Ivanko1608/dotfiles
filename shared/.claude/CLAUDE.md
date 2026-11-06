# graphify
- **graphify** (`~/.claude/skills/graphify/SKILL.md`) - any input to knowledge graph. Trigger: `/graphify`
When the user types `/graphify`, use the installed graphify skill or instructions before doing anything else.

# Subagents
- Spawn subagents on Sonnet (default via `CLAUDE_CODE_SUBAGENT_MODEL` in settings.json). Pass `model: "opus"` only when a Sonnet subagent is struggling (failed, stuck, or clearly out of its depth) on that task.

# Reuse before building
- Before writing a tool, script, hook, CI step or helper, look for an existing one: the standard library, the project's dependencies, installed skills and plugins (`~/.claude/skills`, `~/.claude/plugins`), and well-known tools (gitleaks, pre-commit hooks, GitHub Actions).
- Use what fits. If it's the user's own project and it falls short, extend it there instead of copying it.
- Write your own only when nothing fits, and say in one line what you checked and why it didn't fit.

# Global instructions

## Working style
- Change one file at a time; the user reviews every diff in nvim before the next.
- Never print file contents in chat. Summarize what changed and why, and map it to the task/requirement it serves.
- **Separate concerns into separate commits.** Feature work, unrelated fixes and refactors never share a commit.
- Don't silently keep bad code from the existing codebase. Flag it, and if it stays, say why in the PR description.

## Structure
- **A function reads as a list of steps.** The top-level function says *what* happens, and named helpers say *how*. If you want to put a comment above a block to say what it does, extract the block into a function named after that comment.
- **One job, one level of detail.** Don't mix "decide what to do" with byte-level work in the same function. Roughly 40 lines is the point to ask what should come out.
- **Shape data the way it's read.** If readers have to work out what `xs[i+1]` or `xs[:i]` means, give the pieces names, or store the data in the order it's used.
- **Explicit inputs.** Pass what a function needs as parameters. Pass `context.Context` first through every layer that does I/O. Use it for cancellation and deadlines, not for business data that changes the result.
- **Blank lines separate the steps inside a function:** setup, guard clauses, the main work, the return. Never pack a function into one dense block.

## Expressions
- **Name conditions.** A condition with more than two terms becomes a named variable or a predicate function.
- **No meaningless arguments at the call site.** `Undo(ctx, id, 2, true)` says nothing about what `true` means. Use an options struct or a named type. Special values like "0 means latest" get a named constant.
- **No cleverness.** Write the obvious version: `filepath.Join(dir, id+".jsonl")`, not `path(id) + "l"`. No JSON round trips as a form of reflection, no rune arithmetic to build strings, and no multi-assignments of unrelated values on one line.
- **Use the standard library** (`slices.Equal`, `slices.Sort`, `maps.Keys`, `strings.Cut`) instead of hand-rolled loops that do the same thing.
- **Keep lines under about 100 characters.** Split long calls one argument per line, and pull long closures out into named functions. Lines that cannot be split sensibly are exempt, such as struct tags and long string literals.
- **Don't shadow.** In particular, don't declare `err` inside a closure when the outer function has a named `err` result.
- **Keyed struct literals.** A literal with more than three fields, or any bool field, names its fields.
- **Don't name variables after packages.** No `fs`, `log`, `errors` or `time` as locals.

## Naming
These rules apply to code in every language, not only Go. Spell each name in the language's own case style (`parseChange` in Go and JS, `parse_change` in Rust and Python).
- **Functions start with a verb, in standard vocabulary:** `get`, `create`, `remove`, `parse`, `run`, `handle`, `write`, `toX`, `xFromY` (`getOrCreateChat`, `parseChange`, `toAnthropicTool`, `turnFromOpenAI`). No nouns as function names (`bearerToken`, `unauthorized`), no preposition names (`chatFor`, `detailOf`) and no cryptic abbreviations (`def`).
- **Getters and setters are the only exception,** and follow the language's convention. In Go, a getter is named after the field (`Owner()`, not `GetOwner()`) and a setter is `SetOwner()`.
- **Length follows scope.** One letter is fine for a loop index or a three-line closure. Anything that lives longer gets a word: `newBudget`, not `nb`; `entries`, not `h`. Conventional short names (`ctx`, `err`, `req`, `res`, `w`, `r`, `ok`) are fine at any scope.
- **Use domain words, consistently.** Don't invent metaphors (`forgetIdle`, or "doors" for transports). One concept gets one name everywhere: Go, JSON, UI and docs.
- **Fields name the concrete thing and reuse existing domain types** (`Source store.Source`, not a new word like `Author`).
- **Fixed sets of strings are typed constants**, defined once in the lowest package that owns them, never repeated as literals.
- **Unnamed results of the same type** (`func(T) (string, string)`) need names or a small struct.
- **Ask whether a stranger would guess what a function or variable does from its name alone.** If not, rename it.
- Reference style: the user's hand-written `~/learning/freedom-tls` (`connect`, `handshake`, `resolve_domain`, `try_from_handshake`, `client_stream`, `server_addr`).

## Comments
Few and short.
- Exported identifiers get one sentence that states the contract.
- Inside a function, comment only a *why* the code can't show: a non-obvious ordering, a lock, a deliberate trade-off.
- Never: restate the code, label blocks, justify why a function exists, or refer to branches, PRs or history. That belongs in the commit message.
- Leave existing comments alone unless your change makes them wrong.
- Field comments go on the line above the field, not trailing.

## Tests
- **A test reads like a spec.** Arrange, act and assert, with blank lines between them. Helpers say what they do in domain terms.
- **One assertion per fact.** Don't put five checks in a single `if a || b || c` with one message.
- **Table-driven tests** with `t.Run` when cases share a shape. Use `httptest` for handlers.
- **Fakes, not mocks.** Write fakes by hand for the interfaces a package consumes.
- **Every error in setup code is checked.**

## Safety — hard rules
- NEVER commit, stage, or push `.env` or any file with secrets/credentials, in any repo, on any branch. Check `git status` before every commit. If `.env` is not gitignored, say so.
- Never commit or push without being asked.
- **Never leak internal errors** (stack traces, file paths, storage errors) to API clients. Log them server-side and return a generic message.
- **Validate all external input at the boundary:** query params, path values, JSON bodies. Reject bad input with 400, and enforce the same limits as the schema (e.g. VARCHAR lengths) before it reaches storage.
- **Cap request body size** (`http.MaxBytesReader`) with a limit derived from the payload, and document how it was derived in a comment next to the constant.
- **Use `json.Decoder.DisallowUnknownFields()`** for write endpoints.
- **Parameterized queries only.** Never build SQL by concatenating input.
- Money is never `float64`. Use a decimal type end to end; serialise as a decimal string.
- **NULLable DB columns map to nullable Go types** (`sql.Null*`, `decimal.NullDecimal`, pointers).
- **Write a response only after it is fully built:** marshal first, then set headers and status, then write.
- **Graceful shutdown uses a fresh timeout context,** not the already-cancelled signal context.

## Go idioms
- **Accept interfaces, return structs.** Define interfaces in the consumer package, small (1–3 methods), describing only what the consumer uses.
- **Sentinel errors are specific to one case** (`ErrProductNotFound`, not `ErrFailed`). Translate driver or filesystem errors into them at the storage boundary, so upper layers never see them. Check with `errors.Is`.
- **Wrap errors with context:** `fmt.Errorf("loading product %q: %w", code, err)`.
- **Never ignore errors.** If one truly can't be handled, log it and say why.
- **Library code returns errors;** only `main` calls `log.Fatal` or `os.Exit`.
- **Return a zero value with the error.** Return `(T{}, err)` or `(nil, err)`, and never use the value when `err != nil`.
- **Keep the HTTP layer thin:** parse, call the application layer, map, respond. Response DTOs live in the handler package.
- **Use `ServeMux` patterns** like `GET /items/{id}` with `r.PathValue("id")`.
- **No premature abstraction.** Don't add layers, configuration flags or plug-in points for a case that doesn't exist yet. Named helpers that make a function read as steps, and consumer interfaces for fakes, are not premature.
- `gofmt`, `go vet` clean before handing anything over.
