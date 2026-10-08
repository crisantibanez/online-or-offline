# Online or Offline

A tiny Mac menu bar app that tells you, in real time, whether your internet connection
actually works. Made for trains: one glance before pressing enter on a prompt.

**Everything in this repository is 100% AI-written.** Cristian Santibanez briefed and
decided; Claude (Anthropic) wrote the code, the build script, the icon and this text.
It replaces a SwiftBar script that was itself AI-written and is kept in `reference/`.

## What it shows

- 🟢 and the latency in ms when a real HTTPS request to Cloudflare succeeds quickly.
- 🟡 and the latency when it succeeds but slowly (connection above 200 ms, or the whole
  request above 1.5 s).
- 🔴 "offline" when it fails or takes more than 3 s.

It checks every 5 seconds against `https://1.1.1.1/cdn-cgi/trace`, by IP address, so a
broken DNS does not matter. Because the request is HTTPS, a captive portal (train or hotel
login page) cannot fake Cloudflare's certificate and correctly reads as offline, while a
ping would still answer. Clicking the dot shows the details, a "Run full speed test" item
(Apple's `networkQuality` in Terminal), "Refresh now", a "Launch at login" toggle and Quit.

## Install

The app is not signed or notarised, so the easiest trustworthy path is to build it
yourself. You need Apple's command-line developer tools (`xcode-select --install`).

```sh
git clone https://github.com/crisantibanez/online-or-offline.git
cd online-or-offline
./build.sh
```

That compiles the app, installs it in `~/Applications` for your user only, and starts it.
Drag it into the Dock from there if you want to launch it by hand; it has no Dock icon
while running, the dot in the menu bar is the running sign.

## Why so small

Swift and AppKit only, no dependencies, no Xcode project: one source file, one build script,
one icon. It uses no measurable CPU between checks and a few kilobytes of data per check.

## Licence

MIT, see `LICENSE`.
