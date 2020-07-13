//
//  Edge.swift
//  DelaunayTriangulation
//
//  Created by 樹葉 on 2020/7/13.
//  Copyright © 2020 樹葉. All rights reserved.
//

import Foundation

struct Edge {
    var p1: Int
    var p2: Int
}

extension Edge {
    static var nan: Edge { .init(p1: -1, p2: -1) }
    
    var isNan: Bool { p1 < 0 || p2 < 0 }
    
    mutating func invalidate() {
        p1 = -1
        p2 = -1
    }
}
