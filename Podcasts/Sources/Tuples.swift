//
//  Tuples.swift
//  Podcasts
//
//  Created by Yu Tawata on 2020/08/22.
//

import Foundation

struct Tuple2<S, T> {
    var value0: S
    var value1: T
}

extension Tuple2: Equatable where S: Equatable, T: Equatable {}
