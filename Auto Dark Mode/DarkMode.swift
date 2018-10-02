import Foundation

struct DarkMode {
    private static let command = "tell application id \"com.apple.systemevents\" to tell appearance preferences to set dark mode to "

    static var isEnabled: Bool {
        return UserDefaults.standard.string(forKey: "AppleInterfaceStyle") == "Dark"
    }

    static func toggle(_force: Bool? = nil) -> Bool {
        let flag = _force.map(String.init) ?? String(!isEnabled)
        let script = command + flag
        return AppleScript.run(myAppleScript: script)
    }
}
