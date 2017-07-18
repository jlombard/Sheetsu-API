//
//  Date + Formatting.swift
//  Sheetsu Sample
//
//  Created by Vitalii Hudenko on 7/18/17.
//  Copyright © 2017 sheetsu. All rights reserved.
//

import Foundation

extension Date{
    var fullDateString:String{
        get{
            let formatter = DateFormatter()
            formatter.dateStyle = .long
            formatter.timeStyle = .long
            return formatter.string(from: self)
        }
    }
}
