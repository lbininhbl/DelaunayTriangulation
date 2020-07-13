//
//  ViewController.swift
//  DelaunayTriangulation
//
//  Created by 樹葉 on 2020/7/13.
//  Copyright © 2020 樹葉. All rights reserved.
//

import UIKit

class ViewController: UIViewController {

    @IBOutlet weak var imageView: UIImageView!
    @IBOutlet weak var countLabel: UILabel!
    
    private var pointCount: Int = 4
    
    private var isInProgress = false
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
    }

    
    // MARK: - Actions
    @IBAction func onSliderValueChanged(_ sender: UISlider) {
        pointCount = Int(sender.value.rounded())
        
        countLabel.text = "点的数量：\(pointCount)"
    }
    
    @IBAction func onTriangulate(_ sender: Any) {
        guard isInProgress == false else { return }
        
        isInProgress = true
        imageView.subviews.forEach { $0.removeFromSuperview() }
        
        let drawView = UIImageView(frame: imageView.bounds)
        drawView.backgroundColor = .white
        
        UIGraphicsBeginImageContext(drawView.frame.size)
        
        let size = 10
        let pointSize = CGSize(width: size, height: size)
        var points = generatePoints().sorted { $0.x < $1.x }
        for (index, point) in points.enumerated() {
            let pview = PointView(frame: CGRect(origin: .zero, size: pointSize))
            pview.center = point
            pview.text = "\(index)"
            pview.fontSize = 8
            pview.backgroundColor = .green
            imageView.addSubview(pview)
        }
        
        var triangles = [Triangle]()
        Delaunay.triangulate(points: &points, triangles: &triangles)
        
        let bezier = UIBezierPath()
        bezier.lineWidth = 1
        triangles.forEach { (triangle) in

            bezier.move(to: points[triangle.p1])
            bezier.addLine(to: points[triangle.p2])
            bezier.addLine(to: points[triangle.p3])

            bezier.close()
        }

        bezier.stroke()
        
        let image = UIGraphicsGetImageFromCurrentImageContext()
        
        UIGraphicsEndImageContext()
        
        imageView.image = image
        
        isInProgress = false
    }
    
}

extension ViewController {
    private func generatePoints() -> [CGPoint] {
        var points = [CGPoint]()
        for _ in 0..<pointCount {
            let x = CGFloat.random(in: 25...view.bounds.width - 50)
            let y = CGFloat.random(in: 100...view.bounds.height - 300)
            let point = CGPoint(x: x, y: y)
            points.append(point)
        }
        return points
    }
}
