//
//  NotificationViewController.swift
//  SmartTripNotificationExtension
//
//  Created by Yen-Chun Liu on 5/10/2026.
//

import UIKit
import UserNotifications
import UserNotificationsUI

class NotificationViewController: UIViewController, UNNotificationContentExtension {

    @IBOutlet var label: UILabel?

    private let brandLabel = UILabel()
    private let titleLabel = UILabel()
    private let tripContextLabel = UILabel()
    private let promptLabel = UILabel()
    private let destinationLabel = UILabel()

    override func viewDidLoad() {
        super.viewDidLoad()
        configureView()
    }

    func didReceive(_ notification: UNNotification) {
        let payload = JourneyCapsuleNotificationPayload(
            userInfo: notification.request.content.userInfo
        )
        apply(displayContent: JourneyCapsuleReminderDisplayContent(payload: payload))
    }

    private func configureView() {
        label?.isHidden = true

        view.backgroundColor = UIColor { traitCollection in
            traitCollection.userInterfaceStyle == .dark
                ? UIColor(red: 0.06, green: 0.09, blue: 0.10, alpha: 1.0)
                : UIColor(red: 0.96, green: 0.98, blue: 0.97, alpha: 1.0)
        }

        brandLabel.font = .systemFont(ofSize: 12, weight: .bold)
        brandLabel.textColor = UIColor(red: 0.09, green: 0.42, blue: 0.38, alpha: 1.0)
        brandLabel.text = "SMARTTRIP"
        brandLabel.adjustsFontForContentSizeCategory = true

        titleLabel.font = .preferredFont(forTextStyle: .headline)
        titleLabel.textColor = .label
        titleLabel.adjustsFontForContentSizeCategory = true
        titleLabel.numberOfLines = 1

        tripContextLabel.font = .preferredFont(forTextStyle: .subheadline)
        tripContextLabel.textColor = .secondaryLabel
        tripContextLabel.adjustsFontForContentSizeCategory = true
        tripContextLabel.numberOfLines = 1

        promptLabel.font = .preferredFont(forTextStyle: .body)
        promptLabel.textColor = .label
        promptLabel.adjustsFontForContentSizeCategory = true
        promptLabel.numberOfLines = 3

        destinationLabel.font = .preferredFont(forTextStyle: .caption1)
        destinationLabel.textColor = UIColor(red: 0.52, green: 0.30, blue: 0.15, alpha: 1.0)
        destinationLabel.adjustsFontForContentSizeCategory = true
        destinationLabel.numberOfLines = 1

        let stackView = UIStackView(
            arrangedSubviews: [
                brandLabel,
                titleLabel,
                tripContextLabel,
                promptLabel,
                destinationLabel
            ]
        )
        stackView.axis = .vertical
        stackView.alignment = .fill
        stackView.spacing = 6
        stackView.translatesAutoresizingMaskIntoConstraints = false

        view.addSubview(stackView)

        NSLayoutConstraint.activate([
            stackView.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 18),
            stackView.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -18),
            stackView.topAnchor.constraint(equalTo: view.topAnchor, constant: 14),
            stackView.bottomAnchor.constraint(lessThanOrEqualTo: view.bottomAnchor, constant: -14)
        ])

        preferredContentSize = CGSize(width: 0, height: 164)
        apply(displayContent: JourneyCapsuleReminderDisplayContent(payload: nil))
    }

    private func apply(
        displayContent: JourneyCapsuleReminderDisplayContent
    ) {
        titleLabel.text = displayContent.title
        tripContextLabel.text = displayContent.tripContext
        promptLabel.text = displayContent.prompt
        destinationLabel.text = displayContent.destination
        destinationLabel.isHidden = displayContent.destination == nil
    }
}

private struct JourneyCapsuleReminderDisplayContent {
    let title: String
    let tripContext: String
    let prompt: String
    let destination: String?

    init(
        payload: JourneyCapsuleNotificationPayload?
    ) {
        title = "Capture today's journey"
        prompt = payload?.promptText ?? JourneyCapsuleNotificationPayload.defaultPrompt
        destination = payload?.destination

        let tripName = payload?.tripName ?? "Your Trip"

        if let tripDay = payload?.tripDay {
            tripContext = "\(tripName) · Day \(tripDay)"
        } else {
            tripContext = tripName
        }
    }
}
