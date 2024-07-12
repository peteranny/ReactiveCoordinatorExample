//
//  LoginCoordinator.swift
//  ReactiveCoordinatorExample
//
//  Created by Peteranny on 2024/7/13.
//

import UIKit

final class LoginCoordinator: Coordinator { // subclass Coordinator
    // override the method to define how we respond to a step
    override func navigate(to step: Step) -> Navigation {
        switch step {
        case let step as LoginSteps:
            return navigate(to: step)

        default:
            return .undefined
        }
    }

    private func navigate(to step: LoginSteps) -> Navigation {

        switch step {

        // when asked to launch the editor
        case let .launch(viewModel, root):
            let login = LoginViewController(viewModel: viewModel)
            root.present(login, animated: true)
            return .many([
                // we start the flow whose lifecycle follows the root
                // this must be done on the first step of the flow
                .startFlow(root: login),

                // subscribe potential steps requested by the view model
                .subscribeSteps(login.viewModel, presenting: login),
            ])

        // when asked to login
        case .login(let settingsViewModel):
            // we end the flow
            return .endFlowAndForwardToParent(HomeSteps.showSettings(settingsViewModel))
        }

    }
}
