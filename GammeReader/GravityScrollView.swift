//
//  GravityScrollView.swift
//  GammeReader
//
//  Created by YehYungCheng on 2016/3/27.
//  Copyright © 2016年 YehYungCheng. All rights reserved.
//

import UIKit
import CoreMotion

class GravityScrollView: UIScrollView {
    let manager = CMMotionManager()
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        if manager.deviceMotionAvailable {
            manager.deviceMotionUpdateInterval = 0.03
            manager.startDeviceMotionUpdatesToQueue(NSOperationQueue.mainQueue()) {
                (data, error) in
                let gravity = data!.gravity
                
                self.contentOffset.x = (self.contentSize.width - self.bounds.width) * self.countGravityOffset(gravity.x)
                self.contentOffset.y = (self.contentSize.height - self.bounds.height) * self.countGravityOffset(gravity.y)
            }
        }
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func countGravityOffset(value:Double)->CGFloat{
        var offset = value + 1
        let min = 0.75
        let max = 1.25
        if offset < min {
            offset = min
        }
        if offset > max {
            offset = max
        }
        return CGFloat((offset - min) / (max - min))
    }
}
