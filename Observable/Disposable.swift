//
//  Disposable.swift
//
//  Created by Sergey Gorin on 29/04/2019.
//  Copyright © 2019 Sergey Gorin. All rights reserved.
//

import Foundation

/// Instance of Type that conforms to `Disposable' is intended for canceling observations
public protocol Disposable {
    func dispose()
    
    var isDisposed: Bool { get }
}

extension Disposable {
    
    /// Add disposable to the given dispose bag.
    func disposed(by disposeBag: DisposeBag) {
        disposeBag.append(disposable: self)
    }
    
    /// Add disposable to the dispose bag of the given disposeBag holder.
    func disposed(by disposeBagOwner: DisposeBagOwner) {
        disposed(by: disposeBagOwner.disposeBag)
    }
}

/// Default type conforming to `Disposable`
class DefaultDisposable: Disposable {
    
    var isDisposed: Bool { return disposeCallback == nil }
    
    private var disposeCallback: (() -> ())?
    
    private lazy var locker = NSRecursiveLock().with {
        $0.name = "com.defaultDisposable." + UUID().uuidString
    }
    
    @discardableResult
    func onDispose(_ callback: @escaping () -> ()) -> DefaultDisposable {
        self.disposeCallback = callback
        return self
    }
    
    func dispose() {
        locker.lock(); defer { locker.unlock() }
        disposeCallback?()
        disposeCallback = nil
    }
}

/// A container of disposables that intended to dispose them all on deinit.
final class DisposeBag: Appliable {
    
    private var disposables: [Disposable] = []
    private lazy var locker = NSRecursiveLock().with {
        $0.name = "com.disposeBag." + UUID().uuidString
    }
    
    var isDisposed: Bool {
        return disposables.isEmpty
    }
    
    deinit {
        dispose()
    }
    
    static func += (lhs: DisposeBag, rhs: Disposable) {
        lhs.append(disposable: rhs)
    }
    
    fileprivate func append(disposable: Disposable) {
        disposables.append(disposable)
    }
    
    private func dispose() {
        locker.lock(); defer { locker.unlock() }
        
        disposables.forEach { $0.dispose() }
        disposables.removeAll()
    }
}

/// A disposeBag object holder
protocol DisposeBagOwner {
    
    var disposeBag: DisposeBag { get }
}

extension AssociatedKey {
    fileprivate static let disposeBag = AssociatedKey("disposeBag_" + UUID().uuidString)
}

extension DisposeBagOwner where Self == NSObject {
    
    /// The default container of disposables
    var disposeBag: DisposeBag {
        return self.getAssociatedObject(forKey: .disposeBag)
            ?? DisposeBag().with { self.setAssociatedObject($0, forKey: .disposeBag) }
    }
}

/// `NSObject` enhanced with disposeBag container for convinience
/// So there is no need to set up disposeBag propery by yourself.
extension NSObject: DisposeBagOwner {
    
    /// The default container of disposables
    var disposeBag: DisposeBag {
        return getAssociatedObject(forKey: .disposeBag)
            ?? DisposeBag().with { setAssociatedObject($0, forKey: .disposeBag) }
    }
}
