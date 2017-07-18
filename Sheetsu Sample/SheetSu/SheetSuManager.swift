//
//  SheetSuManager.swift
//  Sheetsu Sample
//
//  Created by Vitalii Hudenko on 7/18/17.
//  Copyright © 2017 sheetsu. All rights reserved.
//

import Foundation
import ObjectMapper

typealias SheetParsingSuccess = ([Mappable])->()
typealias SheetUpdatingsSuccess = ()->()
typealias SheetRequestFail = (Error?)->()


/**
 User this class instance to Fetch or add the sheet data
 */
class SheetSuManager{
    
    fileprivate let requestSrvice = RequestService()
    let sheetId:String
    
    //MARK: --
    //MARK: Init
    /**
     Default constructor
     - Parameters:
        - sheetId: Sheet ID according to SheetSu documentation.
            https://docs.sheetsu.com/#read
     */
    init(_ sheetId:String) {
        self.sheetId = sheetId
    }
    
    /**
     Parse the sheet page with a given name and limits
     - Parameters:
        - mappingClass: The class which represent ONE row of the sheet. It MUST confirm to mappable protocol. See ObjectMapper framework for more info.
        - sheetTabName: Sheet name. Optional. If nil, the default sheet is parsed.
        - searchParams: The search query dictionary in format ["Column_name":"Value"]. Value letters case is ignored.
        - offset: The index of row to start parsing from. Optional. If nil, parsing starts from the begining.
        - limit: The maximum number of fetched rows. Optional. If nil, all rows will be fetched from the sheet.
        - onSuccess: Calls if parsing was successfull.
        - onFail: Calls if paring failed.
    */
    func parseSheet<T:Mappable>(mappingClass:T.Type,
                    sheetTabName:String? = nil,
                    searchParams:[String:Any]? = nil,
                    offset:Int? = nil,
                    limit:Int? = nil,
                    onSuccess:@escaping SheetParsingSuccess,
                    onFail:SheetRequestFail? = nil){
        var urlString = Constants.baseURL + sheetId
        //Add sheet name to the url
        if let name = sheetTabName{
            urlString += "/sheets/\(name)"
        }
        //Query params
        var params = searchParams ?? [:]
        if let offset = offset{
            params["offset"] = offset
        }
        if let limit = limit{
            params["limit"] = limit
        }
        if params.count > 0{
            params["ignore_case"] = true
        }
        requestSrvice.getRows(urlString, mappingClass: mappingClass, params: params, onSuccess: onSuccess, onFail: onFail)
    }
    
    
    /**
     Add new row the sheet page with a given name
     - Parameters:
        - models: Objects that represent rows. Each object represent ONE row
        - sheetTabName: Sheet name. Optional. If nil, the default sheet is parsed.
        - onSuccess: Calls if adding was successfull.
        - onFail: Calls if adding failed.
    */
    func addRows(_ models:[Mappable],
                sheetTabName:String? = nil,
                onSuccess:SheetUpdatingsSuccess? = nil,
                onFail:SheetRequestFail? = nil){
        guard models.count > 0 else{
            onFail?(SheetSuError.invalidRowsCount)
            return
        }
        var urlString = Constants.baseURL + sheetId
        //Add sheet name to the url
        if let name = sheetTabName{
            urlString += "/sheets/\(name)"
        }
        requestSrvice.postRow(urlString, rows: models, onSuccess: onSuccess, onFail: onFail)
    }
    
    
    /**
     /**
     Update row on sheet page with a given name
     - Parameters:
        - model: Object that represent updated row data. It MUST have an uid property. It is a primary key
        - sheetTabName: Sheet name. Optional. If nil, the default sheet is parsed.
        - onSuccess: Calls if adding was successfull.
        - onFail: Calls if adding failed.
     */
    */
    func updateRow<T:Updatable>(_ model:T,
                   sheetTabName:String? = nil,
                   onSuccess:SheetUpdatingsSuccess? = nil,
                   onFail:SheetRequestFail? = nil){
        //Check if model has a uid property value
        guard let uid = model.uid else{
            onFail?(SheetSuError.invalidInputData)
            return
        }
        var urlString = Constants.baseURL + sheetId
        //Add sheet name to the url
        if let name = sheetTabName{
            urlString += "/sheets/\(name)"
        }
        urlString += "/\(model.primaryKeyName)/\(uid)"
        requestSrvice.updateRow(urlString, model: model, onSuccess: onSuccess, onFail: onFail)
    }

}
