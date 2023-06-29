//
//  GraphView.swift
//  GetColor
//
//  Created by HuongLam on 27/01/2023.
//

import Foundation
import UIKit


class GraphView: UIView
{
    
    // graph dimensions
    // put up here as globals so we only have to calculate them one time
    var area: CGRect!
    var maxPoints: Int!
    var height: CGFloat!
    var scale:Float = 1.0

    
    // incoming data to graph
    var dataArrayX:[CGFloat]!
    
    
    
    required init?( coder aDecoder: NSCoder ){ super.init(coder: aDecoder) }
    
    override init(frame:CGRect){ super.init(frame:frame) }
    
    
    
    func setupGraphView() {
        
        area = frame
        maxPoints = Int(area.size.width)
        height = CGFloat(area.size.height)
        
        dataArrayX = [CGFloat](repeating: 0.0, count:maxPoints)
        scale = Float(area.height) * 200
        
    }
    
    
    
    
    
    
    
    func addX(x: Float){
        
        
        // scale incoming data and insert it into data array
        let xScaled = CGFloat((x * scale).truncatingRemainder(dividingBy: Float(height)) )
        
        dataArrayX.insert(xScaled, at: 0)
        dataArrayX.removeLast()
        
        setNeedsDisplay()
    }
    
    
    
    override func draw(_ rect: CGRect) {
        
        let context = UIGraphicsGetCurrentContext()
        context!.setStrokeColor([1.0, 0.0, 0.0, 1.0])
        
        for i in 1..<maxPoints {
            
            let mark = CGFloat(i)
            
            // plot x
            context?.move(to: CGPoint(x: mark-1, y: self.dataArrayX[i-1] ))
            context?.addLine(to: CGPoint(x: mark, y: self.dataArrayX[i]))
        
            context!.setLineWidth(2.0)
            context!.strokePath()
                        
        }
    }
    
}




