import Foundation

/// Lightweight, env-gated logger used to investigate the TUI scrollback duplication bug.
/// Set `ZION_TUI_DEBUG=1` in the process environment to enable. Output appended to
/// `~/Library/Logs/Zion/swiftterm-tui.log`, falling back to `/tmp/zion-swiftterm-tui.log`.
///
/// Remove or guard calls before shipping releases — this is strictly diagnostic.
enum TuiDebug {
    static let isEnabled: Bool = {
        ProcessInfo.processInfo.environment["ZION_TUI_DEBUG"] == "1"
    }()

    private static let queue = DispatchQueue(label: "swiftterm.tui-debug")
    private static let formatter: DateFormatter = {
        let f = DateFormatter()
        f.dateFormat = "HH:mm:ss.SSS"
        return f
    }()

    private static let handle: FileHandle? = {
        guard isEnabled else { return nil }
        let fm = FileManager.default
        let home = fm.homeDirectoryForCurrentUser
        let dir = home.appendingPathComponent("Library/Logs/Zion", isDirectory: true)
        var logURL = dir.appendingPathComponent("swiftterm-tui.log")
        do {
            try fm.createDirectory(at: dir, withIntermediateDirectories: true)
        } catch {
            logURL = URL(fileURLWithPath: "/tmp/zion-swiftterm-tui.log")
        }
        if !fm.fileExists(atPath: logURL.path) {
            fm.createFile(atPath: logURL.path, contents: nil)
        }
        let h = try? FileHandle(forWritingTo: logURL)
        h?.seekToEndOfFile()
        let banner = "---- TuiDebug start pid=\(ProcessInfo.processInfo.processIdentifier) \(Date()) ----\n"
        if let data = banner.data(using: .utf8) { h?.write(data) }
        return h
    }()

    @inline(__always)
    static func log(_ tag: String, _ payload: @autoclosure () -> String) {
        guard isEnabled, let h = handle else { return }
        let ts = formatter.string(from: Date())
        let line = "\(ts) [\(tag)] \(payload())\n"
        queue.async {
            if let data = line.data(using: .utf8) { h.write(data) }
        }
    }
}
