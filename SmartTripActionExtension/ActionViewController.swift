//
//  ActionViewController.swift
//  SmartTripActionExtension
//
//  Created by Yen-Chun Liu on 5/10/2026.
//

import UIKit

class ActionViewController: UIViewController {

    @IBOutlet weak var imageView: UIImageView!
    private let processor: any TravelContentProcessing = TravelContentProcessor()
    private let statusLabel = UILabel()
    private let detailLabel = UILabel()

    override func viewDidLoad() {
        super.viewDidLoad()

        imageView.isHidden = true
        configurePlaceholderState()
        loadSharedContent()
    }

    @IBAction func done() {
        // Return any edited content to the host app.
        // This template doesn't do anything, so we just echo the passed in items.
        self.extensionContext!.completeRequest(returningItems: self.extensionContext!.inputItems, completionHandler: nil)
    }

    private func configurePlaceholderState() {
        statusLabel.text = "SmartTrip Travel Discovery"
        statusLabel.textAlignment = .center
        statusLabel.font = .preferredFont(forTextStyle: .headline)
        statusLabel.textColor = .label
        statusLabel.translatesAutoresizingMaskIntoConstraints = false

        detailLabel.text = "Reading shared travel content..."
        detailLabel.textAlignment = .center
        detailLabel.font = .preferredFont(forTextStyle: .body)
        detailLabel.textColor = .secondaryLabel
        detailLabel.numberOfLines = 0
        detailLabel.translatesAutoresizingMaskIntoConstraints = false

        view.addSubview(statusLabel)
        view.addSubview(detailLabel)

        NSLayoutConstraint.activate([
            statusLabel.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            statusLabel.centerYAnchor.constraint(equalTo: view.centerYAnchor, constant: -32),
            statusLabel.leadingAnchor.constraint(greaterThanOrEqualTo: view.leadingAnchor, constant: 24),
            statusLabel.trailingAnchor.constraint(lessThanOrEqualTo: view.trailingAnchor, constant: -24),

            detailLabel.topAnchor.constraint(equalTo: statusLabel.bottomAnchor, constant: 16),
            detailLabel.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 24),
            detailLabel.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -24)
        ])
    }

    private func loadSharedContent() {
        Task { @MainActor in
            do {
                let input = try await ActionExtensionInputReader.readInput(
                    from: extensionContext
                )
                let result = try await processor.process(input)
                show(result)
            } catch {
                show(error)
            }
        }
    }

    private func show(
        _ result: TravelDiscoveryResult
    ) {
        statusLabel.text = result.placeName ?? "Travel discovery ready"

        let locationLine = result.location.map { "Location: \($0)" }
        let recommendationLine: String?
        if result.recommendations.isEmpty {
            recommendationLine = nil
        } else {
            recommendationLine = "Related: " + result.recommendations
                .map(\.name)
                .joined(separator: ", ")
        }

        detailLabel.text = [
            locationLine,
            result.summary,
            recommendationLine
        ]
        .compactMap { $0 }
        .joined(separator: "\n\n")
    }

    private func show(
        _ error: Error
    ) {
        let localizedError = error as? any LocalizedError
        statusLabel.text = "Nothing to process"
        detailLabel.text = localizedError?.errorDescription ?? "SmartTrip could not process this shared content."
    }

}
