//
//  inputFileSelector.swift
//  STAAR_Reader_2016
//
//  Created by niloofar zarei on 2/10/18.
//  Copyright © 2018 TEILab. All rights reserved.
//

import Foundation

struct inputFiles {
    var noteWithButton: String = "N1N1"
    var noteWithTap: String = "analytic"
    var Intro_BF_BV_Conditions: String = "Intro.BV.BF"
    
    func getDocument()-> String {
        return self.noteWithButton
//        return self.noteWithTap
//        return self.Intro_BF_BV_Conditions
    }
    
}
