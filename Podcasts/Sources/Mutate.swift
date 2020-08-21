//
//  Mutate.swift
//  Podcasts
//
//  Created by Yu Tawata on 2020/08/21.
//

import Foundation

func mutate<V>(_ value: V, _ closure: (inout V) -> Void) -> V where V: Any {
    var new = value
    closure(&new)
    return new
}
