//
//  ExtensionDelegate.swift
//  SingleHandWatch WatchKit Extension
//
//  Created by Mihail Milev on 03.09.17.
//  Copyright © 2017 Mihail Milev. All rights reserved.
//

import WatchKit

class ExtensionDelegate: NSObject, WKExtensionDelegate {
    
    var backgr: UIImage?
    var arrow: UIImage?

    func applicationDidFinishLaunching() {
        // Perform any final initialization of your application.
        //NSLog("App did finish launching")
        handleBackgroundDraw()
        handleArrowDraw()
    }

    func applicationDidBecomeActive() {
        // Restart any tasks that were paused (or not yet started) while the application was inactive. If the application was previously in the background, optionally refresh the user interface.
        //NSLog("App did become active")
    }

    func applicationWillResignActive() {
        // Sent when the application is about to move from active to inactive state. This can occur for certain types of temporary interruptions (such as an incoming phone call or SMS message) or when the user quits the application and it begins the transition to the background state.
        // Use this method to pause ongoing tasks, disable timers, etc.
    }
    
    func applicationWillEnterForeground() {
        //NSLog("App will enter foreground")
        handleBackgroundDraw()
        handleArrowDraw()
    }

    func handle(_ backgroundTasks: Set<WKRefreshBackgroundTask>) {
        // Sent when the system needs to launch the application in the background to process tasks. Tasks arrive in a set, so loop through and process each one.
        for task in backgroundTasks {
            // Use a switch statement to check the task type
            switch task {
            case let backgroundTask as WKApplicationRefreshBackgroundTask:
                // Be sure to complete the background task once you’re done.
                backgroundTask.setTaskCompleted()
            case let snapshotTask as WKSnapshotRefreshBackgroundTask:
                // Snapshot tasks have a unique completion call, make sure to set your expiration date
                snapshotTask.setTaskCompleted(restoredDefaultState: true, estimatedSnapshotExpiration: Date.distantFuture, userInfo: nil)
            case let connectivityTask as WKWatchConnectivityRefreshBackgroundTask:
                // Be sure to complete the connectivity task once you’re done.
                connectivityTask.setTaskCompleted()
            case let urlSessionTask as WKURLSessionRefreshBackgroundTask:
                // Be sure to complete the URL session task once you’re done.
                urlSessionTask.setTaskCompleted()
            default:
                // make sure to complete unhandled task types
                task.setTaskCompleted()
            }
        }
    }
    
    private func handleBackgroundDraw() {
        backgr = nil
        DispatchQueue.global().async {
            self.actionDrawBackground()
        }
    }
    
    private func handleArrowDraw() {
        arrow = nil
        DispatchQueue.global().async {
            self.actionDrawArrow()
        }
    }
    
    private func actionDrawBackground() {
        //NSLog("drawing")
        
        UIGraphicsBeginImageContextWithOptions(CGSize(width:312, height:312), false, 1.0)
        guard let context : CGContext = UIGraphicsGetCurrentContext() else {
            UIGraphicsEndImageContext()
            return
        }
        
        context.translateBy (x: 156, y: 156)
        
        drawSlashesAndDots(inContext: context)
        
        drawTextHours(inContext: context)
        
        backgr = UIGraphicsGetImageFromCurrentImageContext()
        
        UIGraphicsEndImageContext()
    }
    
    private func drawSlashesAndDots(inContext context : CGContext) {
        for i in 0...95 {
            context.setFillColor(UIColor.white.cgColor)
            if(i % 4 == 0) {
                if((i == 0) || (i == 24) || (i == 48) || (i == 72)) {
                    context.setFillColor(UIColor.init(red: 227.0/255.0, green: 162.0/255.0, blue: 56.0/255.0, alpha: 1.0).cgColor)
                    context.fill(CGRect(x: -2, y: 116, width: 4, height: 40))
                } else {
                    context.fill(CGRect(x: -2, y: 131, width: 4, height: 25))
                }
            } else if((i % 4 == 1) || (i % 4 == 3)) {
                context.fillEllipse(in: CGRect(x: -2, y: 152, width: 4, height: 4))
            } else {
                context.fill(CGRect(x: -1, y: 136, width: 2, height: 20))
            }
            context.rotate (by: CGFloat(3.75 * .pi / 180.0));
        }
        context.rotate (by: CGFloat(3.75 * .pi / 180.0));
    }
    
    private func drawTextHours(inContext context : CGContext) {
        context.rotate (by: CGFloat(176.5 * .pi / 180.0));
        let transf : CGAffineTransform = CGAffineTransform.init(a: -1, b: 0, c: 0, d: 1, tx: 0, ty: 0)
        context.concatenate(transf);
        
        let r : CGFloat = 100.0
        
        let lib : Lib = Lib(withFinalFunction: { (img:UIImage) -> Void in })
        
        for i in 0...23 {
            let theta : CGFloat = CGFloat(CGFloat(i+6) * -15.0 * .pi / 180.0)
            let x : CGFloat = cos(theta) * r
            let y : CGFloat = sin(theta) * r
            let fnc : (CGSize) -> (CGPath) = {(textSize : CGSize) -> (CGPath) in
                return CGPath(rect: CGRect(x: x - ceil(textSize.width) / 2.0, y: y - ceil(textSize.height) / 2.0, width: ceil(textSize.width), height: ceil(textSize.height)), transform:nil)
            }
            let text : String = String(format: "%u", i)
            
            lib.drawText(text, inContext: context, withSize: 17, withWhite: 1.0, withPathFunction: fnc)
        }
    }
    
    private func actionDrawArrow() {
        let lib : Lib = Lib(withFinalFunction: { (img:UIImage) -> Void in
            self.arrow = img
        })
        lib.getTimeAndDraw()
    }
}
