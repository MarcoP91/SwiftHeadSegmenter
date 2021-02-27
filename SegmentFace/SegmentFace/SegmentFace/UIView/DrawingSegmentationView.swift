//
//  DrawingSegmentationView.swift
//  SegmentFace
//
//  Created by Marco Perotti on 09/02/21.
//

import UIKit
import Foundation

class DrawingSegmentationView : UIView {
    static private var colors: [Int32: UIColor] = [:]
    
    // 0: background/misc, 15: person
    private var blackWhiteColor: [Int32: UIColor] = [0: UIColor(red: 255, green: 255, blue: 255, alpha: 1), 15: UIColor(white: 0, alpha: 0)]
    
    func segmentationColor(with index: Int32) -> UIColor {
        if let color = blackWhiteColor[index] {
            return color
        } else {
            let color = UIColor(red: 0, green: 0, blue: 0, alpha: 1)
            blackWhiteColor[index] = color
            return color
        }
    }
    
    var segmentationmap: SegmentationResultMLMultiArray? = nil{
        didSet{
            self.setNeedsDisplay()
        }
    }
    
    var normalizedPoints : [CGPoint]?
    var faceRect : CGRect?
    
//    func handlePoints(points: [CGPoint], w: CGFloat, img_h: CGFloat, rect_h: CGFloat, origin_y: CGFloat) -> CGFloat {
//        let a = points.max { a, b in a.y < b.y }
//
//        let norm_a = origin_y * img_h + a!.y * rect_h
//
//        print("Lowest point: \(norm_a)")
//        return norm_a
//    }
    
    override func draw(_ rect: CGRect) {
        if let ctx = UIGraphicsGetCurrentContext() {
            
            ctx.clear(rect)
            
            guard let segmentationmap = self.segmentationmap else {return}
            
            //let rect_h = bounds.size.height * CGFloat(self.faceRect!.height)
            
            //grab the view w,h and divide it by the segmentationmap w, h
            let size = self.bounds.size
            let segmentationmapWidthSize = segmentationmap.segmentationmapWidthSize
            let segmentationmapHeightSize = segmentationmap.segmentationMapHeightSize
            print("segW: \(segmentationmapWidthSize)")
            print("segH: \(segmentationmapHeightSize)")
            let w = size.width / CGFloat(segmentationmapWidthSize)
            let h = size.height / CGFloat(segmentationmapHeightSize)
            
//            let low = handlePoints(points: self.normalizedPoints!,w: w, img_h: size.height, rect_h : rect_h, origin_y: (self.faceRect?.origin.y)!)
            
            
//            print("W:", w)
            
            for j in 0..<segmentationmapHeightSize{
                for i in 0..<segmentationmapWidthSize{
                    
                    //let value = segmentationmap[j,i].floatValue
                    let value = segmentationmap[j,i].int32Value
                    //print(segmentationmap[0,0,j,i])
                    //print("---")
                    //print(segmentationmap[j,i])
                    //print(value)
                    //create and draw a rect
                    let rect : CGRect = CGRect(x: CGFloat(i) * w, y:CGFloat(j) * h, width: w, height: h)
                    
//                    if value == 15{
//                        print(rect)
//                    }
//                    let color : UIColor
//
//                    if rect.minY > low{
//                         color = segmentationColor(with: 0)
//                    }
//                    else{
//                        color = segmentationColor(with: value)
//                    }
                    let color : UIColor
                    
                    //color = segmentationColor(with: value)
                    
                    if value == 1{
                        //print("COLOR")
                        color = segmentationColor(with: 15)
                    }
                    else{
                        //print("NOT COLOR")
                        color = segmentationColor(with: 0)
                    }
                    
                    color.setFill()
                    UIRectFill(rect)
                }
            }
            
        }
    }
    
}
