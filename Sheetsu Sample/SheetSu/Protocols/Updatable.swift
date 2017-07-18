//
//  Updatable.swift
//  Sheetsu Sample
//
//  Created by Vitalii Hudenko on 7/18/17.
//  Copyright © 2017 sheetsu. All rights reserved.
//

import Foundation
import ObjectMapper

protocol Updatable:Mappable {
    var uid:String!{get}
    var primaryKeyName:String {get}
}
