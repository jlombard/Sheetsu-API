//
//  ViewController.swift
//  Sheetsu Sample
//
//  Created by Vitalii Hudenko on 7/18/17.
//  Copyright © 2017 sheetsu. All rights reserved.
//

import UIKit
import ObjectMapper
import CoreLocation
import SwiftLocation
import SVProgressHUD


class LocationsVC: UITableViewController, LocationCellDelegate {
    //A required sheet instance
    fileprivate let sheetPage = SheetSuManager("c0cbd25b3de8")
    fileprivate let sheetPageName = "Locations"
    
    //Parsed locations
    fileprivate var locations = [Location]()
    
    //Service fro gitting the user's current location
    fileprivate var locationService:LocationRequest?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        configureViews()
        SVProgressHUD.show(withStatus: "Loading locations")
        
        //load locations after controller is loaded
        reloadLocations()
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        guard segue.identifier == "ShowMapView",
        let destination = segue.destination as? MapVC else {
            return
        }
        if let locs = sender as? [Location]{
            destination.locations = locs
        }
        else{
            destination.locations = locations
        }
    }

    //MARK: --
    //MARK: Instance methods
    @objc fileprivate func reloadLocations(){
        sheetPage.parseSheet(mappingClass: Location.self, sheetTabName: sheetPageName, onSuccess: {
            [weak self](objects) in
            SVProgressHUD.dismiss()
            self?.refreshControl?.endRefreshing()
            self?.locations = objects as![Location]
            self?.tableView.reloadData()
        }, onFail:{
            [weak self] error in
            SVProgressHUD.dismiss()
            self?.refreshControl?.endRefreshing()
            self?.presentErrorAlert("Locations loading error.", message: error?.localizedDescription)
        })
    }
    
    fileprivate func configureViews(){
        tableView.rowHeight = UITableViewAutomaticDimension
        tableView.estimatedRowHeight = 63
        refreshControl?.addTarget(self, action: #selector(self.reloadLocations), for: .valueChanged)
    }
    
    fileprivate func presentAddLocationAlert(withLocation location:CLLocationCoordinate2D){
        let alert = UIAlertController(title: "Add Location.", message: "Please enter a new location name.", preferredStyle: .alert)
        alert.addTextField { (textField) in
            textField.placeholder = "Name"
        }
        let okAction = UIAlertAction(title: "Save", style: .default) {
            [weak self](_) in
            guard let txtField = alert.textFields?.first,
                let name = txtField.text,
                !name.isEmpty else{
                    self?.presentErrorAlert(message: "Name can't be empty.")
                    return
            }
            self?.addLocationToTheSheet(name, coordinates: location)
        }
        alert.addAction(okAction)
        
        let cancelAction = UIAlertAction(title: "Cancel", style: .cancel)
        alert.addAction(cancelAction)
        present(alert, animated: true, completion: nil)
    }
    
    fileprivate func addLocationToTheSheet(_ name:String, coordinates:CLLocationCoordinate2D){
        
        //Create model for adding
        let model = Location()
        model.name = name
        model.date = Date()
        model.coordinates = coordinates
        SVProgressHUD.show(withStatus: "Adding new row")
        
        //Adding a row to the sheet page
        sheetPage.addRows([model], sheetTabName: sheetPageName, onSuccess: {
            [weak self] in
            SVProgressHUD.dismiss()
            
            //Add the model to the locations list in case of success
            guard let locationsCount = self?.locations.count else{
                self?.locations.append(model)
                self?.tableView.reloadData()
                return
            }
            self?.tableView.beginUpdates()
            self?.locations.append(model)
            self?.tableView.insertRows(at: [IndexPath(row: locationsCount, section: 0)], with: .automatic)
            self?.tableView.endUpdates()
        }) { [weak self](error) in
            
            //Present error alert in case of failure
            SVProgressHUD.dismiss()
            self?.presentErrorAlert("Location adding error.", message: error?.localizedDescription)
        }
    }
    
    fileprivate func updateLocation(_ location:Location){
        SVProgressHUD.show(withStatus: "Updating location")
        sheetPage.updateRow(location, sheetTabName: sheetPageName, onSuccess: {
            [weak self] in
            SVProgressHUD.dismiss()
            //just reloasd data in table
            self?.tableView.reloadData()
        }) { [weak self](error) in
            SVProgressHUD.dismiss()
            
            //present error alert in case of failure
            self?.presentErrorAlert("Location updating error.", message: error?.localizedDescription)
            self?.locationService = nil
        }
    }
    
    fileprivate func deleteLocation(_ location:Location){
        let alert = UIAlertController(title: "Location deleting", message: "Are you sure you want to delete the location?", preferredStyle: .alert)
        let cancel = UIAlertAction(title: "Cancel", style: .cancel, handler: nil)
        alert.addAction(cancel)
        
        let okAction = UIAlertAction(title: "Delete", style: .destructive) {
            [weak self](_) in
            SVProgressHUD.show(withStatus: "Location deleting")
            guard let pageName = self?.sheetPageName else{return}
            self?.sheetPage.deleteRow(location, sheetTabName: pageName, onSuccess: {
                SVProgressHUD.dismiss()
                guard let index = self?.locations.index(of: location) else{return}
                self?.tableView.beginUpdates()
                self?.locations.remove(at: index)
                self?.tableView.deleteRows(at: [IndexPath(row: index, section: 0)], with: .automatic)
                self?.tableView.endUpdates()
            }, onFail: { [weak self](error) in
                //Present error alert in case of failure
                SVProgressHUD.dismiss()
                self?.presentErrorAlert("Location adding error.", message: error?.localizedDescription)
            })
        }
        alert.addAction(okAction)
        present(alert, animated: true, completion: nil)
    }

    //MARK: --
    //MARK: TableViewDataSource/TableViewDelegate
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return locations.count
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let location = locations[indexPath.row]
        
        let cell = tableView.dequeueReusableCell(withIdentifier: "LocationCell", for: indexPath) as! LocationCell
        
        cell.delegate = self
        
        let titleLabel = cell.contentView.viewWithTag(1) as?UILabel
        titleLabel?.text = location.name
        
        let detailsLabel = cell.contentView.viewWithTag(2) as?UILabel
        detailsLabel?.text = "\(location.date.fullDateString)\n\(location.coordinates.string)"
        
        return cell
    }
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let location = locations[indexPath.row]
        performSegue(withIdentifier: "ShowMapView", sender: [location])
    }
    
    //Deleting
    override func tableView(_ tableView: UITableView, editingStyleForRowAt indexPath: IndexPath) -> UITableViewCellEditingStyle {
        return .delete
    }
    
    override func tableView(_ tableView: UITableView, canEditRowAt indexPath: IndexPath) -> Bool {
        return true
    }
    
    override func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCellEditingStyle, forRowAt indexPath: IndexPath) {
        tableView.setEditing(false, animated: true)
        guard editingStyle == .delete else{return}
        let location = locations[indexPath.row]
        deleteLocation(location)
    }
    
    //MARK: --
    //MARK: Control actions
    @IBAction func btnAddLocationAction(_ sender: Any) {
        
        //chech if location service is launched
        guard locationService == nil else{return}
        SVProgressHUD.show(withStatus: "Getting location")
        
        //get the current user location
        locationService = LocationRequest(accuracy: .navigation, frequency: .oneShot, {
            [weak self](request, location) -> (Void) in
            SVProgressHUD.dismiss()
            
            //present the add location alert in case of success
            self?.presentAddLocationAlert(withLocation: location.coordinate)
            self?.locationService = nil
        }) { [weak self] (_, _, error) -> (Void) in
            SVProgressHUD.dismiss()
           
            //present error alert in case of failure
            self?.presentErrorAlert("Location tracking error.", message: error.localizedDescription)
            self?.locationService = nil
        }
        locationService?.resume()
    }
    
    //MARK: --
    //MARK: LocationCellDelegate
    func locationCell(didUpdateLocationAction cell: LocationCell) {
        //chech if location service is launched
        guard locationService == nil,
        let index = tableView.indexPath(for: cell) else{return}
        SVProgressHUD.show(withStatus: "Getting location")
        
        //Get location model to update
        let locationModel = locations[index.row]
        
        //get the current user location
        locationService = LocationRequest(accuracy: .navigation, frequency: .oneShot, {
            [weak self](request, location) -> (Void) in
            SVProgressHUD.dismiss()
            locationModel.coordinates = location.coordinate
            
            //Update sheet row
            self?.updateLocation(locationModel)
            self?.locationService = nil
        }) { [weak self] (_, _, error) -> (Void) in
            SVProgressHUD.dismiss()
            
            //present error alert in case of failure
            self?.presentErrorAlert("Location tracking error.", message: error.localizedDescription)
            self?.locationService = nil
        }
        locationService?.resume()
    }
}

