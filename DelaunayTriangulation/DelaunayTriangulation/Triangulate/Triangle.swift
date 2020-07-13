//
//  Triangle.swift
//  DelaunayTriangulation
//
//  Created by 樹葉 on 2020/7/13.
//  Copyright © 2020 樹葉. All rights reserved.
//

import Foundation

struct Triangle {
    var p1: Int
    var p2: Int
    var p3: Int
    var isDelaunay: Bool = false
}

extension Triangle {
    static var nan: Self { .init(p1: -1, p2: -1, p3: -1, isDelaunay: false) }
    
    var isNan: Bool { p1 < 0 || p2 < 0 || p3 < 0 }
    
    mutating func invalidate() {
        p1 = -1
        p2 = -1
        p3 = -1
    }
}

extension Triangle: Equatable {
    static func == (lhs: Self, rhs: Self) -> Bool {
        let lps = [lhs.p1, lhs.p2, lhs.p3].sorted { $0 < $1 }
        let rps = [rhs.p1, rhs.p2, rhs.p3].sorted { $0 < $1 }
        return lps == rps
    }
}
