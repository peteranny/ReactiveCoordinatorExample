//
//  Coordinator.swift
//  ReactiveCoordinatorExample
//
//  Created by Peteranny on 2024/7/13.
//

import Combine
import UIKit

/// Mark a type as `Step` for specific operations in the navigation flow.
/// It allows different navigations to follow a uniform interface, enabling easy coordination within.
protocol Step {}

/// Mark a type as `StepProvider` to emit the steps to be executed in the navigation flow.
/// Its implementations are responsible for defining and publishing these steps, providing
/// a central point for managing navigation in the system.
protocol StepProvider {
    var stepPublisher: AnyPublisher<Step, Never> { get }
}

/// Extend `Coordinator` to orchestrate navigation in the application.
/// A coordinator starts a flow, receives steps emitted by the `StepProvider`, and
/// handles resulting navigations. It encapsulates the navigation logic in the application.
class Coordinator: NSObject {
    init(onEndFlow: (() -> Void)? = nil) {
        self.onEndFlow = onEndFlow
    }

    /// Describe navigation to be undertaken by the Coordinator.
    enum Navigation {
        /// Not yet defined
        case undefined

        /// Start the coordinator and follow the lifecycle of the root
        case startFlow(root: UIViewController)

        /// Explicitly declare no steps to subscribe
        case subscribeNoSteps

        /// Subscribe the steps from the provider until the presented is deallocated
        case subscribeSteps(StepProvider, presenting: UIViewController)

        /// Start a child coordinator with an initial step
        case startChildFlow(Coordinator, with: Step)

        /// End the coordinator
        case endFlow

        /// End the coordinator with a step forwarded to the parent to respond
        case endFlowAndForwardToParent(Step)

        /// Use this case when multiple navigations happen at the same time.
        indirect case many([Navigation])

        /// Use this case when the navigation can't be determined directly.
        /// Invoke the supplied closure with the identified navigation.
        indirect case async((@escaping (Navigation) -> Void) -> Void)
    }

    /// Override this method to customize how the coordinator respond to a step.
    /// - Parameter step: The in coming step.
    /// - Returns: The naivation in respond to the step
    func navigate(to step: Step) -> Navigation {
        .undefined
    }

    // MARK: - Private

    private func performNavigation(to step: Step) {
        performNavigation(navigate(to: step))
    }

    private func performNavigation(_ navigation: Navigation) {
        switch navigation {
        case .undefined:
            break

        case .startFlow(let root):
            assert(rootViewController == nil, "The root cannot be set more than once.")
            rootViewController = root

            // End the flow as long as the root is deallocated
            root.deallocatedPublisher
                .sink { [weak self] in self?.performNavigation(.endFlow) }
                .store(in: &subscriptions)

        case .subscribeNoSteps:
            break

        case let .subscribeSteps(stepProvider, presenting: presentable):
            stepProvider.stepPublisher
                .prefix(untilOutputFrom: presentable.deallocatedPublisher)
                .sink { [weak self] in self?.performNavigation(to: $0) }
                .store(in: &subscriptions)

        case let .startChildFlow(childCoordinator, with: initialStep):
            children.append(childCoordinator)
            childCoordinator.parent = self
            childCoordinator.performNavigation(to: initialStep)

        case .endFlow where rootViewController != nil:
            // Dismiss the root to trigger endFlow
            assert(rootViewController.presentedViewController == nil)
            rootViewController.dismiss(animated: true)

        case .endFlow:
            parent?.children.removeAll(where: { $0 == self })
            onEndFlow?()

        case .endFlowAndForwardToParent(let step):
            performNavigation(.endFlow)
            parent?.performNavigation(to: step)

        case .many(let navigations):
            navigations.forEach { performNavigation($0) }

        case .async(let task):
            task { [weak self] in self?.performNavigation($0) }
        }
    }

    private weak var parent: Coordinator?
    private var children: [Coordinator] = []
    private var subscriptions: [AnyCancellable] = []
    private let onEndFlow: (() -> Void)?

    // The root must be set on the first step when launching
    // the coordinator. This serves as the referenced lifecycle
    // for the coordinator to follow.
    private weak var rootViewController: UIViewController!
}

extension Coordinator {
    /// Used only when we start a coordinator without a parent coordinator.
    /// For coordinators whose parant is present, use `Navigation.startChildFlow(_:)` instead.
    /// - Parameters:
    ///   - coordinator: The coordinator to start
    ///   - step: The initial step to start the coordinator
    static func start(_ coordinator: Coordinator, from step: Step) {
        coordinator.performNavigation(to: step)
    }
}
