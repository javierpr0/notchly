import Foundation

class SessionHistoryManager {
    static let shared = SessionHistoryManager()

    private let baseDir: URL = {
        let home = FileManager.default.homeDirectoryForCurrentUser
        return home.appendingPathComponent(".notchly/history")
    }()

    private let queue = DispatchQueue(label: "com.notchly.SessionHistory")
    private let maxFileSize: UInt64 = 5 * 1024 * 1024
    private let keepSize = 3 * 1024 * 1024

    private init() {
        try? FileManager.default.createDirectory(at: baseDir, withIntermediateDirectories: true)
    }

    func logPath(for sessionId: UUID) -> URL {
        baseDir.appendingPathComponent("\(sessionId.uuidString).log")
    }

    func appendText(_ text: String, for sessionId: UUID) {
        guard !text.isEmpty else { return }
        queue.async { [self] in
            let path = logPath(for: sessionId)
            guard let data = text.data(using: .utf8) else { return }
            if FileManager.default.fileExists(atPath: path.path) {
                if let handle = try? FileHandle(forWritingTo: path) {
                    handle.seekToEndOfFile()
                    handle.write(data)
                    handle.closeFile()
                }
            } else {
                try? data.write(to: path)
            }
            rotateIfNeeded(at: path)
        }
    }

    func readHistory(for sessionId: UUID) -> String {
        let path = logPath(for: sessionId)
        let raw = (try? String(contentsOf: path, encoding: .utf8)) ?? ""
        return Self.stripAnsi(raw)
    }

    func deleteHistory(for sessionId: UUID) {
        queue.async { [self] in
            try? FileManager.default.removeItem(at: logPath(for: sessionId))
        }
    }

    private func rotateIfNeeded(at path: URL) {
        guard let attrs = try? FileManager.default.attributesOfItem(atPath: path.path),
              let size = attrs[.size] as? UInt64,
              size > maxFileSize else { return }
        guard let data = try? Data(contentsOf: path) else { return }
        let keepFrom = data.count - keepSize
        guard keepFrom > 0 else { return }
        let tail = data.suffix(from: keepFrom)
        if let nl = tail.firstIndex(of: UInt8(ascii: "\n")) {
            let clean = tail.suffix(from: tail.index(after: nl))
            try? clean.write(to: path)
        }
    }

    static func stripAnsi(_ text: String) -> String {
        var result = text
        // CSI sequences: ESC [ ... letter
        result = result.replacingOccurrences(of: "\\x1b\\[[0-9;?]*[a-zA-Z]", with: "", options: .regularExpression)
        // OSC sequences: ESC ] ... BEL or ST
        result = result.replacingOccurrences(of: "\\x1b\\][^\u{07}\u{1b}]*[\u{07}]", with: "", options: .regularExpression)
        result = result.replacingOccurrences(of: "\\x1b\\][^\u{07}\u{1b}]*\\x1b\\\\", with: "", options: .regularExpression)
        // Single ESC + character
        result = result.replacingOccurrences(of: "\\x1b[()][AB012]", with: "", options: .regularExpression)
        // Bare ESC sequences
        result = result.replacingOccurrences(of: "\\x1b[>=]", with: "", options: .regularExpression)
        return result
    }
}
