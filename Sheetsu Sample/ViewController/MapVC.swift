//
//  MapVC.swift
//  Sheetsu Sample
//
//  Created by Vitalii Hudenko on 7/18/17.
//  Copyright © 2017 sheetsu. All rights reserved.
//

import UIKit
import MapKit

class MapVC: UIViewController, MKMapViewDelegate {

    @IBOutlet weak var map: MKMapView!
    
    var locations = [Location]()
    fileprivate var needsFitAnnotations = true
    override func viewDidLoad() {
        super.viewDidLoad()
        addLocationsToMapView()
        // Do any additional setup after loading the view.
    }

    //MARK: --
    //MARK: Instance methods
    fileprivate func addLocationsToMapView(){
        //Iterate though locations list and creat anotations
        //Then add them to the map
        for location in locations {
            let annotation = LocationAnnotation(location)
            map.addAnnotation(annotation)
        }
        map.showAnnotations(map.annotations, animated: false)
    }
    
    
    //MARK: --
    //MARK: MKMapViewDelegate
    func mapView(_ mapView: MKMapView, regionDidChangeAnimated animated: Bool) {
        guard needsFitAnnotations else {return}
        
        //Fit added annotations to the screen
        needsFitAnnotations = false
        let padding = UIEdgeInsets(top: 20, left: 20, bottom: 20, right: 20)
        mapView.setVisibleMapRect(mapView.visibleMapRect, edgePadding: padding, animated: animated)
    }
}
