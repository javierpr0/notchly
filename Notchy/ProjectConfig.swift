import Foundation

/// Per-project configuration loaded from `.notchy.json` in the project root.
///
/// Example `.notchy.json`:
/// ```json
/// {
///   "shell": "/bin/bash",
///   "command": "npm run dev",
///   "env": {
///     "NODE_ENV": "development",
///     "PORT": "3000"
///   }
/// }
/// ```
struct ProjectConfig: Codable {
    var shell: String?
    var command: String?
    var env: [String: String]?

    static func load(from directory: String) -> ProjectConfig? {
        let path = (directory as NSString).appendingPathComponent(".notchy.json")
        guard let data = FileManager.default.contents(atPath: path) else { return nil }
        return try? JSONDecoder().decode(ProjectConfig.self, from: data)
    }
}
