# ChatGPT iOS Stack Demo

A standalone iOS demo app for visually evaluating a ChatGPT-style native chat experience built with open-source Swift/iOS libraries found in the ChatGPT iOS dependency stack.

## Goals

- Feel like a live AI agent without requiring any API key or backend.
- Show streaming replies, thinking, search/tool timelines, rich Markdown, code, remote images, voice-state simulation, interactive cards, error/retry states, light/dark mode, and RTL/LTR behavior.
- Keep this repository isolated from Hanlin so the UI stack can be evaluated safely before any migration decision.
- Produce an unsigned IPA from GitHub Actions for device testing.

## Included stack

The demo directly integrates:

- MarkdownUI (which itself uses cmark-gfm)
- Kingfisher
- Highlightr
- Lottie
- Pow

The app also includes a Library Gallery that makes it obvious which pieces are powered by which library. Unrelated ChatGPT app dependencies such as payments, analytics, subscriptions, banking, crash reporting, and feature flags are intentionally excluded because they do not affect the chat UI.

## Demo behavior

The main Chat tab uses a deterministic local mock-agent. Sending any message starts a staged live sequence:

1. Thinking
2. Web-search activity
3. Tool execution
4. Rich result card
5. Streaming Markdown answer
6. Code sample
7. Remote image result
8. Final assistant actions

No network AI service is required. Only the remote-image demo uses the network.

## Build

The Xcode project is generated with XcodeGen:

```sh
brew install xcodegen
xcodegen generate
open ChatGPTStackDemo.xcodeproj
```

## IPA

Every push to `main` runs GitHub Actions and uploads an unsigned IPA artifact named `ChatGPTStackDemo-unsigned-ipa`.
