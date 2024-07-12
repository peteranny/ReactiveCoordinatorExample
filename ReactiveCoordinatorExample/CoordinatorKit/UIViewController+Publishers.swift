//
//  UIViewController+Publishers.swift
//  ReactiveCoordinatorExample
//
//  Created by Peteranny on 2024/7/13.
//

import Combine
import UIKit

extension UIViewController {
    var deallocatedPublisher: AnyPublisher<Void, Never> {
        DeinitObserver.deinitPublisher(of: self)
    }
}

// MARK: - Deinit publisher

private var deinitObserverKey = "DEINITCALLBACK_SUAS"

private class DeinitObserver: NSObject {
    static func deinitPublisher(of object: NSObject) -> AnyPublisher<Void, Never> {
        // Ref: https://github.com/onmyway133/blog/issues/70
        if let observer = objc_getAssociatedObject(object, &deinitObserverKey) as? DeinitObserver {
            return observer.deinitPublisher
        }

        let observer = DeinitObserver()
        objc_setAssociatedObject(object, &deinitObserverKey, observer, .OBJC_ASSOCIATION_RETAIN_NONATOMIC)
        return observer.deinitPublisher
    }

    private let deinitSubject = PassthroughSubject<Void, Never>()
    var deinitPublisher: AnyPublisher<Void, Never> {
        deinitSubject.eraseToAnyPublisher()
    }

    deinit {
        deinitSubject.send(())
    }
}
