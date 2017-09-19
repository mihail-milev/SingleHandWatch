//
//  InterfaceController.swift
//  SingleHandWatch WatchKit Extension
//
//  Created by Mihail Milev on 03.09.17.
//  Copyright © 2017 Mihail Milev. All rights reserved.
//

import WatchKit
import Foundation


class InterfaceController: WKInterfaceController {

    @IBOutlet weak var handImageContainer: WKInterfaceImage?
    @IBOutlet weak var watchfaceContainer: WKInterfaceGroup?
    
    var syncTimerObj : Timer?
    var fireTimerObj : Timer?
    
    var lib : Lib?
    
    override init() {
        super.init()
        lib = Lib(withFinalFunction: self.setImg)
    }
    
    override func awake(withContext context: Any?) {
        super.awake(withContext: context)
        
        // Configure interface objects here.
    }
    
    override func willActivate() {
        // This method is called when watch view controller is about to be visible to user
        super.willActivate()
        
        let extDelegate : ExtensionDelegate? = WKExtension.shared().delegate as? ExtensionDelegate
        if let delegate : ExtensionDelegate = extDelegate {
            while(delegate.backgr == nil) { }
            if let wC : WKInterfaceGroup = watchfaceContainer {
                wC.setBackgroundImage(delegate.backgr)
            }
            while(delegate.arrow == nil) { }
            if let img : UIImage = delegate.arrow {
                self.setImg(img: img)
            }
            syncTimerObj = Timer.scheduledTimer(timeInterval: 1, target: self, selector: #selector(self.syncTimer), userInfo: nil, repeats: true)
        }
    }
    
    override func didAppear() {
        super.didAppear()
    }
    
    override func didDeactivate() {
        // This method is called when watch view controller is no longer visible
        super.didDeactivate()
        
        if let fTO : Timer = fireTimerObj {
            fTO.invalidate()
            fireTimerObj = nil
        }
        
        if let sTO : Timer = syncTimerObj {
            sTO.invalidate()
            syncTimerObj = nil
        }
    }
    
    func syncTimer(sender:Timer) {
        let date : Date = Date()
        let calendar : Calendar = Calendar.current
        let second : Int = calendar.component(.second, from: date)
        
        if(second == 0) {
            fireTimerObj = Timer.scheduledTimer(timeInterval: 60, target: lib!, selector: #selector(Lib.getTimeAndDraw), userInfo: nil, repeats: true)
            sender.invalidate()
            if let lb : Lib = lib {
                lb.getTimeAndDraw()
            }
        }
    }
    
    func setImg(img:UIImage) {
        if let hIC : WKInterfaceImage = handImageContainer {
            hIC.setImage(img)
        }
    }

}
