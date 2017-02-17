//
//  SRSMapItemView.swift
//  ASAPP
//
//  Created by Mitchell Morgan on 9/13/16.
//  Copyright © 2016 asappinc. All rights reserved.
//

import UIKit

class SRSMapItemView: UIView {
    
    var mapItem: SRSMapItem? {
        didSet {
            if let imageType = mapItem?.imageType {
                switch imageType {
                case .tech:
                    mapView.image = Images.asappImage(.imageTechLocationMap)
                    break
                    
                case .equipment:
                    mapView.image = Images.asappImage(.imageEquipmentReturnMap)
                    break
                    
                case .device:
                    mapView.image = Images.asappImage(.imageDeviceTrackingMap)
                    break
                }
            }
        }
    }
    
    fileprivate let mapView = UIImageView(image: Images.asappImage(.imageEquipmentReturnMap))
    
    // MARK: Initialization
    
    func commonInit() {
        mapView.clipsToBounds = true
        mapView.contentMode = .scaleAspectFill
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
    
    // MARK: Layout
    
    override func layoutSubviews() {
        super.layoutSubviews()
        
        mapView.frame = bounds
    }
    
    override func sizeThatFits(_ size: CGSize) -> CGSize {
        let height = floor(size.width * 0.33)
        
        return CGSize(width: size.width, height: height)
    }
}

// MARK:- StackableView

extension SRSMapItemView: StackableView {
    
    func prefersFullWidthDisplay() -> Bool {
        return true
    }
}
