//
//  Array+Extension.swift
//  DelaunayTriangulation
//
//  Created by 樹葉 on 2020/7/13.
//  Copyright © 2020 樹葉. All rights reserved.
//

import Foundation

extension Array {
    mutating func removeSpecifiedIndices(_ indices: Set<Int>) {
        let sortedIndices = indices.sorted().reversed()
        for i in sortedIndices {
            guard i < count else { return }
            remove(at: i)
        }
    }
}
