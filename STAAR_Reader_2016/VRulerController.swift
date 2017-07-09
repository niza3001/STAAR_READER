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
    let datapath = (Bundle.main.path(forResource: "Demo_12.9_Data", ofType: "csv", inDirectory: "Demo"))! as String
    var hotSpots: [CGFloat] = []
    var  data:[[String:String]] = []
    var dataArray = [[String]]()
    var  columnTitles:[String] = []
    var mySubViews: [customButton] = []
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.convertCSV(file: "Demo_12.9_Data")
        self.extractHotSpots()
        do {
            debugPrint(hotSpots)
            let clickURL = URL(fileURLWithPath: self.clickPath)
            self.rulerClick = try AVAudioPlayer(contentsOf: clickURL)
            self.rulerClick.volume = 1.0
            self.rulerClick.delegate = self
            self.rulerClick.prepareToPlay()
            debugPrint("ruler loaded")
            
        } catch {
            // couldn't load file :(
        }
        
        self.createButtons()
        
    }
    
    func createButtons(){
        for hotspot in self.hotSpots{
            let btn = customButton(frame: CGRect(x: 0, y: hotspot, width: self.view.frame.width, height: 2))
            btn.backgroundColor = UIColor.clear
            //btn.addTarget(self, action: #selector(buttonAction), for: .touchDragInside)
            btn.tag = 1
            self.mySubViews.append(btn)
            self.view.addSubview(btn)
        }
    }
    
    
    func buttonAction(sender: UIButton!) {
        let btnsendtag: UIButton = sender
        if btnsendtag.tag == 1 {
            rulerClick.play()
            rulerClick.prepareToPlay()
        }
    }
    
    
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
            //            Row.append(dataRow["AUDIONORMAL"]!)
            //            Row.append(dataRow["AUDIOFAST\r"]!)
            dataArray.append(Row)
        }
    }
    
    func extractHotSpots(){
        for dataRow in self.dataArray{
            //            if  NSString(string: dataRow[6]).integerValue == docView.currentPage{
            let hotspot = NSString(string: dataRow[3]).floatValue
            self.hotSpots.append(CGFloat(hotspot))
        }//}
        
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
    
    override func touchesMoved(_ touches: Set<UITouch>, with event: UIEvent?) {
        //let myViews = self.view.subviews.filter{$0 is customButton}
        for subview in self.mySubViews{
            for touch in touches{
                if subview.point(inside: touch.location(in: self.view), with: event){
                    self.rulerClick.play()
                    //subview.playClick()
                    //VRAudio.sharedInstance.playSound(soundFileName: "click")
                }
            }
        }
        
    }
    
}

class customButton: UIView, AVAudioPlayerDelegate {
    
    var rulerClick = AVAudioPlayer()
    let clickURL = URL(fileURLWithPath: ((Bundle.main.path(forResource: "click", ofType: "wav"))! as String))
    var soundID: SystemSoundID = 0
    
    
    
    override init(frame: CGRect){
        super.init(frame: frame)
        AudioServicesCreateSystemSoundID(self.clickURL as CFURL, &soundID)
        //        do {
        //            let clickURL = URL(fileURLWithPath: self.clickPath)
        //            self.rulerClick = try AVAudioPlayer(contentsOf: clickURL)
        //            self.rulerClick.volume = 1.0
        //            self.rulerClick.delegate = self
        //            self.rulerClick.prepareToPlay()
        
        //        } catch {
        // couldn't load file :(
        //        }
        
    }
    
    func playClick(){
        AudioServicesPlaySystemSound(soundID)
    }
    
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func point(inside point: CGPoint, with event: UIEvent?) -> Bool {
        return self.frame.contains(point)
    }
}


