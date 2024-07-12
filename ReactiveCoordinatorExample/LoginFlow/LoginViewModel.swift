//
//  LoginViewModel.swift
//  ReactiveCoordinatorExample
//
//  Created by Peteranny on 2024/7/13.
//

import Combine
import UIKit

enum LoginSteps: Step { // conform to the Step protocol
    // to start the Login page
    case launch(LoginViewModel, root: UIViewController)

    // to login
    case login(toOpen: SettingsViewModel)
}

class LoginViewModel: StepProvider { // conform to StepProvider
    private let stepSubject = PassthroughSubject<Step, Never>()
    var stepPublisher: AnyPublisher<Step, Never> { stepSubject.eraseToAnyPublisher() }

    let onLogin: (String) -> SettingsViewModel
    init(onLogin: @escaping (String) -> SettingsViewModel) {
        self.onLogin = onLogin
    }

    struct Input {
        let tapLoginButton: AnyPublisher<Void, Never>
    }

    struct Output {
        let loginName: AnyPublisher<String, Never>
    }

    // to bind the view controller
    func bind(_ input: Input, subscriptions: inout [AnyCancellable]) -> Output {

        let loginName = Just("World")

        // map the input to a step
        // and emit to the step subject
        input.tapLoginButton
            .map { loginName.first() }
            .switchToLatest()
            .map(onLogin)
            .map { LoginSteps.login(toOpen: $0) }
            .subscribe(stepSubject)
            .store(in: &subscriptions)

        return Output(
            loginName: loginName.eraseToAnyPublisher()
        )
    }
}
