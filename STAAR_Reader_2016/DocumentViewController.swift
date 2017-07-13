//
//  DocumentViewController.swift
//  STAAR_Reader_2016
//
//  Created by Niloofar Zarei.
//  Copyright © 2016 TEILab. All rights reserved.
//

import Foundation
import UIKit
import CoreGraphics
import AVFoundation


class DocAreaController: UIViewController, AVAudioPlayerDelegate  {
    
    //MARK: Properties
    //---------------------------------------------------------------------------------------
    @IBOutlet var docView: DocView!
    let filepath = (Bundle.main.path(forResource: "Demo", ofType: "pdf", inDirectory: "Demo"))! as String
    let datapath = (Bundle.main.path(forResource: "Demo_12.9_Data", ofType: "csv", inDirectory: "Demo"))! as String
    let clickPath = (Bundle.main.path(forResource: "click", ofType: "wav"))! as String
    let initAudioPath = (Bundle.main.path(forResource: "click", ofType: "wav"))! as String
    
    //MARK: Variables
    //---------------------------------------------------------------------------------------
    var nextArticlePressed = false
    var nextPagePressed = false
    var previousPagePressed = false
    var speaker = AVAudioPlayer()
    let speechSynthesizer = AVSpeechSynthesizer()
    var data:[[String:String]] = []
    var dataArray = [[String]]()
    var columnTitles:[String] = []
    var error:NSError?
    var words: [String] = []
    var prevID: Int = 0
    var startTime: TimeInterval = 0
    var currentWordID = 0
    var historyID = -1
    var historyOfHistoryID = -1
    var rate: Float = 1.0
    var _click: Bool = false
    var wordClick = AVAudioPlayer()
    var touchLoc = CGPoint(x : 0,y : 0)
    var currentTouch = UITouch()
    var _first: Bool = true
    var hotSpots: [CGFloat] = []
    var textRect = CGRect()
    var whiteStaticPlayer = AVAudioPlayer()
    var pinkStaticPlayer = AVAudioPlayer()
    var whiteSpacePlayer = AVAudioPlayer()
    var EOLPlayer = AVAudioPlayer()
    var gutterFlag = 2
    var EOLWords: [String] = []
 
    
    //MARK: Actions
    //---------------------------------------------------------------------------------------
    @IBAction func PrevPageBtn(_ sender: Any) {
        if (self.docView.currentPage>1 && self.previousPagePressed == true){
            self.docView.currentPage -= 1
            let phrase = "page \(self.docView.currentPage)"
            let utterance = AVSpeechUtterance(string: phrase)
            self.docView.setNeedsDisplay()
            self.speechSynthesizer.speak(utterance)
            self.previousPagePressed = false
        }
        else if (self.previousPagePressed == false){
            let phrase =  "Previous page"
            let utterance = AVSpeechUtterance(string: phrase)
            self.speechSynthesizer.speak(utterance)
            self.previousPagePressed = true
        }
        else if (self.docView.currentPage==1)&&(self.previousPagePressed == true){
            let phrase =  "This is the first page."
            let utterance = AVSpeechUtterance(string: phrase)
            self.previousPagePressed = false
            self.speechSynthesizer.speak(utterance)
        }
    }
    
    @IBAction func NxtPageBtn(_ sender: Any) {
        if (self.docView.currentPage+1<=self.docView.myPDFDoc.PDFPages.count && self.nextPagePressed == true){
            self.docView.currentPage += 1
            let phrase = "page \(self.docView.currentPage)"
            let utterance = AVSpeechUtterance(string: phrase)
            self.docView.setNeedsDisplay()
            self.speechSynthesizer.speak(utterance)
            self.nextPagePressed = false
        }
        else if (self.nextPagePressed == false){
            let phrase =  "Next page"
            let utterance = AVSpeechUtterance(string: phrase)
            self.speechSynthesizer.speak(utterance)
            self.nextPagePressed = true
        }
        else if (self.docView.currentPage==self.docView.myPDFDoc.PDFPages.count)&&(self.nextPagePressed == true){
            let phrase =  "This is the last page."
            let utterance = AVSpeechUtterance(string: phrase)
            self.nextPagePressed = false
            self.speechSynthesizer.speak(utterance)
        }
    }
    
    
    //MARK: Functions
    //---------------------------------------------------------------------------------------
    // [0]ID,[1]WORD,[2]POSWX,[3]POSLY,[4]LENGTH,[5]LINE,[6]PAGE,[7]DURATION,[8]AUDIOSLOW,[9]AUDIONORMAL,[10]AUDIOFAST
    func handleTouchMoving(currentTouch: UITouch, currentLoc: CGPoint){
        let currentLineIndex = self.findNearestLineInd(yTouch: currentLoc.y)
        let currentWordIndex = self.findNearestWordInd(line: currentLineIndex , loc: currentLoc) //x: currentLoc.x)
        if currentWordIndex != self.currentWordID {
            self.rate = calculateTimeBudget(touch: currentTouch, id: currentWordIndex)
            self.currentWordID = currentWordIndex
        }
        if currentWordIndex == self.prevID {}
        else if currentWordIndex > prevID+1 {
            self.enqueueClick(id: currentWordIndex)
            //self.prevID+=1
        }
        else if currentWordIndex == prevID+1 {
            enqueueWord(id: currentWordIndex)
            //dequeueWord(Rate: self.rate)
        }
        self.gutterFlag = self.amIstraying(touch: currentTouch)
        debugPrint("@@@ gutterFlag is \(self.gutterFlag)")
    }
    
    
    func returnFromPlay(currentTouch: UITouch, currentLoc: CGPoint){
        if self.speaker.prepareToPlay() {
            while self.speaker.isPlaying == true {}
        }
        else if self.wordClick.prepareToPlay(){
            while self.wordClick.isPlaying == true {}
        }
        
        //else if words[0] == clickPath { dequeueWord(Rate: self.rate) }
        let currentLineIndex = self.findNearestLineInd(yTouch: currentLoc.y)
        let currentWordIndex = self.findNearestWordInd(line: currentLineIndex , loc: currentLoc) //x: currentLoc.x)
        self.rate = calculateTimeBudget(touch: currentTouch, id: currentWordIndex)
        debugPrint("I am handling return from play current ID is\(currentWordIndex)")
        self.gutterFlag = self.amIstraying(touch: currentTouch)
        debugPrint("@@@ gutterFlag is \(self.gutterFlag)")
        if currentWordIndex==0 {}
        else if currentWordIndex != 0 && (currentWordIndex-prevID)>1 && 10>(currentWordIndex-prevID){
            let i = currentWordIndex-self.prevID-1
            debugPrint("the number of clicks are \(i)")
            //for _ in 1...i{
            //self.enqueueClick(id: currentWordIndex)
            //self.currentWordID+=1
            self.wordClick.numberOfLoops = i
            self.wordClick.prepareToPlay()
            self.wordClick.play()
            self.prevID = currentWordIndex
            //dequeueWord(Rate: self.rate)
        }
        else {
            //self.rate = calculateTimeBudget(touch: currentTouch, id: currentWordIndex)
            self.currentWordID = currentWordIndex
            enqueueWord(id: currentWordIndex)
            
        }
        debugPrint(self.rate)
        dequeueWord(Rate: self.rate)
    }
    
    
    func handleTouchStationary(currentTouch: UITouch, currentLoc: CGPoint){
        let currentLineIndex = self.findNearestLineInd(yTouch: currentLoc.y)
        debugPrint(currentLineIndex)
        let currentWordIndex = self.findNearestWordInd(line: currentLineIndex , loc: currentLoc) //x: currentLoc.x)
        debugPrint("I am handling stationary touch current ID is\(currentWordIndex)")
        self.enqueueWord(id: currentWordIndex)
        
    }
    
    
    func findNearestLineInd(yTouch: CGFloat) -> Int{
        var diff : CGFloat = -1
        var ind = 0
        // debugPrint("*****hotspots is \(self.hotSpots)")
        for hotspot in self.hotSpots{
            let diff2 = abs(hotspot - yTouch)
            //debugPrint("*****diff2 is \(diff2)")
            if diff<0 || diff2<diff {
                diff = diff2
                ind = self.hotSpots.index(of: hotspot)!
            }}
        //debugPrint("current line index is \(ind)")
        return ind+1
    }
    
    func amITouchingWhiteSpace(touch: CGPoint)->Bool{
        if !(self.textRect.contains(touch)){
            return true
        }
        else{return false}
    }
    
    func findNearestWordInd(line: Int, loc: CGPoint)-> Int{
        var ind : Int = 0
        
        var diff : CGFloat = -1
        for dataRow in dataArray{
            
            if dataRow[5] == "\(line)" && dataRow[6] == "\(self.docView.currentPage)"{
                let wordSegment = SegmentMake(CGFloat(NSString(string: dataRow[2]).floatValue), CGFloat(NSString(string: dataRow[3]).floatValue), CGFloat(NSString(string: dataRow[2]).floatValue+NSString(string: dataRow[4]).floatValue), CGFloat(NSString(string: dataRow[3]).floatValue))
                let newdiff = MathFuncs.instance.distanceBetweenLineAndPoint(aSegment: wordSegment, aPoint: loc)
                let tInd = NSString(string: dataRow[0]).integerValue
                if newdiff<diff || diff<0 {
                    diff = newdiff
                    ind = tInd
                }
            }
        }
        return ind
    }
    
    // [0]ID,[1]WORD,[2]POSWX,[3]POSLY,[4]LENGTH,[5]LINE,[6]PAGE,[7]DURATION,[8]AUDIOSLOW,[9]AUDIONORMAL,[10]AUDIOFAST
    func calculateTimeBudget(touch: UITouch, id: Int) -> Float{
        var wordTimeBudget: Float = 0
        var length: Float = 0
        var xStart: Float = 0
        var xEnd: Float = 0
        var nextWordStart : Float = 0
        var whiteSpaceLength: Float = 0
        var lineNumber: Int = 0
        var customRate:Float
        for dataRow in self.dataArray{
            if dataRow[0] == "\(id)"{
                wordTimeBudget = NSString(string: dataRow[7]).floatValue
                length = NSString(string: dataRow[4]).floatValue
                xStart = NSString(string: dataRow[2]).floatValue
                lineNumber = NSString(string: dataRow[5]).integerValue
                xEnd = xStart + length
            }
            if (dataRow[0] == "\(id+1)" && dataRow[5] == "\(lineNumber)"){
                nextWordStart = NSString(string: dataRow[2]).floatValue
                whiteSpaceLength = nextWordStart - xEnd
            }
        }
        debugPrint("word time budget T total \(wordTimeBudget)")
        debugPrint("word length X total \(length)")
        debugPrint("word start x position \(xStart)")
        debugPrint("whiteSpaceLength \(whiteSpaceLength)")
        let prevLoc = touch.previousLocation(in: self.docView)
        let prevTimeStamp = touch.timestamp
        let currLoc = touch.location(in: self.docView)
        let distance =  currLoc.x - prevLoc.x
        let timeTaken = prevTimeStamp - self.startTime
        let velocity = Float(distance)/Float(timeTaken)
        let distanceLeft = Float(xEnd) - Float(currLoc.x)
        var timeIneed: Float = 0
        var tBudgetRatio: Float = 5
        if  distanceLeft>0{
            timeIneed = distanceLeft/velocity
            tBudgetRatio = timeIneed/wordTimeBudget
        }
        debugPrint("X2 \(currLoc)")
        debugPrint("X1 \(prevLoc)")
        debugPrint("X2-X1 \(distance)")
        debugPrint("T2 \(prevTimeStamp)")
        debugPrint("T1 \(startTime)")
        debugPrint("T2-T1 \(timeTaken)")
        debugPrint("xEnd \(xEnd)")
        debugPrint("distance left to go \(Float(xEnd) - Float(currLoc.x))")
        debugPrint("Velocity \(velocity)")
        debugPrint("time budget \(timeIneed)")
        debugPrint("timebudgetratio\(tBudgetRatio)")
        self.startTime = prevTimeStamp
//        switch tBudgetRatio {
//        case 0...0.9:
//            customRate = 2
//        case 0.9...1.2:
//            customRate = 2
//        default:
//            customRate = 2
//        }
        if tBudgetRatio<1{customRate = 1}
        else if tBudgetRatio>1 && tBudgetRatio<2 {customRate = tBudgetRatio}
        else {customRate = 2}
        return customRate
    }
    
    
    
    func enqueueWord(id: Int){
        for dataRow in self.dataArray{
            if dataRow[0] == "\(id)" && self.prevID != id{
                let path = dataRow[8].replacingOccurrences(of: "\r", with: "")
                debugPrint("path is \(path)")
                //let word = dataRow[1]
                self.words.append(path)
                self.prevID = id
            }
            
        }
    }
    
    func enqueueClick(id: Int){
        if self.prevID != id{
            self.words.append(clickPath)
            wordClick.prepareToPlay()
            //self._click = false
            self.prevID = id
        }
    }
    
    func EOLPlay(){
        if self.EOLWords.contains(self.words[0]){
            self.EOLPlayer.play()
        }
    }
    
    func dequeueWord(Rate: Float){
        var wordURL: URL?
        debugPrint("gutter flag is \(self.gutterFlag)")
        if self.words.count>0 {
            do {
                if words[0] == clickPath {
                    
                    wordClick.play()
                    self.words.removeFirst()
                }
                else{
                    //debugPrint(words[0])
                    self.EOLPlay()
                    wordURL = Bundle.main.url(forResource: self.words[0], withExtension: "aiff")
                     debugPrint("@@@@@ word is \(self.words[0])")
                    let wordPath = Bundle.main.path(forResource: self.words[0], ofType: "aiff", inDirectory: "Demo/Demo_AudioFiles")
                    wordURL = URL(fileURLWithPath: wordPath!)
                    
                    debugPrint(wordURL as Any)
                    self.speaker = try AVAudioPlayer(contentsOf: wordURL!)
                    self.speaker.delegate = self
                    self.speaker.enableRate = true
                    self.speaker.volume = 1.0
                    self.speaker.rate = self.rate
                    self.speaker.prepareToPlay()
                    debugPrint("playing")
                    self.speaker.play()
                    if self.words.count>0{
                        self.words.removeFirst()
                    }}//}
            } catch {
                // couldn't load file :(
                self.wordClick.play()
                if self.words.count>0{
                    self.words.removeFirst()
                    debugPrint("can't load file!")
                }
            }
        }}
    
    
    func readDataFromFile(file:String)-> String!{
        guard let filepath = Bundle.main.path(forResource: file, ofType: "csv", inDirectory: "Demo")
            else {
                return nil
        }
        do {
            let contents = try String(contentsOfFile: filepath)
            return contents
        } catch {
            print ("File Read Error")
            return nil
        }
    }
    
    func getStringFieldsForRow(row:String, delimiter:String)-> [String]{
        return row.components(separatedBy: delimiter)
    }
    
    func convertCSV(file:String){
        
        let rows = readDataFromFile(file: file).components(separatedBy: "\n")
        if rows.count > 0 {
            data = []
            self.columnTitles = getStringFieldsForRow(row: rows.first!,delimiter:",")
            for row in rows{
                let fields = getStringFieldsForRow(row: row,delimiter: ",")
                if fields.count != self.columnTitles.count {continue}
                var dataRow = [String:String]()
                for (index,field) in fields.enumerated(){
                    let fieldName = self.columnTitles[index]
                    dataRow[fieldName] = field
                }
                data.append(dataRow)
                //debugPrint(dataRow)
            }
        } else {
            print("No data in file")
        }
        
        for dataRow in data{
            var Row: [String] = []
            Row.append(dataRow["ID"]!)
            Row.append(dataRow["WORD"]!)
            Row.append(dataRow["POSWX"]!)
            Row.append(dataRow["POSLY"]!)
            Row.append(dataRow["LENGTH"]!)
            Row.append(dataRow["LINE"]!)
            Row.append(dataRow["PAGE"]!)
            Row.append(dataRow["DURATION"]!)
            Row.append(dataRow["AUDIOFILE\r"]!)
            dataArray.append(Row)
        }
    }
    
    func amIstraying(touch: UITouch)->Int{
        let distStep = (self.hotSpots[1] - self.hotSpots[0])/4
        debugPrint("@@@ dist is \(distStep)")
        //debugPrint(dist)
        let currentLoc = touch.location(in: self.view)
        debugPrint("@@@ currentLoc is \(currentLoc)")
        let currentLine = self.findNearestLineInd(yTouch: currentLoc.y)
        debugPrint("@@@ currentLine is \(currentLine)")
        //debugPrint("&&&&&&& current y \(currentLoc.y)")
        let prevLoc = touch.previousLocation(in: self.view)
        debugPrint("@@@ prevLoc is \(prevLoc)")
        let prevLine = self.findNearestLineInd(yTouch: prevLoc.y)
        debugPrint("@@@ prevLine is \(prevLine)")
        //debugPrint("&&&&&&& prev y \(prevLoc.y)")
        //debugPrint("&&&&&&& dif \(currentLoc.y-prevLoc.y)")
        let hotspot = self.hotSpots[prevLine-1]
        debugPrint("@@@ hotspot is \(hotspot)")
        debugPrint("@@@ abs(hotspot-currentLoc.y) is \(abs(hotspot-currentLoc.y))")
        if currentLoc.y<prevLoc.y && currentLine==prevLine && abs(hotspot-currentLoc.y)>distStep {
            self.whiteStaticPlayer.play()
            return 1
        }
        if currentLoc.y>prevLoc.y && currentLine==prevLine && abs(currentLoc.y-hotspot)>distStep {
            self.pinkStaticPlayer.play()
            return -1
        }
        else {
            self.pinkStaticPlayer.stop()
            self.whiteStaticPlayer.stop()
            return 0
        }
    }
    
    
    func audioPlayerDidFinishPlaying(_ player: AVAudioPlayer, successfully flag: Bool) {
        debugPrint("audioPlayerDidFinishPlaying")
        if player.isPlaying == false {
            self.returnFromPlay(currentTouch: self.currentTouch, currentLoc: self.touchLoc)}
    }
    
    func SegmentMake(_ x1: CGFloat, _ y1: CGFloat, _ x2: CGFloat, _ y2: CGFloat) -> segment {
        return segment(startpoint: CGPoint(x: x1, y: y1), endpoint: CGPoint(x: x2, y: y2))
    }
    
    func drawSegments(){
        var segments: [segment] = []
        var i = 0
        
        for _ in self.dataArray{
            segments.append(SegmentMake(CGFloat((self.dataArray[i][2] as NSString).floatValue), CGFloat((self.dataArray[i][3] as NSString).floatValue), CGFloat((self.dataArray[i][4] as NSString).floatValue+(self.dataArray[i][2] as NSString).floatValue), CGFloat((self.dataArray[i][3] as NSString).floatValue)))
            i+=1
        }
        
        for segment in segments{
            let path = UIBezierPath()
            path.move(to: segment.startPoint)
            path.addLine(to: segment.endPoint)
            
            let shapeLayer = CAShapeLayer()
            shapeLayer.path = path.cgPath
            shapeLayer.strokeColor = UIColor.blue.cgColor
            shapeLayer.lineWidth = 3.0
            
            self.view.layer.addSublayer(shapeLayer)
        }
    }
    
    func extractHotSpots(){
        for dataRow in self.dataArray{
            if  NSString(string: dataRow[6]).integerValue == self.docView.currentPage{
                let hotspot = NSString(string: dataRow[3]).floatValue
                self.hotSpots.append(CGFloat(hotspot))
            }}
        
        var spot = self.hotSpots[0]
        var index = 1
        while index<hotSpots.count{
            if self.hotSpots[index] == spot{
                self.hotSpots.remove(at: index)
            }
            else {
                spot = self.hotSpots[index]
                index += 1
            }
        }
        
        var newHotSpot : [CGFloat] = []
        for hotspot in self.hotSpots{
            let hotspotnew = round(hotspot)
            newHotSpot.append(hotspotnew)
        }
        self.hotSpots = newHotSpot
        
        //debugPrint("hotspots are \(self.hotSpots)")
    }
    
    
    func getTextAreaRect()->CGRect{
        let rectOrigin = CGPoint(x:CGFloat((self.dataArray[0][2] as NSString).floatValue), y:CGFloat((self.dataArray[0][3] as NSString).floatValue))
        var maxX: CGFloat = rectOrigin.x
        var maxY: CGFloat = rectOrigin.y
        
        var index = 0
        
        for _ in self.dataArray{
            let dataX = CGFloat((self.dataArray[index][2] as NSString).floatValue)
            let dataY = CGFloat((self.dataArray[index][3] as NSString).floatValue)
            
            if dataX>maxX {maxX = dataX}
            if dataY>maxY {maxY = dataY}
            
            index+=1
        }
        let rect = CGRect(x: rectOrigin.x-25, y: rectOrigin.y-50, width: maxX-rectOrigin.x+50, height: maxY-rectOrigin.y+100)
        return rect
    }
    
    func getEOLWords(){
        for word in self.dataArray {
            if NSString(string: word[6]).integerValue == self.docView.currentPage{
                //if NSString(string: word[0]).integerValue<dataArray.count{
                if self.dataArray[NSString(string: word[0]).integerValue][5] != word[5]{
                    self.EOLWords.append(word[8].replacingOccurrences(of: "\r", with: ""))
                }
                //}
            }
        }
        debugPrint("EOL word ids are \(self.EOLWords)")
    }
    
    
    
    
    //MARK: Overriden Functions
    //---------------------------------------------------------------------------------------
    override func viewDidLoad() {
        super.viewDidLoad()
        view.addSubview(docView)
        self.convertCSV(file: "Demo_12.9_Data")
        self.dataArray.removeFirst()
        self.textRect = getTextAreaRect()
        self.getEOLWords()
        //      self.view.addSubview(k)
        //        debugPrint("textrect is \(textRect)")
        //        debugPrint("number of data array elements \(self.dataArray.count)")
        //        debugPrint("first element id \(self.dataArray[0][0]) \(self.dataArray[0][1])")
        //        debugPrint("first element id \(self.dataArray[350][0]) \(self.dataArray[350][1])")
        //        debugPrint("first element id \(self.dataArray[351][0]) \(self.dataArray[351][1])")
        //        debugPrint("first element id \(self.dataArray[352][0]) \(self.dataArray[352][1])")
        //self.drawSegments()
        do {
            let clickURL = URL(fileURLWithPath: self.clickPath)
            let whiteStaticURL = URL(string: Bundle.main.path(forResource: "whiteStatic", ofType: "caf")!)
            let pinkStaticURL = URL(string: Bundle.main.path(forResource: "pinkStatic", ofType: "caf")!)
            let EOLdingURL = URL(string: Bundle.main.path(forResource: "ding1", ofType: "caf")!)
            let whiteSpaceNoiseURL = URL(string: Bundle.main.path(forResource: "paper_touching", ofType: "caf")!)
            self.wordClick = try AVAudioPlayer(contentsOf: clickURL)
            self.speaker = try AVAudioPlayer.init(contentsOf: clickURL)
            self.whiteStaticPlayer = try AVAudioPlayer.init(contentsOf: whiteStaticURL!)
            self.pinkStaticPlayer = try AVAudioPlayer.init(contentsOf: pinkStaticURL!)
            self.EOLPlayer = try AVAudioPlayer.init(contentsOf: EOLdingURL!)
            self.whiteSpacePlayer = try AVAudioPlayer.init(contentsOf: whiteSpaceNoiseURL!)
            speaker.delegate = self
            wordClick.volume = 1.0
            whiteStaticPlayer.volume = 1.0
            pinkStaticPlayer.volume = 1.0
            EOLPlayer.volume = 1.0
            //EOLPlayer.play()
            whiteSpacePlayer.volume = 1.0
            //self.whiteStaticPlayer.numberOfLoops = -1
            //self.whiteStaticPlayer.play()
            //self.pinkStaticPlayer.numberOfLoops = -1
            //wordClick.delegate = self
            //try AVAudioSession.sharedInstance().setCategory(AVAudioSessionCategoryPlayback)
        } catch {
            // couldn't load file :(
        }
        //debug
        self.extractHotSpots()
    }
    
    func handleOneTouch(At point: CGPoint){
        
    }
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        
        let touchArray = Array((event?.allTouches)!)
        //debugPrint("*&*&*& Touch radius is \(touchArray[0].majorRadius)")
        
        if(touchArray.count == 1){
            if let touch = touches.first {
                if (!amITouchingWhiteSpace(touch: touch.location(in: self.view))){
                    self.currentTouch = touch
                    self.startTime = (event!.timestamp)
                    self.touchLoc = touch.location(in: self.docView)
                    debugPrint("&first touch touchLoc is *** \(touchLoc)")
                    if self.words.count == 0 && self.speaker.isPlaying == false {
                        handleTouchStationary(currentTouch: touch,currentLoc: self.touchLoc)
                        self.gutterFlag = self.amIstraying(touch: touch)
                        dequeueWord(Rate: 0.53)
                    }
                }
                else{
                    self.whiteSpacePlayer.play()
                }
            }}
            
        else{
            //we need to find the topmost touches and get the two that are most on the left to track
            var tempTouch1 : UITouch = touchArray[0]
            var tempTouch2 : UITouch = touchArray[1]
            if touchArray[0].location(in: self.view).y>touchArray[1].location(in: self.view).y{
                tempTouch1 = touchArray[1] //topmost touch
                tempTouch2 = touchArray[0] //topmost-1 touch
            }
            for touch in touchArray{
                if touch.location(in: self.view).y<tempTouch1.location(in: self.view).y{
                    tempTouch2 = tempTouch1
                    tempTouch1 = touch
                }
                else if touch.location(in: self.view).y>tempTouch1.location(in: self.view).y && touch.location(in: self.view).y<tempTouch2.location(in: self.view).y{
                    tempTouch2 = touch
                }
            }
            
            let firstPoint = tempTouch1.location(in: self.view)
            let secondPoint = tempTouch2.location(in: self.view)
            if firstPoint.x<secondPoint.x {
                let readingTouch = tempTouch2
                if (!amITouchingWhiteSpace(touch: readingTouch.location(in: self.view))){
                    self.currentTouch = readingTouch
                    self.startTime = (event!.timestamp)
                    self.touchLoc = readingTouch.location(in: self.docView)
                    debugPrint("&first touch touchLoc is *** \(touchLoc)")
                    if self.words.count == 0 && self.speaker.isPlaying == false {
                        handleTouchStationary(currentTouch: readingTouch,currentLoc: self.touchLoc)
                        self.gutterFlag = self.amIstraying(touch: readingTouch)
                        dequeueWord(Rate: 0.53)
                    }
                }
                    
                else{
                    self.whiteSpacePlayer.play()
                }
                
                
            }
            else {
                let readingTouch = tempTouch1
                if (!amITouchingWhiteSpace(touch: readingTouch.location(in: self.view))){
                    self.currentTouch = readingTouch
                    self.startTime = (event!.timestamp)
                    self.touchLoc = readingTouch.location(in: self.docView)
                    debugPrint("&first touch touchLoc is *** \(touchLoc)")
                    if self.words.count == 0 && self.speaker.isPlaying == false {
                        handleTouchStationary(currentTouch: readingTouch,currentLoc: self.touchLoc)
                        self.gutterFlag = self.amIstraying(touch: readingTouch)
                        dequeueWord(Rate: 0.53)
                    }
                }
                    
                else{
                    self.whiteSpacePlayer.play()
                }
                
                
            }
            
            
        }
        super.touchesBegan(touches, with: event)
    }
    
    override func touchesMoved(_ touches: Set<UITouch>, with event: UIEvent?) {
        let touchArray = Array((event?.allTouches)!)
        
        if(touchArray.count == 1){
            if let touch = touches.first {
                if (!amITouchingWhiteSpace(touch: touch.location(in: self.view))){
                    self.currentTouch = touch
                    self.touchLoc = touch.location(in: self.docView)
                    self.gutterFlag = self.amIstraying(touch: touch)
                    debugPrint("touchLoc is *** \(touchLoc)")
                    if self._first == true{
                        self._first = false
                        handleTouchMoving(currentTouch: touch,currentLoc: self.touchLoc)
                        dequeueWord(Rate: self.rate)
                    }
                    else{
                        self.returnFromPlay(currentTouch: self.currentTouch, currentLoc: self.touchLoc)
                    }
                }
                else{
                    self.whiteSpacePlayer.play()
                }
                
            }
        }
            
        else{
            
            var tempTouch1 : UITouch = touchArray[0]
            var tempTouch2 : UITouch = touchArray[1]
            if touchArray[0].location(in: self.view).y>touchArray[1].location(in: self.view).y{
                tempTouch1 = touchArray[1] //topmost touch
                tempTouch2 = touchArray[0] //topmost-1 touch
            }
            for touch in touchArray{
                if touch.location(in: self.view).y<tempTouch1.location(in: self.view).y{
                    tempTouch2 = tempTouch1
                    tempTouch1 = touch
                }
                else if touch.location(in: self.view).y>tempTouch1.location(in: self.view).y && touch.location(in: self.view).y<tempTouch2.location(in: self.view).y{
                    tempTouch2 = touch
                }
            }
            
            let firstPoint = tempTouch1.location(in: self.view)
            let secondPoint = tempTouch2.location(in: self.view)
            if firstPoint.x<secondPoint.x {
                if (!amITouchingWhiteSpace(touch: tempTouch2.location(in: self.view))){
                    self.currentTouch = tempTouch2
                    self.touchLoc = tempTouch2.location(in: self.docView)
                    self.gutterFlag = self.amIstraying(touch: tempTouch2)
                    debugPrint("touchLoc is *** \(touchLoc)")
                    if self._first == true{
                        self._first = false
                        handleTouchMoving(currentTouch: tempTouch2,currentLoc: self.touchLoc)
                        dequeueWord(Rate: self.rate)
                    }
                    else{
                        self.returnFromPlay(currentTouch: self.currentTouch, currentLoc: self.touchLoc)
                    }
                }
                else{
                    self.whiteSpacePlayer.play()
                }
            }
            else{
                if (!amITouchingWhiteSpace(touch: tempTouch1.location(in: self.view))){
                    self.currentTouch = tempTouch1
                    self.touchLoc = tempTouch1.location(in: self.docView)
                    self.gutterFlag = self.amIstraying(touch: tempTouch1)
                    debugPrint("touchLoc is *** \(touchLoc)")
                    if self._first == true{
                        self._first = false
                        handleTouchMoving(currentTouch: tempTouch1,currentLoc: self.touchLoc)
                        dequeueWord(Rate: self.rate)
                    }
                    else{
                        self.returnFromPlay(currentTouch: self.currentTouch, currentLoc: self.touchLoc)
                    }
                }
                else{
                    self.whiteSpacePlayer.play()
                }
//                
//                else if (VertRulerController.sharedInstance.view.frame.contains(tempTouch1.location(in: self.view)))){
//                    VertRulerController.sharedInstance.touchesMoved(touches: Set<UITouch>, with event: UIEvent?)
//                }
                
            }
            
            
        }
        
        
    }
    
    override func touchesEnded(_ touches: Set<UITouch>, with event: UIEvent?) {
        debugPrint("ENDED")
        self.speaker.stop()
        self.whiteSpacePlayer.stop()
        self.whiteStaticPlayer.stop()
        self.pinkStaticPlayer.stop()
        self.words = []
        do{
            self.speaker = try AVAudioPlayer(contentsOf: URL(string: clickPath)!)}
        catch{
            debugPrint("can't reset!")
        }
        
        
    }
}
