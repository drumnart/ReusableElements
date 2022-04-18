//
//  TagsBar.swift
//
//  Created by Sergey Gorin on 30.10.2019.
//  Copyright © 2019 Sergey Gorin. All rights reserved.
//

import UIKit

class TagsBar: BaseView {

    private(set) var tags: [String] = []
    
    lazy var collectionLayout = UICollectionViewFlowLayout().with {
        $0.scrollDirection = .horizontal
        $0.minimumInteritemSpacing = 0
        $0.minimumLineSpacing = 11
        $0.itemSize = CGSize(width: 100, height: 30)
        $0.estimatedItemSize = $0.itemSize
    }
    
    lazy var collectionView = UICollectionView(
        frame: .zero,
        collectionViewLayout: collectionLayout).with {
            if #available(iOS 11.0, *) {
                $0.contentInsetAdjustmentBehavior = .never
            }
        
            $0.backgroundColor = .tbxBackground
            $0.scrollsToTop = false
            $0.showsHorizontalScrollIndicator = false
            $0.showsVerticalScrollIndicator = false
            $0.contentInset = .apply(left: 20, right: 20)
            $0.dataSource = self
            $0.delegate = self
            $0.register(TagsBarCell.self)
    }
    
    private var selectionClosure: ((_ tagListView: TagsBar, _ index: Int) -> Void)?
    private var didRemoveClosure: ((_ tagListView: TagsBar, _ index: Int) -> Void)?
    
    override func prepare() {
        addSubview(collectionView)
        collectionView.xt.pinEdges()
    }
    
    func setTags(_ tags: [String]) {
        
        guard tags.count > 0 || self.tags.count > 0 else { return }
        
        let oldTags = self.tags
        self.tags = tags

        if #available(iOS 13, *) {
            if oldTags.count == 0 {
                reload()
            } else {
                let diff = tags.difference(from: oldTags)
                
                var deletedIndexPaths: [IndexPath] = []
                var insertedIndexPaths: [IndexPath] = []
                
                for change in diff {
                    switch change {
                    case let .remove(offset, _, _):
                        deletedIndexPaths.append(IndexPath(item: offset, section: 0))
                        
                    case let .insert(offset, _, _):
                        insertedIndexPaths.append(IndexPath(item: offset, section: 0))
                    }
                }
                
                self.collectionView.performBatchUpdates({
                    self.collectionView.deleteItems(at: deletedIndexPaths)
                    self.collectionView.insertItems(at: insertedIndexPaths)
                }) { _ in }
            }
        } else {
            reload()
        }
    }
    
    func insertTag(_ tag: String, at index: Int) {
        self.tags.insert(tag, at: index)
        collectionView.insertItems(at: [IndexPath(item: index, section: 0)])
    }
    
    func removeTag(at index: Int) {
        self.tags.remove(at: index)
        collectionView.performBatchUpdates({
            collectionView.deleteItems(at: [IndexPath(item: index, section: 0)])
        }) { _ in }
        didRemoveClosure?(self, index)
    }
    
    func reload() {
        collectionView.reloadData()
    }
    
    func onDidSelect(_ closure: ((_ tagListView: TagsBar, _ index: Int) -> Void)?) {
        self.selectionClosure = closure
    }
    
    func onDidRemove(_ closure: ((_ tagListView: TagsBar, _ index: Int) -> Void)?) {
        self.didRemoveClosure = closure
    }
}

extension TagsBar: UICollectionViewDataSource, UICollectionViewDelegateFlowLayout {
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return tags.count
    }
    
    func collectionView(_ collectionView: UICollectionView,
                        cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        return collectionView.dequeueCell(TagsBarCell.self, for: indexPath).with {
            let tag = tags[indexPath.item]
            $0.title = tag.trimmingCharacters(in: .whitespacesAndNewlines)
            $0.delegate = self
        }
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        selectionClosure?(self, indexPath.item)
    }
}

extension TagsBar: TagsBarCellDelegate {
    
    func handleTagBarItemDelete(for cell: TagsBarCell) {
        guard let indexPath = collectionView.indexPath(for: cell) else { return }
        didRemoveClosure?(self, indexPath.item)
    }
}
