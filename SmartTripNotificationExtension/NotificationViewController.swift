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
    private let contextLabel = UILabel()
    private let promptLabel = UILabel()

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

        brandLabel.font = .systemFont(ofSize: 11, weight: .bold)
        brandLabel.textColor = UIColor(red: 0.09, green: 0.42, blue: 0.38, alpha: 1.0)
        brandLabel.text = "JOURNEY CAPSULE"
        brandLabel.adjustsFontForContentSizeCategory = true

        contextLabel.font = .preferredFont(forTextStyle: .subheadline)
        contextLabel.textColor = .secondaryLabel
        contextLabel.adjustsFontForContentSizeCategory = true
        contextLabel.numberOfLines = 1

        promptLabel.font = .preferredFont(forTextStyle: .subheadline)
        promptLabel.textColor = .label
        promptLabel.adjustsFontForContentSizeCategory = true
        promptLabel.numberOfLines = 2

        let stackView = UIStackView(
            arrangedSubviews: [
                brandLabel,
                contextLabel,
                promptLabel
            ]
        )
        stackView.axis = .vertical
        stackView.alignment = .fill
        stackView.spacing = 4
        stackView.translatesAutoresizingMaskIntoConstraints = false

        view.addSubview(stackView)

        NSLayoutConstraint.activate([
            stackView.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 18),
            stackView.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -18),
            stackView.topAnchor.constraint(equalTo: view.topAnchor, constant: 12),
            stackView.bottomAnchor.constraint(lessThanOrEqualTo: view.bottomAnchor, constant: -12)
        ])

        preferredContentSize = CGSize(width: 0, height: 96)
        apply(displayContent: JourneyCapsuleReminderDisplayContent(payload: nil))
    }

    private func apply(
        displayContent: JourneyCapsuleReminderDisplayContent
    ) {
        contextLabel.text = displayContent.context
        contextLabel.isHidden = displayContent.context == nil
        promptLabel.text = displayContent.prompt
    }
}

private struct JourneyCapsuleReminderDisplayContent {
    let context: String?
    let prompt: String

    init(
        payload: JourneyCapsuleNotificationPayload?
    ) {
        context = payload?.destination.map { "Today in \($0)" }
        prompt = "Save a place, thought, or moment while it's still fresh."
    }
}
