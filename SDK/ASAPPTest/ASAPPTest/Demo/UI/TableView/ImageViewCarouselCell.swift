//
//  ImageViewCarouselCell.swift
//  ASAPPTest
//
//  Created by Mitchell Morgan on 6/22/17.
//  Copyright © 2017 asappinc. All rights reserved.
//

import UIKit

class ImageViewCarouselCell: TableViewCell {

    static let defaultHeight: CGFloat = 130.0
    
    var imageNames: [String]? {
        didSet {
            collectionView.reloadData()
        }
    }
    
    var selectedImageName: String? {
        didSet {
            collectionView.reloadData()
        }
    }
    
    var onSelection: ((_ imageName: String) -> Void)?
    
    override var contentInset: UIEdgeInsets {
        didSet {
            collectionView.contentInset = contentInset
        }
    }
    
    override class var reuseId: String {
        return "ImageViewCarouselCellReuseId"
    }
    
    private(set) var collectionView: UICollectionView!
    
    // MARK: Init
    
    override func commonInit() {
        super.commonInit()
        
        let layout = UICollectionViewFlowLayout()
        layout.scrollDirection = .horizontal
        layout.minimumInteritemSpacing = 12.0
        layout.minimumLineSpacing = 12.0
        
        collectionView = UICollectionView(frame: bounds, collectionViewLayout: layout)
        collectionView.contentInset = contentInset
        collectionView.backgroundColor = UIColor.clear
        collectionView.showsHorizontalScrollIndicator = false
        collectionView.register(RoundImageCVCell.self, forCellWithReuseIdentifier: RoundImageCVCell.reuseId)
        
        collectionView.dataSource = self
        collectionView.delegate = self
        contentView.addSubview(collectionView)
    }
    
    deinit {
        collectionView.dataSource = nil
        collectionView.delegate = nil
    }
}

// MARK: - Sizing

extension ImageViewCarouselCell {
    
    override func layoutSubviews() {
        super.layoutSubviews()
        
        collectionView.frame = bounds
    }
    
    override func sizeThatFits(_ size: CGSize) -> CGSize {
        let height: CGFloat
        if size.height > 0 {
            height = min(size.height, ImageViewCarouselCell.defaultHeight)
        } else {
            height = ImageViewCarouselCell.defaultHeight
        }
        
        return CGSize(width: size.width, height: height)
    }
}

extension ImageViewCarouselCell: UICollectionViewDataSource {
    
    func numberOfSections(in collectionView: UICollectionView) -> Int {
        return 1
    }
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return imageNames?.count ?? 0
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: RoundImageCVCell.reuseId, for: indexPath) as? RoundImageCVCell
        if let imageName = imageNames?[indexPath.row] {
            cell?.imageView.image = UIImage(named: imageName)
            cell?.shouldHighlightImageBorder = imageName == selectedImageName
        } else {
            cell?.imageView.image = nil
            cell?.shouldHighlightImageBorder = false
        }
        
        return cell ?? UICollectionViewCell()
    }
}

extension ImageViewCarouselCell: UICollectionViewDelegate {
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        collectionView.deselectItem(at: indexPath, animated: true)
        if let imageName = imageNames?[indexPath.row] {
            selectedImageName = imageName
            onSelection?(imageName)
        }
    }
}

extension ImageViewCarouselCell: UICollectionViewDelegateFlowLayout {
    
    func collectionView(_ collectionView: UICollectionView,
                        layout collectionViewLayout: UICollectionViewLayout,
                        sizeForItemAt indexPath: IndexPath) -> CGSize {
        let width = collectionView.bounds.width - collectionView.contentInset.left - collectionView.contentInset.right
        let height = collectionView.bounds.height - collectionView.contentInset.top - collectionView.contentInset.bottom
        let size = min(width, height)
        return CGSize(width: size, height: size)
    }
}
