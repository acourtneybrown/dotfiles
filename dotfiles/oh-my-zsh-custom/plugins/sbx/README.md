# sbx

> zsh plugin to run AI coding CLIs (`opencode`, `claude`, `codex`) against a local
> [LM Studio](https://lmstudio.ai/) model server, via Docker.

## Overview

This plugin wires up the `sbx` CLI (Docker's container sandbox tool) to act as a
gateway to a locally running [LM Studio](https://lmstudio.ai/) model server, so
that AI coding agents can use models served from your own machine instead of a
hosted provider.

It is only loaded when the `sbx` binary is available on your `PATH`.

The LM Studio local model server exposes OpenAI-compatible (and Anthropic-
compatible) APIs and listens on `http://localhost:1234` by default. The plugin
talks to that server, asks it which models are available, and then runs the
requested AI CLI inside a Docker sandbox pointed at the local server.

> Before using this plugin, follow the
> [LM Studio documentation on enabling the local model server](https://lmstudio.ai/docs/developer/core/server),
> start the server, and make sure a model is loaded and running.

## Prerequisites

- [LM Studio](https://lmstudio.ai/) installed, with at least one model downloaded
  and loaded
- The LM Studio local server started, either via the "Start server" toggle in
  the Developer tab or via the `lms` CLI, e.g. `lms server start`
  - see the
    [`lms server start` documentation](https://lmstudio.ai/docs/cli/serve/server-start)
- Docker `sbx` installed

## Functions

### AI CLI wrappers

These functions wrap the underlying AI CLI and pass through its arguments, so
anything the CLI itself accepts can be used:

- `sbxopencode` — run `opencode` against the local LM Studio model server
- `sbxcodex` — run `codex` against the local LM Studio model server
- `sbxclaude` — run `claude` against the local LM Studio model server

They accept the same flags as the wrapped CLI, including `--model`:

```sh
sbxopencode
sbxopencode --model qwen/qwen3-coder-next
sbxclaude --model <model>
sbxcodex --model openai/gpt-oss-20b
```

Run `sbx_models` to see the models currently available on your LM Studio
server, and use one of those IDs with `--model`.

### Model discovery & management

- `sbx_models` — list the models discovered on the LM Studio server

- `sbx_global [model]` — set (or, with no arguments, read) the global default
  model, stored in `~/.sbx-model`

- `sbx_local [model]` — set (or, with no arguments, read) the model for the
  current directory, stored in `./.sbx-model`

## How the model is selected

When a wrapper such as `sbxopencode` is invoked:

1. An explicit `--model <model>` argument passed to the wrapper takes
   precedence and is forwarded to the underlying CLI.
2. Otherwise, the plugin walks up the directory tree from the current working
   directory looking for a `.sbx-model` file, using the nearest one found.
3. If no model was explicitly requested and no `.sbx-model` file was found,
   the first model discovered on the LM Studio server is used.

If the resolved model isn't among the models discovered on the LM Studio
server, the wrapper prints a warning and falls back to the first discovered
model.

## Environment

- `LMSTUDIO_API_KEY` — the API key expected by the LM Studio server, loaded
  from 1Password via the `op` CLI.

  Per the
  [LM Studio authentication docs](https://lmstudio.ai/docs/developer/core/authentication),
  the LM Studio API server does not require authentication by default; if
  authentication is enabled, requests must include a valid API token, e.g.
  `Authorization: Bearer $LM_API_TOKEN`.

- The LM Studio provider is configured in Docker (`sbx`) with the URL
  `http://localhost:1234/v1` and the `LMSTUDIO_API_KEY` environment variable,
  as well as an Anthropic-wire provider (`lms-anthropic`) for `claude`.

## See also

- [LM Studio as a Local LLM API Server](https://lmstudio.ai/docs/developer/core/server)
  — how to enable and run the local model server
- [Get up and running with the LM Studio API](https://lmstudio.ai/docs/developer/rest/quickstart)
  — downloading a model and making your first API call
- [`lms server start`](https://lmstudio.ai/docs/cli/serve/server-start) — start
  the LM Studio local server via the CLI
- [OpenAI Compatibility Endpoints](https://lmstudio.ai/docs/developer/openai-compat)
  — using OpenAI-compatible clients against the local server (e.g. Codex via
  `POST /v1/responses`)
- [Authentication](https://lmstudio.ai/docs/developer/core/authentication) —
  API tokens for the LM Studio server
