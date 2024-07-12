//
//  HomeCoordinator.swift
//  ReactiveCoordinatorExample
//
//  Created by Peteranny on 2024/7/13.
//

import UIKit

final class HomeCoordinator: Coordinator { // subclass Coordinator
    // override the method to define how we respond to a step
    override func navigate(to step: Step) -> Navigation {
        switch step {
        case let step as HomeSteps:
            return navigate(to: step)

        case let step as SettingsSteps:
            return navigate(to: step)

        default:
            return .undefined
        }
    }

    private func navigate(to step: HomeSteps) -> Navigation {

        switch step {

        // when asked to launch the editor
        case .launch(let window):
            let home = HomeViewController()
            let nav = UINavigationController(rootViewController: home)
            window.rootViewController = nav
            self.nav = nav
            return .many([
                // we start the flow whose lifecycle follows the root
                // this must be done on the first step of the flow
                .startFlow(root: nav),

                // subscribe potential steps requested by the view model
                .subscribeSteps(home.viewModel, presenting: nav),
            ])

        // when asked to show the login page
        case .showLogin(let viewModel):
            // we present the login page in response to the step
            return .startChildFlow(LoginCoordinator(), with: LoginSteps.launch(viewModel, root: nav!))

        // when asked to show the settings page
        case .showSettings(let viewModel):
            // we present the settings in response to the step
            let settings = SettingsViewController(viewModel: viewModel)
            nav?.pushViewController(settings, animated: true)
            return .subscribeSteps(settings.viewModel, presenting: settings)

        }

    }

    private func navigate(to step: SettingsSteps) -> Navigation {
        switch step {
        case .showVersion(let version):
            let alert = UIAlertController(title: "Version", message: version, preferredStyle: .alert)
            alert.addAction(UIAlertAction(title: "OK", style: .default))
            nav?.present(alert, animated: true)
            return .subscribeNoSteps
        }
    }

    private weak var nav: UINavigationController?
}
