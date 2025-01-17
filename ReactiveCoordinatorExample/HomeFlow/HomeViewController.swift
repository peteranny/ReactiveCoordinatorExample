//
//  HomeViewController.swift
//  ReactiveCoordinatorExample
//
//  Created by Peteranny on 2024/7/12.
//

import Combine
import CombineCocoa
import UIKit

class HomeViewController: UIViewController {
    let viewModel = HomeViewModel()

    override func viewDidLoad() {
        super.viewDidLoad()

        title = "Home"
        navigationController?.setNavigationBarHidden(false, animated: false)
        view.backgroundColor = .white

        let greetButton = UIButton()
        greetButton.setTitle("Greet", for: .normal)
        greetButton.setTitleColor(.blue, for: .normal)

        let loginButton = UIButton()
        loginButton.setTitle("Login", for: .normal)
        loginButton.setTitleColor(.blue, for: .normal)

        let logoutButton = UIButton()
        logoutButton.setTitle("Logout", for: .normal)
        logoutButton.setTitleColor(.red, for: .normal)

        let stackView = UIStackView(arrangedSubviews: [greetButton, loginButton, logoutButton])
        stackView.axis = .vertical
        stackView.alignment = .center
        stackView.distribution = .fillEqually
        stackView.frame = view.bounds
        view.addSubview(stackView)

        // install bindings

        let input = HomeViewModel.Input(
            tapLoginButton: loginButton.tapPublisher,
            tapLogoutButton: logoutButton.tapPublisher,
            tapGreetButton: greetButton.tapPublisher
        )

        let output = viewModel.bind(input, subscriptions: &subscriptions)

        output.loginName
            .map { $0 != nil }
            .assign(to: \.isHidden, on: loginButton)
            .store(in: &subscriptions)

        output.loginName
            .map { $0 == nil }
            .assign(to: \.isHidden, on: logoutButton)
            .store(in: &subscriptions)
    }

    private var subscriptions: [AnyCancellable] = []
}
