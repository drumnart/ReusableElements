//
//  SequenceDiff.swift
//
//  Created by Sergey Gorin on 29/04/2019.
//  Copyright © 2019 Sergey Gorin. All rights reserved.
//

public struct SequenceDiff<T1, T2> {
    public let removed: [T1]
    public let inserted: [T2]
    
    public init(removed: [T1] = [], inserted: [T2] = []) {
        self.removed = removed
        self.inserted = inserted
    }
}

public func diff<T1, T2>(_ first: [T1], _ second: [T2],
                         compare: (T1,T2) -> Bool) -> SequenceDiff<T1, T2> {
    let combinations = first.compactMap { firstElement in
        (firstElement, second.first { secondElement in compare(firstElement, secondElement) })
    }
    let common = combinations.filter { $0.1 != nil }.compactMap { ($0.0, $0.1!) }
    let removed = combinations.filter { $0.1 == nil }.compactMap { ($0.0) }
    let inserted = second.filter { secondElement in !common.contains { compare($0.0, secondElement) } }
    
    return SequenceDiff(removed: removed, inserted: inserted)
}
