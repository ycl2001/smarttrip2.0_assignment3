//
//  ActionViewController.swift
//  SmartTripActionExtension
//
//  Created by Yen-Chun Liu on 5/10/2026.
//

import UIKit
import UniformTypeIdentifiers

class ActionViewController: UIViewController {

    @IBOutlet weak var imageView: UIImageView!
    private let processor: any TravelContentProcessing = TravelContentProcessor(
        recommendationProvider: MapKitTravelRecommendationService()
    )
    private let formatter = TravelDiscoveryFormatter()
    private var loadTask: Task<Void, Never>?
    private var currentResult: TravelDiscoveryResult?
    private var visibleRecommendations: [TravelRecommendation] = []
    private var isCompleting = false

    private let scrollView = UIScrollView()
    private let stackView = UIStackView()
    private let statusLabel = UILabel()
    private let placeField = UITextField()
    private let locationField = UITextField()
    private let summaryTextView = UITextView()
    private let recommendationsSection = UIStackView()
    private let sourceLabel = UILabel()
    private let errorLabel = UILabel()
    private var doneButton: UIBarButtonItem?
    private var cancelButton: UIBarButtonItem?

    override func viewDidLoad() {
        super.viewDidLoad()

        imageView.isHidden = true
        configureNavigationItems()
        configureReviewUI()
        showLoadingState()
        loadSharedContent()
    }

    @IBAction func done() {
        guard !isCompleting else {
            return
        }

        guard var result = currentResult else {
            completeWithoutReturnedContent()
            return
        }

        result.placeName = placeField.text?.trimmedNonEmpty
        result.location = locationField.text?.trimmedNonEmpty
        result.summary = summaryTextView.text.trimmedNonEmpty ?? result.summary
        result.recommendations = visibleRecommendations

        let formattedText = formatter.format(result)
        let item = NSExtensionItem()
        var attachments = [
            NSItemProvider(item: formattedText as NSString, typeIdentifier: UTType.plainText.identifier)
        ]

        if let sourceURL = result.sourceURL {
            attachments.append(
                NSItemProvider(item: sourceURL as NSURL, typeIdentifier: UTType.url.identifier)
            )
        }

        item.attachments = attachments
        complete(returningItems: [item])
    }

    @objc private func cancel() {
        guard !isCompleting else {
            return
        }

        loadTask?.cancel()
        let error = NSError(
            domain: NSCocoaErrorDomain,
            code: NSUserCancelledError,
            userInfo: nil
        )
        isCompleting = true
        extensionContext?.cancelRequest(withError: error)
    }

    private func configureNavigationItems() {
        cancelButton = UIBarButtonItem(
            title: "Cancel",
            style: .plain,
            target: self,
            action: #selector(cancel)
        )
        let doneStyle: UIBarButtonItem.Style
        if #available(iOS 26.0, *) {
            doneStyle = .prominent
        } else {
            doneStyle = .done
        }
        doneButton = UIBarButtonItem(
            title: "Done",
            style: doneStyle,
            target: self,
            action: #selector(done)
        )
        doneButton?.isEnabled = false

        if let navigationBar = view.subviews.compactMap({ $0 as? UINavigationBar }).first {
            let item = navigationBar.topItem ?? UINavigationItem(title: "SmartTrip Discovery")
            item.title = "SmartTrip Discovery"
            item.leftBarButtonItem = cancelButton
            item.rightBarButtonItem = doneButton

            if navigationBar.topItem == nil {
                navigationBar.setItems([item], animated: false)
            }
        } else {
            navigationItem.title = "SmartTrip Discovery"
            navigationItem.leftBarButtonItem = cancelButton
            navigationItem.rightBarButtonItem = doneButton
        }
    }

    private func configureReviewUI() {
        scrollView.translatesAutoresizingMaskIntoConstraints = false
        scrollView.keyboardDismissMode = .interactive

        stackView.axis = .vertical
        stackView.spacing = 16
        stackView.translatesAutoresizingMaskIntoConstraints = false

        statusLabel.font = .preferredFont(forTextStyle: .headline)
        statusLabel.textColor = .label
        statusLabel.numberOfLines = 0
        statusLabel.accessibilityTraits = .header

        placeField.borderStyle = .roundedRect
        placeField.placeholder = "Add a place or travel topic"
        placeField.textContentType = .location
        placeField.clearButtonMode = .whileEditing
        placeField.accessibilityLabel = "Place"

        locationField.borderStyle = .roundedRect
        locationField.placeholder = "Add a location"
        locationField.textContentType = .location
        locationField.clearButtonMode = .whileEditing
        locationField.accessibilityLabel = "Location"

        summaryTextView.font = .preferredFont(forTextStyle: .body)
        summaryTextView.layer.borderColor = UIColor.separator.cgColor
        summaryTextView.layer.borderWidth = 1
        summaryTextView.layer.cornerRadius = 8
        summaryTextView.textContainerInset = UIEdgeInsets(top: 10, left: 8, bottom: 10, right: 8)
        summaryTextView.isScrollEnabled = false
        summaryTextView.accessibilityLabel = "Travel summary"

        recommendationsSection.axis = .vertical
        recommendationsSection.spacing = 8

        sourceLabel.font = .preferredFont(forTextStyle: .footnote)
        sourceLabel.textColor = .secondaryLabel
        sourceLabel.numberOfLines = 3
        sourceLabel.accessibilityLabel = "Source"

        errorLabel.font = .preferredFont(forTextStyle: .body)
        errorLabel.textColor = .secondaryLabel
        errorLabel.numberOfLines = 0
        errorLabel.isHidden = true

        view.addSubview(scrollView)
        scrollView.addSubview(stackView)

        stackView.addArrangedSubview(statusLabel)
        stackView.addArrangedSubview(labeledView(title: "Place", view: placeField))
        stackView.addArrangedSubview(labeledView(title: "Location", view: locationField))
        stackView.addArrangedSubview(labeledView(title: "Summary", view: summaryTextView))
        stackView.addArrangedSubview(labeledView(title: "Related Places", view: recommendationsSection))
        stackView.addArrangedSubview(labeledView(title: "Source", view: sourceLabel))
        stackView.addArrangedSubview(errorLabel)

        let navigationBar = view.subviews.compactMap { $0 as? UINavigationBar }.first
        let topAnchor = navigationBar?.bottomAnchor ?? view.safeAreaLayoutGuide.topAnchor

        NSLayoutConstraint.activate([
            scrollView.topAnchor.constraint(equalTo: topAnchor),
            scrollView.leadingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.leadingAnchor),
            scrollView.trailingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.trailingAnchor),
            scrollView.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor),

            stackView.topAnchor.constraint(equalTo: scrollView.contentLayoutGuide.topAnchor, constant: 20),
            stackView.leadingAnchor.constraint(equalTo: scrollView.contentLayoutGuide.leadingAnchor, constant: 20),
            stackView.trailingAnchor.constraint(equalTo: scrollView.contentLayoutGuide.trailingAnchor, constant: -20),
            stackView.bottomAnchor.constraint(equalTo: scrollView.contentLayoutGuide.bottomAnchor, constant: -20),
            stackView.widthAnchor.constraint(equalTo: scrollView.frameLayoutGuide.widthAnchor, constant: -40),

            summaryTextView.heightAnchor.constraint(greaterThanOrEqualToConstant: 120)
        ])
    }

    private func labeledView(
        title: String,
        view: UIView
    ) -> UIView {
        let container = UIStackView()
        container.axis = .vertical
        container.spacing = 6

        let label = UILabel()
        label.text = title
        label.font = .preferredFont(forTextStyle: .subheadline)
        label.textColor = .secondaryLabel

        container.addArrangedSubview(label)
        container.addArrangedSubview(view)
        return container
    }

    private func showLoadingState() {
        currentResult = nil
        visibleRecommendations = []
        statusLabel.text = "Preparing travel discovery..."
        placeField.text = nil
        locationField.text = nil
        summaryTextView.text = nil
        placeField.isEnabled = false
        locationField.isEnabled = false
        summaryTextView.isEditable = false
        sourceLabel.text = nil
        errorLabel.isHidden = true
        doneButton?.isEnabled = false
        renderRecommendations([])
    }

    private func loadSharedContent() {
        loadTask = Task { @MainActor in
            do {
                let input = try await ActionExtensionInputReader.readInput(
                    from: extensionContext
                )
                let result = try await processor.process(input)
                guard !Task.isCancelled, !isCompleting else {
                    return
                }

                show(result)
            } catch is CancellationError {
                return
            } catch {
                guard !Task.isCancelled, !isCompleting else {
                    return
                }

                show(error)
            }
        }
    }

    private func show(
        _ result: TravelDiscoveryResult
    ) {
        currentResult = result
        visibleRecommendations = result.recommendations
        statusLabel.text = "Review your travel discovery"
        placeField.text = result.placeName
        locationField.text = result.location
        summaryTextView.text = result.summary
        sourceLabel.text = result.sourceURL?.absoluteString ?? "No source URL provided"
        errorLabel.isHidden = true

        placeField.isEnabled = true
        locationField.isEnabled = true
        summaryTextView.isEditable = true
        doneButton?.isEnabled = true
        renderRecommendations(result.recommendations)
    }

    private func show(
        _ error: Error
    ) {
        let localizedError = error as? any LocalizedError
        currentResult = nil
        visibleRecommendations = []
        statusLabel.text = "Nothing to process"
        placeField.text = nil
        locationField.text = nil
        summaryTextView.text = nil
        errorLabel.text = localizedError?.errorDescription
            ?? "SmartTrip could not find enough travel information to prepare this content."
        errorLabel.isHidden = false
        placeField.isEnabled = false
        locationField.isEnabled = false
        summaryTextView.isEditable = false
        sourceLabel.text = nil
        doneButton?.isEnabled = true
        renderRecommendations([])
    }

    private func renderRecommendations(
        _ recommendations: [TravelRecommendation]
    ) {
        recommendationsSection.arrangedSubviews.forEach { view in
            recommendationsSection.removeArrangedSubview(view)
            view.removeFromSuperview()
        }

        guard !recommendations.isEmpty else {
            let label = UILabel()
            label.text = "No related places found"
            label.font = .preferredFont(forTextStyle: .footnote)
            label.textColor = .secondaryLabel
            recommendationsSection.addArrangedSubview(label)
            return
        }

        recommendations.forEach { recommendation in
            recommendationsSection.addArrangedSubview(
                recommendationRow(for: recommendation)
            )
        }
    }

    private func recommendationRow(
        for recommendation: TravelRecommendation
    ) -> UIView {
        let container = UIStackView()
        container.axis = .horizontal
        container.alignment = .center
        container.spacing = 8
        container.isLayoutMarginsRelativeArrangement = true
        container.directionalLayoutMargins = NSDirectionalEdgeInsets(
            top: 10,
            leading: 12,
            bottom: 10,
            trailing: 8
        )
        container.layer.cornerRadius = 8
        container.layer.borderColor = UIColor.separator.cgColor
        container.layer.borderWidth = 1

        let textStack = UIStackView()
        textStack.axis = .vertical
        textStack.spacing = 2

        let titleLabel = UILabel()
        titleLabel.text = recommendation.name
        titleLabel.font = .preferredFont(forTextStyle: .body)
        titleLabel.numberOfLines = 0

        let detailLabel = UILabel()
        detailLabel.text = [
            recommendation.subtitle,
            recommendation.category
        ]
        .compactMap { $0?.trimmedNonEmpty }
        .joined(separator: " • ")
        detailLabel.font = .preferredFont(forTextStyle: .footnote)
        detailLabel.textColor = .secondaryLabel
        detailLabel.numberOfLines = 0

        textStack.addArrangedSubview(titleLabel)
        if detailLabel.text?.isEmpty == false {
            textStack.addArrangedSubview(detailLabel)
        }

        let removeButton = UIButton(type: .system)
        removeButton.setImage(UIImage(systemName: "xmark.circle.fill"), for: .normal)
        removeButton.tintColor = .secondaryLabel
        removeButton.accessibilityLabel = "Remove \(recommendation.name)"
        removeButton.addAction(
            UIAction { [weak self] _ in
                self?.removeRecommendation(recommendation)
            },
            for: .touchUpInside
        )

        container.addArrangedSubview(textStack)
        container.addArrangedSubview(removeButton)
        textStack.setContentHuggingPriority(.defaultLow, for: .horizontal)
        removeButton.setContentHuggingPriority(.required, for: .horizontal)
        return container
    }

    private func removeRecommendation(
        _ recommendation: TravelRecommendation
    ) {
        visibleRecommendations.removeAll { $0.id == recommendation.id }
        renderRecommendations(visibleRecommendations)
    }

    private func completeWithoutReturnedContent() {
        complete(returningItems: nil)
    }

    private func complete(
        returningItems items: [NSExtensionItem]?
    ) {
        isCompleting = true
        doneButton?.isEnabled = false
        cancelButton?.isEnabled = false
        loadTask?.cancel()
        extensionContext?.completeRequest(returningItems: items, completionHandler: nil)
    }

}

private extension String {
    var trimmedNonEmpty: String? {
        let trimmed = trimmingCharacters(in: .whitespacesAndNewlines)
        return trimmed.isEmpty ? nil : trimmed
    }
}
