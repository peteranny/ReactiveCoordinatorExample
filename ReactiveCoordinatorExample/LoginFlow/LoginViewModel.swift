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
    case login((String) -> Void)

    // to have logged in
    case loggedIn(toOpen: GreetViewModel)
}

class LoginViewModel: StepProvider { // conform to StepProvider
    private let stepSubject = PassthroughSubject<Step, Never>()
    var stepPublisher: AnyPublisher<Step, Never> { stepSubject.eraseToAnyPublisher() }

    let onLogin: (String) -> GreetViewModel
    init(onLogin: @escaping (String) -> GreetViewModel) {
        self.onLogin = onLogin
    }

    struct Input {
        let tapLoginButton: AnyPublisher<Void, Never>
    }

    // to bind the view controller
    func bind(_ input: Input, subscriptions: inout [AnyCancellable]) {

        let loginNameSubject = PassthroughSubject<String, Never>()

        // map the input to a step
        // and emit to the step subject
        input.tapLoginButton
            .map { LoginSteps.login { loginNameSubject.send($0) } }
            .subscribe(stepSubject)
            .store(in: &subscriptions)

        loginNameSubject
            .map { [onLogin] in LoginSteps.loggedIn(toOpen: onLogin($0)) }
            .subscribe(stepSubject)
            .store(in: &subscriptions)
    }
}
