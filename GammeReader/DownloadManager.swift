//
//  DownloadManager.swift
//  GammeReader
//
//  Created by YehYungCheng on 2016/3/26.
//  Copyright © 2016年 YehYungCheng. All rights reserved.
//

import Foundation

class DownloadManager {
    var retry = 3
    let request: NSMutableURLRequest!
    let action: NSData->()!
    var fail: (()->())?
    
    init(url: String, success: NSData->()) {
        self.request = NSMutableURLRequest(URL: NSURL(string: url)!)
        self.action = success
    }
    
    @objc func connect() {
        autoreleasepool { 
            let session = NSURLSession.sharedSession()
            let sessionURLTask = session.dataTaskWithRequest(request) { (data, response, error) in
                // success and error handling
                if let data = data {
                    self.action(data)
                    return
                }
                
                var delaySecond: Double = 1.0
                if let error = error {
                    // check if error is transient or final and throw right error
                    if let delay = error.userInfo["ErrorRetryDelayKey"] as? Double {
                        // request failed and can be retry later
                        delaySecond = delay
                    }
                }
                self.reconnect(delaySecond)
            }
            
            sessionURLTask.resume()
        }
    }
    
    func reconnect(delay: Double) {
        if self.retry > 0 {
            let delayTime = dispatch_time(
                DISPATCH_TIME_NOW,
                Int64(delay * Double(NSEC_PER_SEC))
            )
            dispatch_after(delayTime, dispatch_get_main_queue()) {
                self.connect()
            }

            self.retry = self.retry-1
        }else if let next = fail {
            next()
        }
    }
}