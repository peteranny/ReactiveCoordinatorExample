//
//  HomeViewModel.swift
//  ReactiveCoordinatorExample
//
//  Created by Peteranny on 2024/7/13.
//

import Combine
import UIKit

enum HomeSteps: Step { // conform to the Step protocol
    // to start the Home page
    case launch(UIWindow)

    // to show the login page
    case showLogin(LoginViewModel)

    // to show the greet page
    case showGreet(GreetViewModel)
}

class HomeViewModel: StepProvider { // conform to StepProvider
    private let stepSubject = PassthroughSubject<Step, Never>()
    var stepPublisher: AnyPublisher<Step, Never> { stepSubject.eraseToAnyPublisher() }

    struct Input {
        let tapLoginButton: AnyPublisher<Void, Never>
        let tapLogoutButton: AnyPublisher<Void, Never>
        let tapGreetButton: AnyPublisher<Void, Never>
    }

    struct Output {
        let loginName: AnyPublisher<String?, Never>
    }

    // to bind the view controller
    func bind(_ input: Input, subscriptions: inout [AnyCancellable]) -> Output {

        let loginNameSubject = CurrentValueSubject<String?, Never>(nil)

        // map the input to a step
        // and emit to the step subject
        input.tapLoginButton
            .map {
                HomeSteps.showLogin(LoginViewModel(onLogin: { loginName in
                    loginNameSubject.send(loginName)
                    return GreetViewModel(loginName: loginName)
                }))
            }
            .subscribe(stepSubject)
            .store(in: &subscriptions)

        input.tapLogoutButton
            .map { nil }
            .subscribe(loginNameSubject)
            .store(in: &subscriptions)

        input.tapGreetButton
            .map { loginNameSubject.first() }
            .switchToLatest()
            .map { HomeSteps.showGreet(GreetViewModel(loginName: $0)) }
            .subscribe(stepSubject)
            .store(in: &subscriptions)

        return Output(
            loginName: loginNameSubject.eraseToAnyPublisher()
        )
    }
}
