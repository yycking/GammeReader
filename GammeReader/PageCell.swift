//
//  PageCell.swift
//  GammeReader
//
//  Created by YehYungCheng on 2016/3/27.
//  Copyright © 2016年 YehYungCheng. All rights reserved.
//

import UIKit

class PageCell: UITableViewCell {
    
    var backgroundImageView:UIImageView!
    let blurEffectView = UIVisualEffectView(effect: UIBlurEffect(style: .Dark))
    
    init(reuseIdentifier: String?) {
        super.init(style: UITableViewCellStyle.Subtitle, reuseIdentifier: reuseIdentifier)
        
        //blurEffectView.alpha = 0.5
        blurEffectView.layer.zPosition = (self.textLabel?.layer.zPosition)! - CGFloat(0.1)
        self.contentView.addSubview(blurEffectView)
        
        self.textLabel?.font = self.textLabel?.font.fontWithSize(18)
        self.textLabel?.numberOfLines = 0
        self.textLabel?.textColor = UIColor.whiteColor()
        
        self.selectionStyle = UITableViewCellSelectionStyle.None
        
        self.backgroundView = GravityScrollView()
        backgroundImageView = UIImageView()
        self.backgroundView!.addSubview(backgroundImageView)
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        
        backgroundSizeFit()
        
        var frame = (self.textLabel?.frame)!
        frame.origin.y = self.bounds.height - frame.size.height
        frame.size.width = self.bounds.width - frame.origin.x*2
        self.textLabel?.frame = frame
        
        blurEffectView.frame = frame
    }
    
    // MARK: - PageCell
    func setBackground(image: UIImage) {
        backgroundImageView.image = image
        backgroundSizeFit()
        
        backgroundImageView.setNeedsDisplay()
    }
    
    func backgroundSizeFit(){
        var frame = self.bounds
        
        // image aspect fill
        if let imageSize = backgroundImageView.image?.size {
            if frame.width/frame.height > imageSize.width/imageSize.height{
                frame.size.height = frame.width * imageSize.height / imageSize.width
            } else {
                frame.size.width = frame.height * imageSize.width / imageSize.height
            }
        }
        
        backgroundImageView.frame = frame
        
        let scrollView = self.backgroundView as! UIScrollView
        scrollView.contentSize = frame.size
        scrollView.contentOffset.x = (frame.width/2) - (self.bounds.width/2)
        scrollView.contentOffset.y = (frame.height/2) - (self.bounds.height/2)
    }
}
