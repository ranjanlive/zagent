# Contributing to zengine

Thank you for helping. This page is the short version; [docs/DEVELOPMENT.md](docs/DEVELOPMENT.md) has the code map, the invariants the engine relies on, and step-by-step recipes for the common extensions (a provider, a built-in tool, a config key, a slash command).

## Before you start

- **Bug?** Open an issue with: what you ran, what you expected, what happened, the version (`zagent version`), your OS, and (if it involves a session) the output of `zagent show SESSION --debug` with secrets removed.
- **Feature?** Open an issue first for anything larger than a small fix, so the design can be agreed before you invest time. The engine has deliberate constraints (a deterministic, append-only log; a frozen prompt prefix; no interface-owned state) that shape what fits.
- **Security issue?** Do not file it publicly; contact the maintainers privately (add the address to `SECURITY.md` when the project is published).

## Making a change

1. Fork, branch from `main`.
2. `make check` must pass: `gofmt`, `go vet`, and all tests. For platform-specific code also run `GOOS=linux go vet ./...` and `GOOS=darwin go vet ./...`.
3. **Add tests that fail without your change** (see the patterns in `docs/DEVELOPMENT.md#testing`). A bug fix needs a regression test.
4. **Update the docs** that describe the behaviour you changed (`README.md`, `docs/CONFIG.md`, `docs/EXTERNAL_TOOLS.md`, ...), and add a line to `CHANGELOG.md` under *Unreleased*.
5. Keep commits focused and the message explaining *why*. Open a pull request describing what changed, how you tested it, and anything you could not test (for example a platform you do not have).

## Ground rules

- Keep the invariants in `docs/DEVELOPMENT.md` intact: never rewrite history, keep rendering deterministic, put new information at the end of a turn.
- Messages the model or user will read must be concrete and tell them what to do next.
- Prefer the standard library; new dependencies need a reason.
- Do not commit secrets, local `.env` files, session data or build output (`dist/`).
