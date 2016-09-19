//
//  SRSMapItemView.swift
//  ASAPP
//
//  Created by Mitchell Morgan on 9/13/16.
//  Copyright © 2016 asappinc. All rights reserved.
//

import UIKit

class SRSMapItemView: UIView, ASAPPStyleable, StackableView {
    
    var mapItem: SRSMapItem? {
        didSet {
            if let imageType = mapItem?.imageType {
                switch imageType {
                case .Tech:
                    mapView.image = Images.imageTechLocationMap()
                    break
                    
                case .Equipment:
                    mapView.image = Images.imageEquipmentReturnMap()
                    break
                }
            }
        }
    }
    
    let mapView = UIImageView(image: Images.imageEquipmentReturnMap())
    
    // MARK: Initialization
    
    func commonInit() {
        mapView.clipsToBounds = true
        mapView.contentMode = .ScaleAspectFill
        mapView.layer.cornerRadius = 4
        addSubview(mapView)
    }
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        commonInit()
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        commonInit()
    }
    
    // MARK: ASAPPStyleable
    
    private(set) var styles = ASAPPStyles()
    
    func applyStyles(styles: ASAPPStyles) {
        self.styles = styles
    }
    
    // MARK: Layout
    
    override func layoutSubviews() {
        super.layoutSubviews()
        
        mapView.frame = bounds
    }
    
    override func sizeThatFits(size: CGSize) -> CGSize {
        let height = floor(size.width * 0.33)
        
        return CGSize(width: size.width, height: height)
    }
    
    // MARK: StackableView
    
    func prefersFullWidthDisplay() -> Bool {
        return true
    }
}
