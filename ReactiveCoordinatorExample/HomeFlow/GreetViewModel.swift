//
//  GreetViewModel.swift
//  ReactiveCoordinatorExample
//
//  Created by Peteranny on 2024/7/13.
//

import Combine
import UIKit

enum GreetSteps: Step { // conform to the Step protocol
    // to open the version alert
    case showVersion(String)
}

class GreetViewModel: StepProvider { // conform to StepProvider
    private let stepSubject = PassthroughSubject<Step, Never>()
    var stepPublisher: AnyPublisher<Step, Never> { stepSubject.eraseToAnyPublisher() }

    let loginName: String?
    init(loginName: String?) {
        self.loginName = loginName
    }

    struct Input {
        let tapVersionButton: AnyPublisher<Void, Never>
    }

    struct Output {
        let name: AnyPublisher<String?, Never>
    }

    // to bind the view controller
    func bind(_ input: Input, subscriptions: inout [AnyCancellable]) -> Output {

        // map the input to a step
        // and emit to the step subject
        input.tapVersionButton
            .map { GreetSteps.showVersion("1.0.0") }
            .subscribe(stepSubject)
            .store(in: &subscriptions)

        return Output(
            name: Just(loginName).eraseToAnyPublisher()
        )
    }
}
