import Foundation

enum AppleScriptError: Error {
    case runError(message: String)
}


struct AppleScript {
    static func run(myAppleScript: String) throws -> String  {
        var error: NSDictionary?

        if let result = NSAppleScript(source: myAppleScript)?.executeAndReturnError(&error).stringValue {
            return String(result)
        }

        if error != nil {
            print(error)
            throw AppleScriptError.runError(message: "Apple script run error")
        }
        
        return "Apple Script successfull"
    }
}
