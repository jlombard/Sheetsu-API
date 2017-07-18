//
//  Constants.swift
//  Sheetsu Sample
//
//  Created by Vitalii Hudenko on 7/18/17.
//  Copyright © 2017 sheetsu. All rights reserved.
//

import Foundation
import ObjectMapper
import CoreLocation


struct Constants {
    static let dateFormat = "MM/dd/yyyy hh:mm:ss"
    static let baseURL = "https://sheetsu.com/apis/v1.0/"
    static let latLonSeparator = ", "
}

func coordinateTransform()->TransformOf<CLLocationCoordinate2D, String>{
    return TransformOf<CLLocationCoordinate2D, String>(fromJSON: { (string) -> CLLocationCoordinate2D? in
        guard let coordinateString = string else{return nil}
        //get latitude and longitude from the given string
        //format should be "latitude,longitude"
        let coordinatesComponents = coordinateString.components(separatedBy: Constants.latLonSeparator)
        guard coordinatesComponents.count == 2,
            let lat = Double(coordinatesComponents[0]),
            let lng = Double(coordinatesComponents[1]) else{return nil}
        return CLLocationCoordinate2D(latitude: lat, longitude: lng)
        
    }, toJSON: { (coordinates) -> String? in
        guard let c = coordinates else{return nil}
        return "\(c.latitude)\(Constants.latLonSeparator)\(c.longitude)"
    })
}

enum SheetSuError:Error {
    case invalidRowsCount
}
