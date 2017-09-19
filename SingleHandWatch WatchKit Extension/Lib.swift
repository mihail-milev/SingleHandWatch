//
//  Lib.swift
//  SingleHandWatch
//
//  Created by Mihail Milev on 05.09.17.
//  Copyright © 2017 Mihail Milev. All rights reserved.
//

import Foundation
import WatchKit

class Lib {
    
    let tobecalled : (UIImage) -> Void
    
    init(withFinalFunction fnc: @escaping (UIImage) -> Void) {
        self.tobecalled = fnc
    }
    
    @objc func getTimeAndDraw() {
        let date : Date = Date()
        let calendar : Calendar = Calendar.current
        let hour : Int = calendar.component(.hour, from: date)
        let minutes : Int = calendar.component(.minute, from: date)
        drawHand(hour: UInt8(hour), minute: UInt8(minutes))
    }
    
    func drawHand(hour:UInt8, minute:UInt8) {
        let deg : Double = 360.0 * (Double(hour) * 60.0 + Double(minute)) / (23.0 * 60.0 + 60)
        performDrawing(deg: deg)
    }
    
    func performDrawing(deg:Double) {
        UIGraphicsBeginImageContextWithOptions(CGSize(width:312, height:312), false, 1.0)
        guard let context : CGContext = UIGraphicsGetCurrentContext() else {
            UIGraphicsEndImageContext()
            return
        }
        
        drawDateWeek(withContext: context)
        
        context.translateBy (x: 156, y: 156);
        context.rotate (by: CGFloat(deg * .pi / 180.0));
        
        context.setFillColor(UIColor.init(red: 227.0/255.0, green: 162.0/255.0, blue: 56.0/255.0, alpha: 1.0).cgColor)
        context.fill(CGRect(x: -2, y: 0, width: 4, height: 85))
        context.fill(CGRect(x: -1, y: 0, width: 2, height: 150))
        context.fillEllipse(in: CGRect(x: -6, y: -6, width: 12, height: 12))
        
        let image : UIImage? = UIGraphicsGetImageFromCurrentImageContext()
        
        UIGraphicsEndImageContext()
        
        if let img : UIImage = image {
            tobecalled(img)
        }
    }
    
    func drawDateWeek(withContext context: CGContext) {
        context.saveGState()
        let transf : CGAffineTransform = CGAffineTransform.init(a: 1, b: 0, c: 0, d: -1, tx: 0, ty: 0)
        context.concatenate(transf);
        
        context.setFillColor(UIColor.white.cgColor)
        context.fill(CGRect(x: 0, y: 0, width: 156, height: 156))
        
        let date : Date = Date()
        let calendar : Calendar = Calendar.current
        let day : Int = calendar.component(.day, from: date)
        let month : Int = calendar.component(.month, from: date)
        let week : Int = calendar.component(.weekOfYear, from: date)
        let text : String = String(format: "%02u.%02u / %02u", day, month, week)
        
        let fnc : (CGSize) -> (CGPath) = {(textSize : CGSize) -> (CGPath) in
            return CGPath(rect: CGRect(x: 156.0 - ceil(textSize.width) / 2.0, y: -156.0 - 2.4 * ceil(textSize.height), width: ceil(textSize.width), height: ceil(textSize.height)), transform:nil)
        }
        
        drawText(text, inContext: context, withSize: 24, withWhite: 0.5, withPathFunction: fnc)
        
        context.restoreGState()
    }
    
    func drawText(_ text: String, inContext context : CGContext, withSize size : CGFloat, withWhite white : CGFloat, withPathFunction fnc : (CGSize) -> (CGPath)) {
        let textAttributes2: [String: AnyObject] = [
            NSForegroundColorAttributeName : UIColor(white: white, alpha: 1.0).cgColor,
            NSFontAttributeName : UIFont.systemFont(ofSize: size)
        ]
        let attributedString : NSAttributedString = NSAttributedString(string: text, attributes: textAttributes2)
        let textSize : CGSize = text.size(attributes: textAttributes2)
        let textPath : CGPath = fnc(textSize)
        let frameSetter : CTFramesetter = CTFramesetterCreateWithAttributedString(attributedString)
        let frame : CTFrame = CTFramesetterCreateFrame(frameSetter, CFRange(location: 0, length: attributedString.length), textPath, nil)
        
        CTFrameDraw(frame, context)
    }
}
