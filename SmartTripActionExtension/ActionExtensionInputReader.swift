import Foundation
import UniformTypeIdentifiers

enum ActionExtensionInputReader {
    static func readInput(
        from context: NSExtensionContext?
    ) async throws -> ActionTravelInput {
        guard let extensionItems = context?.inputItems as? [NSExtensionItem] else {
            throw ActionInputError.noSupportedContent
        }

        var sourceURL: URL?
        var sharedText: String?
        var sourceTitle: String?

        for item in extensionItems {
            sourceTitle = sourceTitle ?? item.attributedTitle?.string.trimmedNonEmpty
            sharedText = sharedText ?? item.attributedContentText?.string.trimmedNonEmpty

            guard let attachments = item.attachments else {
                continue
            }

            for provider in attachments {
                if sourceURL == nil,
                   provider.hasItemConformingToTypeIdentifier(UTType.url.identifier) {
                    sourceURL = try await loadURL(from: provider)
                }

                if sharedText == nil,
                   provider.hasItemConformingToTypeIdentifier(UTType.plainText.identifier) {
                    sharedText = try await loadPlainText(from: provider)
                }

                if sourceURL != nil, sharedText != nil {
                    break
                }
            }

            if sourceURL != nil || sharedText != nil {
                break
            }
        }

        guard sourceURL != nil || sharedText != nil else {
            throw ActionInputError.noSupportedContent
        }

        return ActionTravelInput(
            sourceURL: sourceURL,
            sharedText: sharedText,
            sourceTitle: sourceTitle
        )
    }

    private static func loadURL(
        from provider: NSItemProvider
    ) async throws -> URL? {
        try await withCheckedThrowingContinuation { continuation in
            provider.loadItem(forTypeIdentifier: UTType.url.identifier) { item, error in
                if error != nil {
                    continuation.resume(throwing: ActionInputError.unableToReadContent)
                    return
                }

                if let url = item as? URL {
                    continuation.resume(returning: url)
                } else if let text = item as? String {
                    continuation.resume(returning: URL(string: text))
                } else {
                    continuation.resume(returning: nil)
                }
            }
        }
    }

    private static func loadPlainText(
        from provider: NSItemProvider
    ) async throws -> String? {
        try await withCheckedThrowingContinuation { continuation in
            provider.loadItem(forTypeIdentifier: UTType.plainText.identifier) { item, error in
                if error != nil {
                    continuation.resume(throwing: ActionInputError.unableToReadContent)
                    return
                }

                if let text = item as? String {
                    continuation.resume(returning: text.trimmedNonEmpty)
                } else if let data = item as? Data {
                    continuation.resume(returning: String(data: data, encoding: .utf8)?.trimmedNonEmpty)
                } else {
                    continuation.resume(returning: nil)
                }
            }
        }
    }
}

private extension String {
    var trimmedNonEmpty: String? {
        let trimmed = trimmingCharacters(in: .whitespacesAndNewlines)
        return trimmed.isEmpty ? nil : trimmed
    }
}
