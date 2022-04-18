//
//  Result+Extensions.swift
//
//  Created by Sergey Gorin on 11/07/2019.
//  Copyright © 2019 Sergey Gorin. All rights reserved.
//

import Foundation

extension Result where Success == Void {
    static var success: Result {
        return .success(())
    }
}

typealias ResultCallback<T> = (Result<T, Error>) -> Void

typealias VoidResult = Result<Void, Error>
