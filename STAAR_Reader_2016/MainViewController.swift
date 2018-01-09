//
//  MainViewController.swift
//  STAAR_Reader_2016
//
//  Created by Niloofar Zarei.
//  Copyright © 2016 TEILab. All rights reserved.
//

import UIKit


import UIKit

class MainViewController: UIViewController {
    
    //--------------------------------------------------------------------------------------------------------------
    //MARK: Variables
    //--------------------------------------------------------------------------------------------------------------
    var docAreaController: DocAreaController!
    var vertRulerController: VertRulerController!
    var currentPage = 1
    
    //--------------------------------------------------------------------------------------------------------------
    //MARK: - Overridden Functions
    //--------------------------------------------------------------------------------------------------------------
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Do any additional setup after loading the view, typically from a nib.
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    //--------------------------------------------------------------------------------------------------------------
    //MARK: - Navigation
    //--------------------------------------------------------------------------------------------------------------
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        //Called on startup, allows access to the DocAreaController class instance
        if (segue.identifier == "docAreaController") { //Check for the docAreaController segue to prevent incorrect assignments
            docAreaController = segue.destination as?  DocAreaController
        }
        
        if (segue.identifier == "vertRulerController") { //Check for the vertRulerControllerEmbed segue to prevent incorrect assignments
            vertRulerController = segue.destination as? VertRulerController
        }
        
        
    }
    
    override func touchesMoved(_ touches: Set<UITouch>, with event: UIEvent?) {
        if self.currentPage != 1{
            self.currentPage = self.docAreaController.docView.currentPage
            self.vertRulerController.currentPage = self.currentPage
            self.vertRulerController.extractHotSpots()
        }
    }
    
}
//--------------------------------------------------------------------------------------------------------------
//MARK: - Class Extensions
//--------------------------------------------------------------------------------------------------------------
extension String {
    
    subscript (i: Int) -> Character {
        return self[self.characters.index(self.startIndex, offsetBy: i)]
    }
    
    subscript (i: Int) -> String {
        return String(self[i] as Character)
    }
    
    subscript (r: Range<Int>) -> String {
        return substring(with: Range(characters.index(startIndex, offsetBy: r.lowerBound)..<characters.index(startIndex, offsetBy: r.upperBound)))
    }
    
    //Note2Self: How these extensions work?
    //"abcde"[0] == "a"
    //"abcde"[0...2] == "abc"
    //"abcde"[2..<4] == "cd"
}

extension URL {
    var isDirectory: Bool {
        guard isFileURL else { return false }
        var directory: ObjCBool = false
        return FileManager.default.fileExists(atPath: path, isDirectory: &directory) ? directory.boolValue : false
    }
    var subDirectories: [URL] {
        guard isDirectory else { return [] }
        return (try? FileManager.default.contentsOfDirectory(at: self, includingPropertiesForKeys: nil, options: [.skipsHiddenFiles]).filter{ $0.isDirectory }) ?? []
    }
}





