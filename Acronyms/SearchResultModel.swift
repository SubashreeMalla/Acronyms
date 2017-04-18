//
//  SearchResultModel.swift
//  Acronyms
//
//  Created by Subashree Malla Lokanathan on 4/17/17.
//  Copyright © 2017 Subashree Malla Lokanathan. All rights reserved.
//

import UIKit
import ObjectMapper

class SearchResultModel: Mappable {
    var sf : String?
    var lfs : [LongFormsModel]?
    
    required convenience init?(map: Map) {
        self.init()
    }
    
    func mapping(map: Map) {
        sf   <- map["sf"]
        lfs  <- map["lfs"]
    }
}

class LongFormsModel: Mappable {
    var lf: String?
    var freq: Int?
    var since : Int?
    var vars : [LongFormsModel]?
    required convenience init?(map: Map) {
        self.init()
    }
    
    func mapping(map: Map) {
        freq   <- map["freq"]
        lf  <- map["lf"]
        since  <- map["since"]
        vars  <- map["vars"]
    }

}
