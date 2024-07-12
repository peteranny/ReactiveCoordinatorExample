//
//  LoginViewController.swift
//  ReactiveCoordinatorExample
//
//  Created by Peteranny on 2024/7/12.
//

import Combine
import CombineCocoa
import UIKit

class LoginViewController: UIViewController {

    let viewModel: LoginViewModel
    init(viewModel: LoginViewModel) {
        self.viewModel = viewModel
        super.init(nibName: nil, bundle: nil)
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    override func viewDidLoad() {
        super.viewDidLoad()

        view.backgroundColor = .white

        let loginButton = UIButton()
        loginButton.setTitleColor(.blue, for: .normal)
        loginButton.frame = view.bounds
        view.addSubview(loginButton)

        // install bindings

        let input = LoginViewModel.Input(
            tapLoginButton: loginButton.tapPublisher
        )

        let output = viewModel.bind(input, subscriptions: &subscriptions)

        output.loginName
            .map { "Click To Login with: \($0)" }
            .sink { loginButton.setTitle($0, for: .normal) }
            .store(in: &subscriptions)
    }

    private var subscriptions: [AnyCancellable] = []

}
