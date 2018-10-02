import Foundation

struct DarkMode {
    private static let command = "tell application id \"com.apple.systemevents\" to tell appearance preferences to set dark mode to "

    static var isEnabled: Bool {
        return UserDefaults.standard.string(forKey: "AppleInterfaceStyle") == "Dark"
    }

    static func toggle(_flag: Bool) {
        let script = "\(command)\(_flag)"
        let _ = runAppleScript(myAppleScript: script)
    }
}

func runAppleScript(myAppleScript: String) ->Bool {
    var error: NSDictionary?
    let result = NSAppleScript(source: myAppleScript)?.executeAndReturnError(&error).stringValue

    if result == nil {
        print(error)
        return false
    }

    print(result)
    return true
}
