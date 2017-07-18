//
//  LocationAnnotation.swift
//  Sheetsu Sample
//
//  Created by Vitalii Hudenko on 7/18/17.
//  Copyright © 2017 sheetsu. All rights reserved.
//

import Foundation
import MapKit

//Implement annotation class
//Instances of this class will be added to the map
class LocationAnnotation:NSObject, MKAnnotation {
    let coordinate: CLLocationCoordinate2D
    var title: String?
    
    init(_ location:Location) {
        coordinate = location.coordinates
        title = location.name
        super.init()
    }
}
