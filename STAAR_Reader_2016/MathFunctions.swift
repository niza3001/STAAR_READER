//
//  MathFunctions.swift
//  STAAR_Reader_2016
//
//  Created by Niloofar Zarei.
//  Copyright © 2016 TEILab. All rights reserved.
//

import Foundation
import UIKit


class MathFuncs{
    
    static let instance = MathFuncs()
    
    func dotProduct(firstPoint: CGPoint, secondPoint: CGPoint, thirdPoint: CGPoint) -> CGFloat{
        let result: CGFloat = (secondPoint.x-firstPoint.x)*(thirdPoint.x-secondPoint.x) + (secondPoint.y-firstPoint.y)*(thirdPoint.y-secondPoint.y)
        return result
    }
    
    func crossProduct(firstPoint: CGPoint, secondPoint: CGPoint, thirdPoint: CGPoint) -> CGFloat {
        let result: CGFloat = (secondPoint.x-firstPoint.x)*(thirdPoint.y-firstPoint.y) - (secondPoint.y-firstPoint.y)*(thirdPoint.x-firstPoint.x)
        return result
    }
    
    func distanceBetween2Points(firstPoint: CGPoint, secondPoint: CGPoint) -> CGFloat{
        let distance: CGFloat = sqrt((firstPoint.x-secondPoint.x)*(firstPoint.x-secondPoint.x)+(firstPoint.y-secondPoint.y)*(firstPoint.y-secondPoint.y))
        return distance
    }
    
    func distanceBetweenLineAndPoint(aSegment: segment, aPoint:CGPoint) -> CGFloat{
        let dot1: CGFloat = self.dotProduct(firstPoint: aSegment.startPoint, secondPoint: aSegment.endPoint, thirdPoint: aPoint)
        if (dot1 > 0){
            return self.distanceBetween2Points(firstPoint: aSegment.endPoint, secondPoint: aPoint)
        }
        let dot2: CGFloat = self.dotProduct(firstPoint: aSegment.endPoint, secondPoint: aSegment.startPoint, thirdPoint: aPoint)
        if (dot2 > 0){
            return self.distanceBetween2Points(firstPoint: aSegment.startPoint, secondPoint: aPoint)
        }
        let dist: CGFloat = self.crossProduct(firstPoint: aSegment.startPoint, secondPoint: aSegment.endPoint, thirdPoint: aPoint)/self.distanceBetween2Points(firstPoint: aSegment.startPoint, secondPoint: aSegment.endPoint)
        return fabs(dist)
    }
    
}
