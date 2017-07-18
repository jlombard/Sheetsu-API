//
//  Location.swift
//  Sheetsu Sample
//
//  Created by Vitalii Hudenko on 7/18/17.
//  Copyright © 2017 sheetsu. All rights reserved.
//

import Foundation
import ObjectMapper
import CoreLocation


/**
 Object represented Row in location page of the provided sheet
 If object could be updated, it MUST confirm to protocol Updatable
 To add new attribute:
 - Add new column to the sheet page 
 - Add new property to the class
 - Subscribe mapping rule
 
 For more information about Mapping, see https://github.com/Hearst-DD/ObjectMapper
 */
class Location:Updatable {
    fileprivate(set) var uid:String!
    var name:String!
    var coordinates:CLLocationCoordinate2D!
    var date:Date!
    
    var primaryKeyName: String{
        get{
            return Key.udid
        }
    }
    
    init() {
        uid = NSUUID().uuidString
    }
    
    //MARK: --
    //MARK: Mappable
    required init?(map: Map) {
        mapping(map: map)
    }
    
    func mapping(map: Map) {
        uid <- map[Key.udid]
        name <- map[Key.name]
        date <- (map[Key.date], CustomDateFormatTransform(formatString: Constants.dateFormat))
        coordinates <- (map[Key.location], coordinateTransform())
    }
}

//MARK: --
//MARK: Model keys
fileprivate struct Key {
    static let udid = "UDID"
    static let name = "Name"
    static let date = "Date_Time"
    static let location = "Location"
}
