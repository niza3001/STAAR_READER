//
//  PDFModel.swift
//  STAAR_Reader_2016
//
//  Created by Niloofar Zarei.
//  Copyright © 2016 TEILab. All rights reserved.
//

import Foundation
import UIKit
//import QuartzCore

//MARK: Structures
//____________________________________________________________________________________

struct segment{
    var startPoint = CGPoint()
    var endPoint = CGPoint()
    
    init(startpoint: CGPoint, endpoint: CGPoint){
        self.startPoint = startpoint
        self.endPoint = endpoint
    }
}

struct pageWordsDetails {
    var mySelections: NSArray
    var pageTextString: String
    var words: [String]
    var wordBBoxArray: [CGRect] = []
    
    init(){
        mySelections = []
        pageTextString = ""
        words = []
    }
    
}

//MARK: Classes
//____________________________________________________________________________________

class STAAR_Wordclass {
    
    //MARK: Properties
    //____________________________________________
    
    let id: Int64
    var wordBBox: CGRect!
    var wordString: String!
    var wordSegment: segment!
    
    
    //MARK: Initialization
    //____________________________________________
    
    init(thisid: Int64,str: String, bbox: CGRect, startpoint: CGPoint, endpoint: CGPoint) {
        self.id = thisid
        self.wordString = str
        self.wordBBox = bbox
        self.wordSegment = segment.init(startpoint: startpoint, endpoint: endpoint)
    }
    
    //MARK: Functions
    //____________________________________________
    
    func doesMatch(inputString: String) -> Bool {
        
        if (self.wordString == inputString){
            return true
        }
        else{
            return false
        }
    }
}

class STAAR_Lineclass{
    
    //MARK: Properties
    //____________________________________________
    var lineNum: Int = 1
    var lineYvalue: CGFloat = 0
    let lineWords: [STAAR_Wordclass] = []
}

class STAAR_PDFPageClass {
    
    //MARK: Properties
    //____________________________________________
    var myPage: CGPDFPage!
    var pageNum: Int
    var pageWords: [STAAR_Wordclass] = []
    let myScanner: Scanner2
    var myPageWordsDetails: pageWordsDetails = pageWordsDetails.init()
    var pageLines: [STAAR_Lineclass] = []
    
    //MARK: Initialization
    //____________________________________________
    
    init(aPDFDoc: CGPDFDocument!,aPageNum: Int){
        self.myPage = aPDFDoc.page(at: aPageNum)
        self.pageNum = aPageNum
        self.myScanner = Scanner2(page: self.myPage)
    }
    
    
    //MARK: Functions
    //____________________________________________
    
    func setPageWordsDetails(){
        myPageWordsDetails.mySelections = myScanner.select(" ") as NSArray
        let pageTextString = myScanner.getPageText()!
        myPageWordsDetails.words = pageTextString.components(separatedBy: " ")
        var transformedRects: [CGRect] = []
        
        for object in myPageWordsDetails.mySelections{
            let rect: CGRect = (object as AnyObject).frame.applying((object as AnyObject).transform)
            let x = rect.origin.x*(1.176 as CGFloat) + 1.041
            let y = rect.origin.y*(-1.174 as CGFloat) + 942.7
            let w = rect.width * 1.176
            let h = rect.height * 1.174
            
            let transformedRect = CGRect(x: x,y: y,width: w,height: h)
            transformedRects.append(transformedRect)
        }
        
        for word in myPageWordsDetails.words{
            let counter = word.characters.count
            
            if counter == 0 {continue}
            var wordCharsRect: [CGRect] = []
            var aRect : CGRect
            for _ in 1...counter{
                if !(transformedRects.isEmpty){
                    aRect = transformedRects.removeFirst()
                    wordCharsRect.append(aRect)
                    
                }
            }
            
            if (wordCharsRect.count == counter){
                var tempRect = wordCharsRect.removeFirst()
                if counter == 1 {
                    myPageWordsDetails.wordBBoxArray.append(tempRect)
                    continue
                }
                for _ in 1...(counter-1){
                    let tempRect2 = wordCharsRect.removeFirst()
                    tempRect = tempRect.union(tempRect2)
                }
                myPageWordsDetails.wordBBoxArray.append(tempRect)
            }
        }
        
        //for BBox in myPageWordsDetails.wordBBoxArray{
        
    }
}



class STAAR_PDFDocClass {
    
    //MARK: Properties
    //____________________________________________
    let PDFdoc: CGPDFDocument!
    var PDFPages: [STAAR_PDFPageClass] = []
    var PDFPath: String
    
    
    //MARK: Initialization
    //____________________________________________
    init(thisPath:String){
        self.PDFPath = thisPath
        self.PDFdoc = CGPDFDocument(URL(fileURLWithPath: thisPath) as CFURL)
        
    }
    
    //MARK: Functions
    //____________________________________________
    func GetPDFPages(){
        for index in 1...(PDFdoc.numberOfPages) {
            let aPage = STAAR_PDFPageClass(aPDFDoc: PDFdoc, aPageNum: index)
            self.PDFPages.append(aPage)
        }
    }
    
}

//extension UIButton {
//    override open var isHighlighted: Bool {
//        get {
//            return super.isHighlighted
//        }
//        set {
//            if newValue {
//                backgroundColor = UIColor.yellow.withAlphaComponent(0.5)
//            }
//            else {
//                backgroundColor = UIColor.clear
//            }
//            super.isHighlighted = newValue
//        }
//    }
//
//}

