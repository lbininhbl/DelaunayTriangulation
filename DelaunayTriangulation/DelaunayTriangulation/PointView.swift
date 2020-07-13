//
//  PointView.swift
//  DelaunayTriangulation
//
//  Created by 樹葉 on 2020/7/13.
//  Copyright © 2020 樹葉. All rights reserved.
//

import UIKit
import SnapKit

class PointView: UIView {
    private var label: UILabel!
    
    var fontSize: CGFloat {
        get { label.font.pointSize }
        set { label.font = UIFont.systemFont(ofSize: newValue) }
    }
    
    var text: String? {
        get { label.text }
        set { label.text = newValue }
    }
    
    required init?(coder: NSCoder) { fatalError("init(coder:) has not been implemented") }
    override init(frame: CGRect) {
        super.init(frame: frame)
        
        label = UILabel(frame: .zero)
        label.textAlignment = .center
        label.font = UIFont.systemFont(ofSize: 8)
        label.adjustsFontSizeToFitWidth = true
        label.adjustsFontForContentSizeCategory = true
        addSubview(label)
        
        label.snp.makeConstraints { (make) in
            make.edges.equalToSuperview()
        }
    }

    override func layoutSubviews() {
        super.layoutSubviews()
        layer.cornerRadius = frame.width * 0.5
    }
}
