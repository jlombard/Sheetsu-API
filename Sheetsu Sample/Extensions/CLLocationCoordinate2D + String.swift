//
//  CLLocationCoordinate2D + String.swift
//  Sheetsu Sample
//
//  Created by Vitalii Hudenko on 7/18/17.
//  Copyright © 2017 sheetsu. All rights reserved.
//

import Foundation
import CoreLocation

extension CLLocationCoordinate2D{
    var string:String{
        get{
            return "lat: \(latitude)\nlng: \(longitude)"
        }
    }
}
