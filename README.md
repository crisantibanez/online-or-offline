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

## Download (no developer tools needed)

1. Download [Online-or-Offline.zip](https://github.com/crisantibanez/online-or-offline/releases/latest/download/Online-or-Offline.zip)
   and open it. You get the app and a "Read me first" note.
2. Move "Online or Offline" into your Applications folder and double-click it. Your Mac
   will say it could not verify the app. Click Done, not "Move to Trash".
3. Open System Settings, then Privacy & Security, scroll down to the Security section,
   click "Open Anyway" next to the line about Online or Offline, and confirm.
4. A green dot appears in your menu bar. From now on it opens normally. It never shows in
   the Dock while running; click the dot to see details, to quit, or to start it at login.

Why the extra steps: Apple only opens an app without questions when its maker pays for a
developer account and sends every version to Apple for checking ("notarisation"). This is a
free gift, not a product, so it is not notarised and your Mac treats it as unverified until
you say you trust it. The whole app is a few hundred lines of code, all visible here.

## Build it yourself

The alternative for people with Apple's command-line developer tools
(`xcode-select --install`): the Mac then trusts the app it built itself, with no warning.

```sh
git clone https://github.com/crisantibanez/online-or-offline.git
cd online-or-offline
./build.sh
```

That compiles the app, installs it in `~/Applications` for your user only, starts it, and
also produces the zip above in `build/`.

## Why so small

Swift and AppKit only, no dependencies, no Xcode project: one source file, one build script,
one icon. It uses no measurable CPU between checks and a few kilobytes of data per check.

## Licence

MIT, see `LICENSE`.
