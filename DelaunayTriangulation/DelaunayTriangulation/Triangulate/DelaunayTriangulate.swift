//
//  DelaunayTriangulate.swift
//  DelaunayTriangulation
//
//  Created by 樹葉 on 2020/7/13.
//  Copyright © 2020 樹葉. All rights reserved.
//

import Foundation
import CoreGraphics

// 参考 http://paulbourke.net/papers/triangulate/ 写的 Delaunay 三角剖分算法

struct Delaunay {
    
    static func triangulate(points: inout [CGPoint], triangles: inout [Triangle]) {
        
        defer {
            points.removeLast(3)
        }
        
        let pointCount = points.count
        var triCount = triangles.count
        
        var edges = [Edge]()
        var edgeCount = 0
        
        // 找到最大和最小的顶点边界
        var xmin = points[0].x
        var ymin = points[0].y
        var xmax = xmin
        var ymax = ymin
        
        for i in 1..<pointCount {
            xmin = min(points[i].x, xmin)
            ymin = min(points[i].y, ymin)
            xmax = max(points[i].x, xmax)
            ymax = max(points[i].y, ymax)
        }
        let dx = xmax - xmin
        let dy = ymax - ymin
        let dmax = max(dx, dy)
        let xmid = (xmax + xmin) * 0.5
        let ymid = (ymax + ymin) * 0.5
        
        // 设置 supertriangle
        points.append(CGPoint(x: xmid - 20 * dmax, y: ymid - dmax))
        points.append(CGPoint(x: xmid, y: ymid + 20 * dmax))
        points.append(CGPoint(x: xmid + 20 * dmax, y: ymid - dmax))
        
        // 把三角形加入到三角形数组中
        let triangle = Triangle(p1: pointCount, p2: pointCount + 1, p3: pointCount + 2)
        triangles.append(triangle)
        
        var delIndex = Set<Int>()
        
        var currentPoint: CGPoint
        var point1: CGPoint
        var point2: CGPoint
        var point3: CGPoint
        
        var xc: CGFloat
        var r: CGFloat
        
        // 开始遍历顶点坐标
        for i in 0..<pointCount {
            
            print("----------- 开始循环第\(i)个点，总共\(pointCount)个")
            
            currentPoint = points[i]
            edgeCount = 0
            
            // 遍历三角形
            triCount = triangles.count
            for j in 0..<triCount {
                print("----------- 开始循环第\(j)个三角形，总共\(triCount)个")
                let current = triangles[j]
                
                if current.isDelaunay || current.isNan {
                    continue
                }
                
                // 取出该三角形的三个点的坐标
                point1 = points[current.p1]
                point2 = points[current.p2]
                point3 = points[current.p3]
                
                // 判断当前点是否在外接圆中
                let result = circumCircle(sample: currentPoint, point1: point1, point2: point2, point3: point3)
                xc = result.center.x
                r = result.r
                
                // 如果当前点在外接圆的右侧，则该三角形为Delaunay三角形
                if xc < currentPoint.x, (currentPoint.x - xc) > r {
                    triangles[j].isDelaunay = true
                }
                
                // 如果点在圆内，则把边加到边缓冲中
                if result.isInside {
                    
                    edges.append(Edge(p1: current.p1, p2: current.p2))
                    edges.append(Edge(p1: current.p2, p2: current.p3))
                    edges.append(Edge(p1: current.p3, p2: current.p1))
                    
                    delIndex.insert(j)
                }
            }
            
            triangles.removeSpecifiedIndices(delIndex)
            delIndex.removeAll()
            
            // 去除edge的重复边
            edgeCount = edges.count
            if edgeCount > 0 {
                for j in 0..<edgeCount-1 {
                    for k in j+1..<edgeCount {
                        if edges[j].p1 == edges[k].p2, edges[j].p2 == edges[k].p1 {
                            delIndex.insert(j)
                            delIndex.insert(k)
                        }
                    }
                }
                
                edges.removeSpecifiedIndices(delIndex)
                edgeCount = edges.count
                delIndex.removeAll()
                
                // 重组三角形
                for j in 0..<edgeCount {
                    triangles.append(Triangle(p1: edges[j].p1, p2: edges[j].p2, p3: i))
                }
            }
            
            // 清空边缓冲
            edges.removeAll()
        }
        
        // 移除supertriangle
        triCount = triangles.count
        for i in 0..<triCount {
            if triangles[i].p1 >= pointCount || triangles[i].p2 >= pointCount || triangles[i].p3 >= pointCount {
                delIndex.insert(i)
            }
        }
        
        triangles.removeSpecifiedIndices(delIndex)
        delIndex.removeAll()
    }
}

extension Delaunay {
    private static func circumCircle(sample: CGPoint, point1: CGPoint, point2: CGPoint, point3: CGPoint) -> (center: CGPoint, r: CGFloat, isInside: Bool) {
        
        // 点坐标
        let x1 = point1.x
        let y1 = point1.y
        let x2 = point2.x
        let y2 = point2.y
        let x3 = point3.x
        let y3 = point3.y
        
        // 两条垂直平分线的斜率
        var m1: CGFloat
        var m2: CGFloat
        // 两条垂直平分线与边相交的点的坐标
        var mx1: CGFloat
        var mx2: CGFloat
        var my1: CGFloat
        var my2: CGFloat
        
        // 要求的圆心半径
        var xc: CGFloat = -1.0
        var yc: CGFloat = -1.0
        var r2: CGFloat = 0
        
        let fabsy1y2 = abs(y1 - y2)
        let fabsy2y3 = abs(y2 - y3)
        
        // 3点共线，不构成外接圆
        if fabsy1y2 < .ulpOfOne, fabsy2y3 < .ulpOfOne {
            return (CGPoint(x: xc, y: yc), r2, false)
        }
        
        // 1. 求外接圆圆心
        if fabsy1y2 < .ulpOfOne {
            print("y1 y2 平行")
            m2 = -(x3 - x2) / (y3 - y2)
            mx2 = (x2 + x3) * 0.5
            my2 = (y2 + y3) * 0.5
            xc = (x2 + x1) * 0.5
            yc = m2 * (xc - mx2) + my2
        } else if fabsy2y3 < .ulpOfOne {
            print("y2 y3 平行")
            m1 = -(x2-x1) / (y2-y1)
            mx1 = (x1 + x2) * 0.5
            my1 = (y1 + y2) * 0.5
            xc = (x3 + x2) * 0.5
            yc = m1 * (xc - mx1) + my1
        } else {
            m1 = -(x2-x1) / (y2-y1)
            m2 = -(x3-x2) / (y3-y2)
            mx1 = (x1 + x2) * 0.5
            mx2 = (x2 + x3) * 0.5
            my1 = (y1 + y2) * 0.5
            my2 = (y2 + y3) * 0.5

            // 两直线方程求出x
            xc = (m1 * mx1 - m2 * mx2 + my2 - my1) / (m1 - m2);
            
            // 两点的y方向差距越大，则出现垂直的情况越低，斜率也相对较小，不会出现极端情况
            if fabsy1y2 > fabsy2y3 {
               yc = m1 * (xc - mx1) + my1
            } else {
               yc = m2 * (xc - mx2) + my2
            }
        }
        
        // 2. 求外接圆半径,即任意一个顶点到圆心的距离
        var dx = x2 - xc;
        var dy = y2 - yc;
        r2 = dx * dx + dy * dy;

        // 3. 判断点是否在圆内
        dx = sample.x - xc;
        dy = sample.y - yc;
        let d2 = dx * dx + dy * dy
        
        return (CGPoint(x: xc, y: yc), sqrt(r2), (d2 - r2) <= .ulpOfOne)
    }
}

