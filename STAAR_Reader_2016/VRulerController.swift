//
//  VRulerController.swift
//  STAAR_Reader_2016
//
//  Created by Niloofar Zarei.
//  Copyright © 2016 TEILab. All rights reserved.
//

import AVFoundation
import UIKit

class VertRulerController: UIViewController, AVAudioPlayerDelegate {
    
    static let sharedInstance = VertRulerController()
    @IBOutlet var verticalRulerView: UIView!
    var rulerClick = AVAudioPlayer()
    let clickPath = (Bundle.main.path(forResource: "click", ofType: "wav"))! as String
    //let datapath = (Bundle.main.path(forResource: "analytic_9.7_Data", ofType: "csv", inDirectory: "analytic"))! as String
    let datapath = (Bundle.main.path(forResource: "analytic_12.9_Data", ofType: "csv", inDirectory: "analytic"))! as String
    let EOLdingURL = URL(string: Bundle.main.path(forResource: "ding1", ofType: "caf")!)
    var hotSpots: [CGFloat] = []
    var data:[[String:String]] = []
    var dataArray = [[String]]()
    var columnTitles:[String] = []
    var synth = AVSpeechSynthesizer()
    var currentPage = 1
    var lastLineIndex = -1
    var notePlayMode = false
    var notePlayer = AVAudioPlayer()
    var noteSignalPlayer = AVAudioPlayer()
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        //self.convertCSV(file: "analytic_9.7_Data")
        self.convertCSV(file: "analytic_12.9_Data")
        self.extractHotSpots()
        
        do{
            try self.noteSignalPlayer = AVAudioPlayer(contentsOf: EOLdingURL!)
            noteSignalPlayer.volume = 1.0
            noteSignalPlayer.prepareToPlay()
        }
        catch{
            debugPrint("Could not initialize")
        }
        
        let singleFingerDoubleTapRecognizer = UITapGestureRecognizer(target: self, action: #selector(modeChanger))
        singleFingerDoubleTapRecognizer.numberOfTapsRequired = 2
        //singleFingerDoubleTapRecognizer.require(toFail: singleFingerTripleTapRecognizer)
        singleFingerDoubleTapRecognizer.numberOfTouchesRequired = 1
        //view.addGestureRecognizer(singleFingerDoubleTapRecognizer)
        
        let singleFingerSingleTapRecognizer = UITapGestureRecognizer(target: self, action: #selector(nextNote))
        singleFingerSingleTapRecognizer.numberOfTapsRequired = 1
        //singleFingerDoubleTapRecognizer.require(toFail: singleFingerTripleTapRecognizer)
        singleFingerSingleTapRecognizer.numberOfTouchesRequired = 1
        view.addGestureRecognizer(singleFingerSingleTapRecognizer)
        
     }
    
    func modeChanger(){
//        if (!self.notePlayMode){
//            self.notePlayMode = true
//            PlayNotes()
//        }
//        else if self.notePlayMode &&
        debugPrint("inside Play")
        debugPrint("last line index is \(lastLineIndex)")
        if self.notePlayer.isPlaying{
            notePlayer.stop()
        }
        if self.lastLineIndex>0{
            debugPrint("inside if cond")
            let nsDocumentDirectory = FileManager.SearchPathDirectory.documentDirectory
            let nsUserDomainMask    = FileManager.SearchPathDomainMask.userDomainMask
            let paths               = NSSearchPathForDirectoriesInDomains(nsDocumentDirectory, nsUserDomainMask, true)
            let enumerator = FileManager.default.enumerator(atPath: paths[0])
            let filePaths = enumerator?.allObjects as! [String]
            let noteFilePaths = filePaths.filter{$0.contains("\(lastLineIndex).caf")}
            debugPrint(noteFilePaths)
            if noteFilePaths.count>0{
                for noteFilePath in noteFilePaths{
                    do{
                        let dirPath = paths.first
                        let noteURL = URL(fileURLWithPath: dirPath!).appendingPathComponent(noteFilePath)
                        try notePlayer = AVAudioPlayer(contentsOf: noteURL)
                        notePlayer.volume = 1.0
                        notePlayer.prepareToPlay()
                        notePlayer.play()
                    }
                    catch{
                        debugPrint("cant load")
                        // couldn't load file :(
                    }
                }
            }
  
        }
        
    }
    
    func nextNote(){
        
    }
    
    func PlayNotes(){
        
    }
    
    
    func readDataFromFile(file:String)-> String!{
        guard let filepath = Bundle.main.path(forResource: file, ofType: "csv", inDirectory: "analytic")
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
            Row.append(dataRow["id"]!)
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
    
    func extractHotSpots(){
//        for dataRow in self.dataArray{
//        if  NSString(string: dataRow[6]).integerValue == self.currentPage{
//            let hotspot = NSString(string: dataRow[3]).floatValue
//            self.hotSpots.append(CGFloat(hotspot))
//        }}
    
        for dataRow in self.dataArray{
            let hotspot = NSString(string: dataRow[3]).floatValue
            self.hotSpots.append(CGFloat(hotspot))
        }
    
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
    }
    
    func checkForNotes(line: Int)->Bool{
        let nsDocumentDirectory = FileManager.SearchPathDirectory.documentDirectory
        let nsUserDomainMask    = FileManager.SearchPathDomainMask.userDomainMask
        let paths               = NSSearchPathForDirectoriesInDomains(nsDocumentDirectory, nsUserDomainMask, true)
        let enumerator = FileManager.default.enumerator(atPath: paths[0])
        let filePaths = enumerator?.allObjects as! [String]
        let noteFilePaths = filePaths.filter{$0.contains("\(line).caf")}
        if noteFilePaths.count>0 {return true}
        else {return false}
    }
    
    override func touchesMoved(_ touches: Set<UITouch>, with event: UIEvent?) {
        if let touch = touches.first{
            for hotspot in self.hotSpots{
                if abs(touch.location(in: self.view).y-hotspot)<5 && hotSpots.index(of: hotspot)! != lastLineIndex {
                    //if checkForNotes(line: Int(hotSpots.index(of: hotspot)!)){
                        //noteSignalPlayer.play()
                    //}
                    let utterance = AVSpeechUtterance(string: "line \(String(describing: hotSpots.index(of: hotspot)!))")
                    utterance.rate = 0.5
                    utterance.volume = 0.7
                    //if (!self.notePlayMode){
                        self.lastLineIndex = hotSpots.index(of: hotspot)!
                        synth.speak(utterance)
                    //}
                    
                    
                }
            }
        }
    }
    
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        if let touch = touches.first{
            for hotspot in self.hotSpots{
                if abs(touch.location(in: self.view).y-hotspot)<5 && hotSpots.index(of: hotspot)! != lastLineIndex && !(synth.isSpeaking){
                    let utterance = AVSpeechUtterance(string: "line \(String(describing: hotSpots.index(of: hotspot)!))")
                    utterance.rate = 0.5
                    utterance.volume = 0.8
                    if (!self.notePlayMode){
                        self.lastLineIndex = hotSpots.index(of: hotspot)!
                        synth.speak(utterance)
                    }
                    
                }
            }
        }

    }
    
    override func touchesEnded(_ touches: Set<UITouch>, with event: UIEvent?) {
        lastLineIndex = -1
        synth.stopSpeaking(at: AVSpeechBoundary.immediate)
    }
}
