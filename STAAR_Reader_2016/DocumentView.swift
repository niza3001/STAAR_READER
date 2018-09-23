//
//  DocumentView.swift
//  STAAR_Reader_2016
//
//  Created by Niloofar Zarei.
//  Copyright © 2016 TEILab. All rights reserved.
//

import Foundation
import UIKit

class DocView: UIView{
    
    //MARK: Properties
    //---------------------------------------------------------------------------------------
    var myPDFDoc: STAAR_PDFDocClass!
    
    
    
    //MARK: Variables
    //---------------------------------------------------------------------------------------
    var currentPage = 1
    
    //MARK: Initialization
    //---------------------------------------------------------------------------------------
    override init(frame: CGRect) {
        super.init(frame: frame)
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }
    
    
    //MARK: Functions
    //---------------------------------------------------------------------------------------
    //This fn changes the coord system from iOS to PDF
    func coordFlipper(context: CGContext, scale: CGFloat) {
        context.translateBy(x: 0.0, y: self.bounds.size.height - 10)
        context.scaleBy(x: 1.0, y: -1.0)
        context.scaleBy(x: scale, y: scale)
    }
    
    func getPDFScale(aPage: CGPDFPage) -> (CGFloat){
        let pageRect: CGRect = aPage.getBoxRect(CGPDFBox.mediaBox)
        let scale: CGFloat = min(self.bounds.size.width / pageRect.size.width , self.bounds.size.height / pageRect.size.height)
        return scale
    }
    
    func displayPDF(context: CGContext, currentPage: Int){
        let thisPageInfo = myPDFDoc.PDFPages[currentPage]
        let thisPage = thisPageInfo.myPage
        let thisScale = getPDFScale(aPage: thisPage!)
        context.saveGState()
        coordFlipper(context: context, scale: thisScale)
        context.drawPDFPage(thisPage!)
        context.restoreGState()
    }
    
    func CGRectMake(_ x: CGFloat, _ y: CGFloat, _ width: CGFloat, _ height: CGFloat) -> CGRect {
        return CGRect(x: x, y: y, width: width, height: height)
    }
    
    
    
    func drawRectangles(context: CGContext){
        //        var rects: [CGRect] = []
        //            rects.append(CGRectMake(295.643420820719, 192.654208, 23.3559287998183, 21.174696))
        //            rects.append(CGRectMake(691.715471224448, 324.637408, 23.3559287998185, 21.174696))
        //            rects.append(CGRectMake(448.280857611227, 500.615008, 23.3559287998185, 21.174696))
        //            rects.append(CGRectMake(365.955890098391, 544.609408, 15.9236280000001, 21.174696))
        //            rects.append(CGRectMake(511.70392232308, 632.598208, 53.0736623994555, 21.174696))
        //            rects.append(CGRectMake(693.60222038516, 720.587008, 18.056973599637, 21.174696))
        //            rects.append(CGRectMake(835.180891758173, 764.581408, 23.3559287998186, 21.174696))
        //            rects.append(CGRectMake(609.184052684294, 984.553408, 15.3998495996368, 21.174696))
        //            rects.append(CGRectMake(460.438633532644, 1116.536608, 50.963256, 21.174696))
        //            rects.append(CGRectMake(819.66650547117, 1116.536608, 32.9101055996368, 21.174696))
        //            rects.append(CGRectMake(57.481, 1160.53097612, 46.184256, 21.174696))
        //            rects.append(CGRectMake(894.329778434297, 324.637408, 23.3559287998183, 21.174696))
        //            rects.append(CGRectMake(57.481, 368.631808, 55.2031847998184, 21.174696))
        
        
        //let rect = CGRectMake(57.4809989929199, 115.252754211426, 849.58003616333, 1055.87114715576)
        let rect = CGRectMake(47.4809989929199, 100.252754211426, 869.58003616333, 1075.87114715576)
        context.saveGState()
        context.setStrokeColor(UIColor.yellow.cgColor)
        context.setLineWidth(3)
        //guide - func setFillColor(red: CGFloat,green: CGFloat,blue: CGFloat,alpha: CGFloat)
        //context.setFillColor(UIColor.yellow.cgColor)
        context.stroke(rect)
        //context.fill(rects)
        context.restoreGState()
    }
    
    
    
    override func draw(_ rect: CGRect) {
        super.draw(rect)
        self.myPDFDoc = STAAR_PDFDocClass(thisPath: DocAreaController().filepath)
        self.myPDFDoc.GetPDFPages()
        self.myPDFDoc.PDFPages[currentPage - 1].setPageWordsDetails()
        let context = UIGraphicsGetCurrentContext()!
        displayPDF(context: context, currentPage: currentPage - 1)
        //drawRectangles(context: context)
    }
    
    
}
