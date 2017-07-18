//
//  LocationCell.swift
//  Sheetsu Sample
//
//  Created by Vitalii Hudenko on 7/18/17.
//  Copyright © 2017 sheetsu. All rights reserved.
//

import Foundation
import UIKit

protocol LocationCellDelegate:class {
    func locationCell(didUpdateLocationAction cell:LocationCell)
}

class LocationCell:UITableViewCell{
    @IBOutlet weak var lblName: UILabel!
    @IBOutlet weak var lblDescription: UILabel!

    weak var delegate:LocationCellDelegate?
    
    @IBAction func btnUpdateLocationAction(_ sender: Any) {
        delegate?.locationCell(didUpdateLocationAction: self)
    }
}
