//
//  BrandingSwitcherView.swift
//  ASAPPTest
//
//  Created by Mitchell Morgan on 2/2/17.
//  Copyright © 2017 asappinc. All rights reserved.
//

import UIKit

class BrandingSwitcherView: UIView {
   
    var didSelectBrandingType: ((_ type: BrandingType) -> Void)? {
        didSet {
            brandingPreviewListView.didSelectBrandingType = didSelectBrandingType
        }
    }
    
    private(set) var switcherViewHidden = true
    
    private let brandingPreviewListView = BrandingPreviewListView()
    
    private var listViewSize = CGSize.zero
    
    private let backgroundOverlayView = UIView()
    
    private var brandingPreviewSize: CGSize = .zero
    
    private var animator: UIDynamicAnimator!
    
    // MARK: Initialization
    
    func commonInit() {
        isUserInteractionEnabled = false
        
        backgroundOverlayView.backgroundColor = UIColor.black
        backgroundOverlayView.alpha = 0.0
        backgroundOverlayView.addGestureRecognizer(UITapGestureRecognizer(target: self,
                                                                          action: #selector(BrandingSwitcherView.didTapOverlayView)))
        addSubview(backgroundOverlayView)
        
        let panGesture = UIPanGestureRecognizer(target: self, action: #selector(BrandingSwitcherView.didPan(gesture:)))
        brandingPreviewListView.addGestureRecognizer(panGesture)
        addSubview(brandingPreviewListView)
        
        animator = UIDynamicAnimator(referenceView: self)
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
        
        backgroundOverlayView.frame = bounds
        
        let width = floor(min(320, bounds.width * 0.8))
        let height = ceil(brandingPreviewListView.sizeThatFits(CGSize(width: width, height: 0)).height)
        listViewSize = CGSize(width: width, height: height)
        
        if !brandingPreviewListView.bounds.size.equalTo(listViewSize) {
            brandingPreviewListView.bounds = CGRect(x: 0, y: 0, width: listViewSize.width, height: listViewSize.height)
            brandingPreviewListView.center = getPreviewListCenter(whenHidden: switcherViewHidden)
        }
    }
    
    func getPreviewListCenter(whenHidden hidden: Bool) -> CGPoint {
        var center = CGPoint(x: bounds.midX, y: bounds.midY)
        if hidden {
            center.y = floor(-listViewSize.height / 2.0 - 64)
        }
        return center
    }
    
    // MARK:- Actions
    
    func didTapOverlayView() {
        setSwitcherViewHidden(true, animated: true)
    }
    
    func setSwitcherViewHidden(_ hidden: Bool, animated: Bool) {
        if hidden == switcherViewHidden || animator.isRunning {
            return
        }
        switcherViewHidden = hidden
        
        func updateBlock() {
            self.brandingPreviewListView.center = getPreviewListCenter(whenHidden: switcherViewHidden)
            self.backgroundOverlayView.alpha = switcherViewHidden ? 0.0 : 0.4
            self.isUserInteractionEnabled = !switcherViewHidden
        }
        
        if !switcherViewHidden {
            brandingPreviewListView.alpha = 0.0
            brandingPreviewListView.transform = .identity
            brandingPreviewListView.center = getPreviewListCenter(whenHidden: true)
            brandingPreviewListView.alpha = 1.0
        }
        
        if animated {
            UIView.animate(withDuration: 0.5,
                           delay: 0.0,
                           usingSpringWithDamping: 0.75,
                           initialSpringVelocity: 0.0,
                           options: .curveEaseInOut,
                           animations: updateBlock,
                           completion: nil)
        } else {
            updateBlock()
        }
    }
    
    // MARK:- Gesture
    
    var attachment: UIAttachmentBehavior?
    var startCenter: CGPoint = .zero
    var lastTime: CFAbsoluteTime = 0
    var lastAngle: CGFloat = 0
    var angularVelocity: CGFloat = 0
    
    func didPan(gesture: UIPanGestureRecognizer?) {
        guard let gesture = gesture,
            let gestureView = gesture.view,
            let gestureSuperview = gestureView.superview else {
            return
        }
        
        // http://stackoverflow.com/questions/21325057/implement-uikitdynamics-for-dragging-view-off-screen
        
        switch gesture.state {
        case .began:
            animator?.removeAllBehaviors()
    
            startCenter = gestureView.center
            let pointWithinView = gesture.location(in: gestureView)
            let offset = UIOffset(horizontal: pointWithinView.x - gestureView.bounds.width / 2.0,
                                  vertical: pointWithinView.y - gestureView.bounds.height / 2.0)
            let anchor = gesture.location(in: gestureSuperview)
            
            attachment = UIAttachmentBehavior(item: gestureView, offsetFromCenter: offset, attachedToAnchor: anchor)
            lastTime = CFAbsoluteTimeGetCurrent()
            lastAngle = getAngleOfView(gestureView)
            
            if let attachment = attachment {
                attachment.action = { [weak self] in
                    guard let weakSelf = self else { return }
                    
                    let time = CFAbsoluteTimeGetCurrent()
                    let angle = weakSelf.getAngleOfView(gestureView)
                    if time > weakSelf.lastTime {
                        weakSelf.angularVelocity = CGFloat(angle - weakSelf.lastAngle) / CGFloat(time - weakSelf.lastTime);
                        weakSelf.lastTime = time;
                        weakSelf.lastAngle = angle;
                    }
                }
                animator.addBehavior(attachment)
            }
            break
            
        case .changed:
            // As the user makes gesture, update attachment behavior's anchor point, achieving drag 'n' rotate
            attachment?.anchorPoint = gesture.location(in: self)
            break
            
        case .ended:
            animator.removeAllBehaviors()
            
            let velocity = gesture.velocity(in: gestureSuperview)
            
            let magnitude = sqrt(velocity.x * velocity.x + velocity.y * velocity.y)

//            let angle = fabs(Double(atan2(velocity.y, velocity.x)) - M_PI_2)
//            if (fabs(Double(atan2(velocity.y, velocity.x)) - M_PI_2) > M_PI_4) {
        
            if magnitude < 800.0 {
                let snap = UISnapBehavior(item: gestureView, snapTo: getPreviewListCenter(whenHidden: false))
                animator.addBehavior(snap)
                return;
            }
            
            // Otherwise, create UIDynamicItemBehavior that carries on animation from where the gesture left off (notably linear and angular velocity)
            
            let dynamic = UIDynamicItemBehavior(items: [gestureView])
            dynamic.addLinearVelocity(velocity, for: gestureView)
            dynamic.addAngularVelocity(angularVelocity, for: gestureView)
            dynamic.angularResistance = 1.25
            dynamic.action = { [weak self] in
                guard let weakSelf = self else { return }
                
                if !gestureSuperview.bounds.intersects(gestureView.frame) {
                    self?.animator.removeAllBehaviors()
                    
                    weakSelf.brandingPreviewListView.alpha = 0.0
                    weakSelf.brandingPreviewListView.transform = .identity
                    weakSelf.brandingPreviewListView.center = weakSelf.getPreviewListCenter(whenHidden: true)
                    weakSelf.brandingPreviewListView.alpha = 1.0
    
                    UIView.animate(withDuration: 0.3, animations: {
                        weakSelf.backgroundOverlayView.alpha = 0.0
                    }) { (completed) in
                        weakSelf.switcherViewHidden = true
                        weakSelf.isUserInteractionEnabled = false
                    }
                }
            }
            animator.addBehavior(dynamic)
            
            let gravity = UIGravityBehavior(items: [gestureView])
            gravity.magnitude = 0.7
            self.animator.addBehavior(gravity)
            break
            
        default: break
        }
    }

    func getAngleOfView(_ view: UIView) -> CGFloat {
        // http://stackoverflow.com/a/2051861/1271826
        return atan2(view.transform.b, view.transform.a)
    }
}
