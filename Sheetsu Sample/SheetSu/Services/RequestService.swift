//
//  RequestService.swift
//  Sheetsu Sample
//
//  Created by Vitalii Hudenko on 7/18/17.
//  Copyright © 2017 sheetsu. All rights reserved.
//

import Foundation
import ObjectMapper
import AlamofireObjectMapper
import Alamofire

class RequestService{
    //Send GET request to get the sheet rows and map them to objects
    //Mappable is a ObjectMapper framework protocol
    func getRows<T:Mappable>(_ urlString:String, mappingClass:T.Type, params:[String:Any]? = nil, onSuccess:@escaping SheetParsingSuccess, onFail:SheetRequestFail?){
        Alamofire.request(urlString, parameters: params)
            .responseArray { (response:DataResponse<[T]>) in
                guard let value = response.value else{
                    onFail?(response.error)
                    return
                }
                onSuccess(value)
        }
    }
    
    //Adding new row to the sheet
    func postRow(_ urlString:String, rows:[Mappable], onSuccess:SheetUpdatingsSuccess?, onFail:SheetRequestFail?){
        //Map objects to JSON dictionary
        let params = ["rows":rows.map({$0.toJSON()})]
        //Sending request
        Alamofire.request(urlString, method: .post, parameters: params, encoding: JSONEncoding.default)
        .response { (response) in
            guard let error = response.error else{
                onSuccess?()
                return
            }
            onFail?(error)
        }
    }
}
