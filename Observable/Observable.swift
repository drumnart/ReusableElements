//
//  Observable.swift
//
//  Created by Sergey Gorin on 29/04/2019.
//  Copyright © 2019 Sergey Gorin. All rights reserved.
//

import Foundation

extension Observable: BlockScopable {}

class Observable<T> {
    
    struct ValueChange {
        let old: T
        let new: T
        
        init(_ o: T, _ n: T) {
            old = o
            new = n
        }
    }
    
    typealias ObserverClosure = (ValueChange) -> ()
    typealias ObserverId = String
    
    private(set) var observers: [(ObserverId, Observer<ValueChange>)] = []
    
    private(set) var value: T {
        didSet {
            self.oldValue = oldValue
            let fire = { [observers, value] in
                observers.forEach {
                    $0.1.notify(ValueChange(oldValue, value))
                }
            }
            queue?.async(execute: fire) ?? fire()
        }
    }
    
    private(set) lazy var oldValue: T = self.value
    
    fileprivate var queue: DispatchQueue? = .main
    private lazy var locker = NSRecursiveLock().with {
        $0.name = "com.observable." + UUID().uuidString
    }
    
    init(_ value: T) {
        self.value = value
    }
    
    func set(_ value: T) {
        self.value = value
    }
    
    @discardableResult func observe(by observer: @escaping ObserverClosure) -> Disposable {
        locker.lock(); defer { locker.unlock() }
        
        let id = UUID().uuidString
        observers.append((id, Observer(observer)))
        
        return DefaultDisposable().onDispose { [weak self, id] in
            self?.removeObserver(by: id)
        }
    }
    
    @discardableResult func observeAndFire(by observer: @escaping ObserverClosure) -> Disposable {
        defer { observer(ValueChange(oldValue, value)) }
        return observe(by: observer)
    }
    
    func observeOn(_ queue: DispatchQueue) -> Observable<T> {
        return with {
            $0.queue = queue
        }
    }
    
    private func removeObserver(by id: ObserverId) {
        guard let index = observers.firstIndex(where: { $0.0 == id }) else { return }
        observers.remove(at: index)
    }
    
    func removeObservers() {
        observers = []
    }
    
    deinit {
        removeObservers()
    }
}
