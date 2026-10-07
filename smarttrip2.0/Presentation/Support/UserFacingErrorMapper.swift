import Foundation

enum UserFacingErrorMapper {
    static func message(for error: Error, fallback: String) -> String {
        let localizedError = error as? any LocalizedError
        return localizedError?.errorDescription ?? fallback
    }

    static func recoverySuggestion(for error: Error) -> String? {
        let localizedError = error as? any LocalizedError
        return localizedError?.recoverySuggestion ?? "Try again."
    }
}
