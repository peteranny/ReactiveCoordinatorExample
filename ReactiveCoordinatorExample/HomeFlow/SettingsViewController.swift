//
//  SettingsViewController.swift
//  ReactiveCoordinatorExample
//
//  Created by Peteranny on 2024/7/12.
//

import Combine
import CombineCocoa
import UIKit

class SettingsViewController: UIViewController {

    let viewModel: SettingsViewModel
    init(viewModel: SettingsViewModel) {
        self.viewModel = viewModel
        super.init(nibName: nil, bundle: nil)
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    override func viewDidLoad() {
        super.viewDidLoad()

        title = "Settings"
        view.backgroundColor = .white

        let greetLabel = UILabel()
        greetLabel.textAlignment = .center
        greetLabel.frame = view.bounds
        view.addSubview(greetLabel)

        let versionButton = UIBarButtonItem(title: "Version", style: .plain, target: nil, action: nil)
        navigationItem.rightBarButtonItem = versionButton

        // install bindings

        let input = SettingsViewModel.Input(
            tapVersionButton: versionButton.tapPublisher
        )

        let output = viewModel.bind(input, subscriptions: &subscriptions)

        output.name
            .map { name in
                if let name {
                    "Hello, \(name)!"
                } else {
                    "You have not logged in yet"
                }
            }
            .assign(to: \.text, on: greetLabel)
            .store(in: &subscriptions)
    }

    private var subscriptions: [AnyCancellable] = []
}
