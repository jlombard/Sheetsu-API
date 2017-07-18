//
//  UIViewController + Alert Controller.swift
//  Sheetsu Sample
//
//  Created by Vitalii Hudenko on 7/18/17.
//  Copyright © 2017 sheetsu. All rights reserved.
//

import Foundation
import UIKit

extension UIViewController{
    //Present Alert view controller on any UIViewController
    func presentErrorAlert(_ title:String = "Error.",
                           message:String? = nil,
                           action:((UIAlertAction) -> Swift.Void)? = nil){
        let alert = UIAlertController(title: title, message: message ?? "Something went wrong.\nPleaase try again.", preferredStyle: .alert)
        let okAction = UIAlertAction(title: "OK", style: .cancel, handler: action)
        alert.addAction(okAction)
        present(alert, animated: true, completion: nil)
    }
}
