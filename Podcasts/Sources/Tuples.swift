//
//  Tuples.swift
//  Podcasts
//
//  Created by Yu Tawata on 2020/08/22.
//

import Foundation

public struct Tuple2<S, T> {
    public var value0: S
    public var value1: T

    public init(value0: S, value1: T) {
        self.value0 = value0
        self.value1 = value1
    }
}

extension Tuple2: Equatable where S: Equatable, T: Equatable {}
