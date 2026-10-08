// Online or Offline: a menu bar dot that says whether the internet really works.
// One HTTPS request to Cloudflare (by IP, so DNS does not matter) every few seconds.
// A captive portal cannot present Cloudflare's certificate, so it reads as offline.

import AppKit
import ServiceManagement

let probeURL = URL(string: "https://1.1.1.1/cdn-cgi/trace")!
let slowConnectMs = 200      // TCP connect above this => slow
let slowTotalMs = 1500       // whole request above this => slow
let timeoutSeconds = 3.0     // hard cap for the whole probe
let intervalSeconds = 5.0    // time between checks

enum State: String { case healthy, slow, offline }

struct Result {
    let state: State
    let connectMs: Int
    let totalMs: Int
    let detail: String
    let at: Date
}

// One probe = one fresh session, so every check measures a real new connection (like curl did).
final class Probe: NSObject, URLSessionDataDelegate {
    private let start = Date()
    private var status = 0
    private var connectMs = 0
    private var done: ((Result) -> Void)?

    static func run(_ done: @escaping (Result) -> Void) {
        let probe = Probe()
        probe.done = done
        let config = URLSessionConfiguration.ephemeral
        config.timeoutIntervalForRequest = timeoutSeconds
        config.timeoutIntervalForResource = timeoutSeconds
        config.waitsForConnectivity = false
        config.urlCache = nil
        config.requestCachePolicy = .reloadIgnoringLocalAndRemoteCacheData
        let session = URLSession(configuration: config, delegate: probe, delegateQueue: nil)
        session.dataTask(with: probeURL).resume()
        session.finishTasksAndInvalidate()
    }

    func urlSession(_ session: URLSession, dataTask: URLSessionDataTask, didReceive response: URLResponse,
                    completionHandler: @escaping (URLSession.ResponseDisposition) -> Void) {
        status = (response as? HTTPURLResponse)?.statusCode ?? 0
        completionHandler(.allow)
    }

    func urlSession(_ session: URLSession, task: URLSessionTask, didFinishCollecting metrics: URLSessionTaskMetrics) {
        for t in metrics.transactionMetrics {
            if let begin = t.connectStartDate, let end = t.secureConnectionStartDate ?? t.connectEndDate {
                connectMs = Int(end.timeIntervalSince(begin) * 1000)
            }
        }
    }

    func urlSession(_ session: URLSession, task: URLSessionTask, didCompleteWithError error: Error?) {
        let totalMs = Int(Date().timeIntervalSince(start) * 1000)
        let state: State
        let detail: String
        if let error = error {
            state = .offline
            detail = (error as NSError).code == NSURLErrorTimedOut
                ? "No HTTPS reply within \(Int(timeoutSeconds)) s"
                : error.localizedDescription
        } else if status != 200 {
            state = .offline
            detail = "Unexpected HTTP \(status)"
        } else {
            state = (connectMs > slowConnectMs || totalMs > slowTotalMs) ? .slow : .healthy
            detail = "Connect \(connectMs) ms  ·  full request \(totalMs) ms"
        }
        let result = Result(state: state, connectMs: connectMs, totalMs: totalMs, detail: detail, at: Date())
        DispatchQueue.main.async { self.done?(result) }
    }
}

final class App: NSObject, NSApplicationDelegate {
    private let item = NSStatusBar.system.statusItem(withLength: NSStatusItem.variableLength)
    private let menu = NSMenu()
    private var checking = false
    private var last: Result?

    func applicationDidFinishLaunching(_ note: Notification) {
        item.button?.title = "⚪️ …"
        item.menu = menu
        menu.delegate = self
        check()
        let timer = Timer.scheduledTimer(withTimeInterval: intervalSeconds, repeats: true) { [weak self] _ in self?.check() }
        timer.tolerance = 1
    }

    @objc func check() {
        if checking { return }
        checking = true
        Probe.run { [weak self] result in
            guard let self = self else { return }
            self.checking = false
            self.last = result
            switch result.state {
            case .healthy: self.item.button?.title = "🟢 \(result.connectMs)ms"
            case .slow:    self.item.button?.title = "🟡 \(result.connectMs)ms"
            case .offline: self.item.button?.title = "🔴 offline"
            }
        }
    }

    @objc func speedTest() {
        let script = "tell application \"Terminal\"\nactivate\ndo script \"networkQuality -v\"\nend tell"
        NSAppleScript(source: script)?.executeAndReturnError(nil)
    }

    @objc func toggleLaunchAtLogin() {
        let service = SMAppService.mainApp
        do {
            if service.status == .enabled { try service.unregister() } else { try service.register() }
        } catch {
            NSAlert(error: error).runModal()
        }
    }

    @objc func quit() { NSApp.terminate(nil) }
}

extension App: NSMenuDelegate {
    func menuNeedsUpdate(_ menu: NSMenu) {
        menu.removeAllItems()
        let time = DateFormatter()
        time.timeStyle = .medium
        if let r = last {
            menu.addItem(label("Status: \(r.state.rawValue)"))
            menu.addItem(label(r.detail))
            menu.addItem(label("Last check: \(time.string(from: r.at))"))
        } else {
            menu.addItem(label("Checking…"))
        }
        menu.addItem(.separator())
        menu.addItem(NSMenuItem(title: "Run full speed test", action: #selector(speedTest), keyEquivalent: ""))
        menu.addItem(NSMenuItem(title: "Refresh now", action: #selector(check), keyEquivalent: "r"))
        let login = NSMenuItem(title: "Launch at login", action: #selector(toggleLaunchAtLogin), keyEquivalent: "")
        login.state = SMAppService.mainApp.status == .enabled ? .on : .off
        menu.addItem(login)
        menu.addItem(.separator())
        menu.addItem(NSMenuItem(title: "Quit", action: #selector(quit), keyEquivalent: "q"))
        for entry in menu.items { entry.target = self }
    }

    private func label(_ text: String) -> NSMenuItem {
        let entry = NSMenuItem(title: text, action: nil, keyEquivalent: "")
        entry.isEnabled = false
        return entry
    }
}

let app = NSApplication.shared
let delegate = App()
app.delegate = delegate
app.setActivationPolicy(.accessory)
app.run()
