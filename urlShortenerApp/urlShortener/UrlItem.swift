//
//  UrlItem.swift
//  urlShortener
//
//  Created by Paul Jouhaud on 24/12/2016.
//  Copyright © 2016 Paul Jouhaud. All rights reserved.
//

import Foundation
import UIKit

class UrlItem: NSObject, NSCoding {
    var real_url = ""
    var short_url = ""
    
    override init() {
        super.init()
    }
    
    required init?(coder aDecoder: NSCoder) {
        real_url = aDecoder.decodeObject(forKey: "real_url") as! String
        short_url = aDecoder.decodeObject(forKey: "short_url") as! String
        super.init()
    }
    
    func encode(with aCoder: NSCoder) {
        aCoder.encode(real_url, forKey: "real_url")
        aCoder.encode(short_url, forKey: "short_url")
    }
}
