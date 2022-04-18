//
//  Reusable.swift
//
//  Created by Sergey Gorin on 04/02/2019.
//  Copyright © 2019 Sergey Gorin. All rights reserved.
//

import UIKit

public protocol Reusable: class {
    static var reuseIdentifier: String { get }
}

extension Reusable {
    public static var reuseIdentifier: String {
        return String(describing: self)
    }
}

public protocol NibReusable: Reusable, NibInstantiable {}

extension UITableViewCell: Reusable {}
extension UITableViewHeaderFooterView: Reusable {}
extension UICollectionReusableView: Reusable {}

public protocol ReusableItemsManager {
    associatedtype BaseView
    var baseView: BaseView { get }
}

public struct ReuseId: RawRepresentable {
    public var rawValue: String
    
    public init(rawValue: String) {
        self.rawValue = rawValue
    }
    
    public init(_ rawValue: String) {
        self.rawValue = rawValue
    }
}

extension ReusableItemsManager where BaseView: UICollectionView {
    
    // Use one of these methods to register collectionView's cell without using a UINib or
    // dequeue cell without using string literals in reuseIdentifiers.
    // Every method uses class's name as an identifier and a nibName by default
    // if parameter `reuseId` was not set explicitly.
    
    /// Register class-based UICollectioniewCell
    /// Example: collectionView.register(CustomCollectionViewCell.self)
    @discardableResult
    public func register<T: UICollectionViewCell>(_: T.Type,
                                                  withReuseId reuseId: ReuseId? = nil) -> Self {
        baseView.register(T.self, forCellWithReuseIdentifier: reuseId?.rawValue ?? T.reuseIdentifier)
        return self
    }
    
    /// Register nib-based UICollectioniewCell
    /// Example: collectionView.register(CustomCollectionViewCell.self)
    @discardableResult
    public func register<T: UICollectionViewCell>(_: T.Type,
                                                  withReuseId reuseId: ReuseId? = nil) -> Self
        where T: NibReusable  {
            baseView.register(T.nib, forCellWithReuseIdentifier: reuseId?.rawValue ?? T.reuseIdentifier)
            return self
    }
    
    /// Register a bunch of nib-based or class-based cells of type/subtype UICollectionViewCell
    /// - Parameters: types - array of cells' classes
    /// - Example: collectionView.register([CustomCollectionViewCell.self])
    @discardableResult
    public func register<T: UICollectionViewCell>(types: [T.Type]) -> Self {
        types.forEach {
            if let cellClass = $0 as? NibReusable.Type {
                baseView.register(cellClass.nib, forCellWithReuseIdentifier: $0.reuseIdentifier)
            } else {
                baseView.register($0.self, forCellWithReuseIdentifier: $0.reuseIdentifier)
            }
        }
        return self
    }
    
    /// Dequeue custom UICollectionViewCell
    /// Example: let cell: CustomCollectionViewCell = collectionView.dequeueReusableCell(for: indexPath)
    public func dequeueCell<T: UICollectionViewCell>(_: T.Type = T.self,
                                                     withReuseId reuseId: ReuseId? = nil,
                                                     for indexPath: IndexPath) -> T {
        let reuseId = reuseId?.rawValue ?? T.reuseIdentifier
        guard let cell = baseView.dequeueReusableCell(withReuseIdentifier: reuseId, for: indexPath) as? T else {
            fatalError("Failed to dequeue cell with reuse identifier \(reuseId). Verify id in XIB/Storyboard.")
        }
        return cell
    }
    
    /// Register class-based UICollectionReusableView
    @discardableResult
    public func register<T: UICollectionReusableView>(_: T.Type,
                                                      kind: String,
                                                      withReuseId reuseId: ReuseId? = nil) -> Self {
        baseView.register(T.self, forSupplementaryViewOfKind: kind,
                          withReuseIdentifier: reuseId?.rawValue ?? T.reuseIdentifier)
        return self
    }
    
    /// Register nib-based UICollectionReusableView
    @discardableResult
    public func register<T: UICollectionReusableView>(_: T.Type,
                                                      kind: String,
                                                      withReuseId reuseId: ReuseId? = nil) -> Self
        where T: NibReusable {
            baseView.register(T.nib, forSupplementaryViewOfKind: kind,
                              withReuseIdentifier: reuseId?.rawValue ?? T.reuseIdentifier)
            return self
    }
    
    /// Register a bunch of nib-based and/or class-based reusable views subclassed from UICollectionReusableView
    @discardableResult
    public func register<T: UICollectionReusableView>(_ types: [T.Type], kind: String) -> Self {
        types.forEach {
            if let cellClass = $0 as? NibReusable.Type {
                baseView.register(cellClass.nib, forSupplementaryViewOfKind: kind, withReuseIdentifier: $0.reuseIdentifier)
            } else {
                baseView.register($0.self, forSupplementaryViewOfKind: kind, withReuseIdentifier: $0.reuseIdentifier)
            }
        }
        return self
    }
    
    /// Dequeue custom UICollectionReusableView instance
    public func dequeueView<T: UICollectionReusableView>(_: T.Type = T.self,
                                                         ofKind kind: String,
                                                         withReuseId reuseId: ReuseId? = nil,
                                                         for indexPath: IndexPath) -> T {
        let reuseId = reuseId?.rawValue ?? T.reuseIdentifier
        guard let cell = baseView.dequeueReusableSupplementaryView(ofKind: kind, withReuseIdentifier: reuseId,
                                                                   for: indexPath) as? T
            else {
                fatalError("Failed to dequeue supplementary view with reuse identifier \(reuseId). Verify id in XIB/Storyboard.")
        }
        return cell
    }
    
    /// Get cell by indexPath through subscript
    public subscript(indexPath: IndexPath) -> UICollectionViewCell? {
        return baseView.cellForItem(at: indexPath)
    }
}

extension ReusableItemsManager where BaseView: UITableView {
    
    // Use one of these methods to register tableView's cell without using a UINib or
    // dequeue cell without using string literals in reuseIdentifiers.
    // Every method uses class's name as an identifier and a nibName by default
    // if parameter `reuseId` was not set explicitly.
    
    /// Register class-based UITableViewCell
    /// Example: tableView.registerCell(CustomTableViewCell)
    @discardableResult
    public func register<T: UITableViewCell>(_: T.Type,
                                             withReuseId reuseId: ReuseId? = nil) -> Self {
        baseView.register(T.self, forCellReuseIdentifier: reuseId?.rawValue ?? T.reuseIdentifier)
        return self
    }
    
    /// Register nib-based UITableViewCell
    /// Example: tableView.registerCell(CustomTableViewCell)
    @discardableResult
    public func register<T: UITableViewCell>(_: T.Type,
                                             withReuseId reuseId: ReuseId? = nil) -> Self
        where T: NibReusable {
            baseView.register(T.nib, forCellReuseIdentifier: reuseId?.rawValue ?? T.reuseIdentifier)
            return self
    }
    
    /// Register a bunch of nib-based or class-based cells of type UITableViewCell
    /// - Parameters: types - array of cells' classes
    /// - Example: tableView.registerCells([CustomCollectionViewCell.self])
    @discardableResult
    public func register<T: UITableViewCell>(_ types: [T.Type]) -> Self {
        types.forEach {
            if let cellClass = $0 as? NibReusable.Type {
                baseView.register(cellClass.nib, forCellReuseIdentifier: $0.reuseIdentifier)
            } else {
                baseView.register($0.self, forCellReuseIdentifier: $0.reuseIdentifier)
            }
        }
        return self
    }
    
    /// Dequeue custom UITableViewCell
    /// Example: let cell: CustomTableViewCell = tableView.dequeueReusableCell(for: indexPath)
    public func dequeueCell<T: UITableViewCell>(_: T.Type = T.self,
                                                withReuseId reuseId: ReuseId? = nil,
                                                for indexPath: IndexPath) -> T {
        let reuseId = reuseId?.rawValue ?? T.reuseIdentifier
        guard let cell = baseView.dequeueReusableCell(withIdentifier: reuseId, for: indexPath) as? T else {
            fatalError("Failed to dequeue cell with reuse identifier \(reuseId). Verify id in XIB/Storyboard.")
        }
        return cell
    }
    
    /// Register class-based UITableViewHeaderFooterView class
    @discardableResult
    public func register<T: UITableViewHeaderFooterView>(_: T.Type,
                                                         withReuseId reuseId: ReuseId? = nil) -> Self {
        baseView.register(T.self, forHeaderFooterViewReuseIdentifier: reuseId?.rawValue ?? T.reuseIdentifier)
        return self
    }
    
    /// Register nib-based UITableViewHeaderFooterView class
    @discardableResult
    public func register<T: UITableViewHeaderFooterView>(_: T.Type,
                                                         withReuseId reuseId: ReuseId? = nil) -> Self
        where T: NibReusable {
            baseView.register(T.nib, forHeaderFooterViewReuseIdentifier: reuseId?.rawValue ?? T.reuseIdentifier)
            return self
    }
    
    /// Register a bunch of nib-based and/or class-based views subclassed from UITableViewHeaderFooterView
    @discardableResult
    public func register<T: UITableViewHeaderFooterView>(_ types: [T.Type]) -> Self {
        types.forEach {
            if let cellClass = $0 as? NibReusable.Type {
                baseView.register(cellClass.nib, forHeaderFooterViewReuseIdentifier: $0.reuseIdentifier)
            } else {
                baseView.register($0.self, forHeaderFooterViewReuseIdentifier: $0.reuseIdentifier)
            }
        }
        return self
    }
    
    /// Dequeue custom UITableViewHeaderFooterView instance
    public func dequeueView<T: UITableViewHeaderFooterView>(_: T.Type = T.self,
                                                            withReuseId reuseId: ReuseId? = nil) -> T? {
        let reuseId = reuseId?.rawValue ?? T.reuseIdentifier
        guard let cell = baseView.dequeueReusableHeaderFooterView(withIdentifier: reuseId) as? T? else {
            fatalError("Failed to dequeue reusable view with reuse identifier \(reuseId). Verify id in XIB/Storyboard.")
        }
        return cell
    }
    
    /// Get cell by indexPath through subscript
    public subscript(indexPath: IndexPath) -> UITableViewCell? {
        return baseView.cellForRow(at: indexPath)
    }
}

extension UICollectionView: ReusableItemsManager {
    public var baseView: UICollectionView { return self }
}

extension UITableView: ReusableItemsManager {
    public var baseView: UITableView { return self }
}
