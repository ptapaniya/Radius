//
//  APIManager.swift
//  Radius
//
//  Created by iMac on 29/06/23.
//

import UIKit
import Alamofire

private class SingletonAlamofireHelper {
    var parentView: UIViewController?
}

class APIManager: NSObject {
    
    enum HTTPRequestType {
        case get
        case post
        case put
        case delete
    }
    
    //MARK: - Setup
    private static let setup = SingletonAlamofireHelper()
    var isAskedForRefreshToken: Bool = false
    let dictRequests: NSMutableDictionary = [:]
    
    class func setup(parentVC: UIViewController) {
        APIManager.setup.parentView = parentVC
    }
    
    typealias completionDataHandler<T> = (_ status: Bool, _ response: T?, _ errorMessage: APICustomError?) -> Void
    typealias braintreeCompletionHandler = (_ status: Bool, _ responseData: Data?, _ responseString: String?) -> Void
    
    //MARK: - Accessors
    static let sharedInstance = APIManager()
    var manager: Session?
    
    //MARK: - Init
    private override init() {
        super.init()
        manager = Alamofire.Session.default
        manager!.session.configuration.timeoutIntervalForRequest = APIServerConstants.serverTimeout
    }
    
    //MARK: - User Session Headers
    private func getUserSessionHeaders(_ contentType: String = "application/json") -> [String:String] {
        
        var defaultHeaders = [String:String]()
        defaultHeaders["Content-Type"] = contentType
        defaultHeaders["Accept"] = "application/json"
        
        return defaultHeaders
    }
    
    //MARK: - Request
    func generateAPIRequest<T: Codable>(reqEndpoint: APIConstants, type: T.Type, isAccessToken: Bool = false, reqBodyData: [String:Any]?, completion: @escaping completionDataHandler<T>)  {
        
        var urlString = APIServerConstants.serverBaseURL.appendingPathComponent(reqEndpoint.apiPath).absoluteString.removingPercentEncoding
        if reqBodyData != nil {
            DLog("API Request Data ==> \(reqBodyData!)")
            if reqEndpoint.apiRequestType == "GET"{
                if reqBodyData != nil {
                    urlString = urlString! + "?" + reqBodyData!.queryString
                }
            }
        }
        
        let escapedAddress = urlString?.addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed)
        
        guard let reqURL = URL(string: escapedAddress ?? "") else {
            return
        }
        DLog("API URL ==> \(reqURL)")
        
        var request = URLRequest(url: reqURL)
        if reqEndpoint.apiRequestType != "GET"{
            if reqBodyData != nil {
                
                var jsonData: Data! = nil
                do {
                    jsonData = try JSONSerialization.data(withJSONObject: reqBodyData!, options: [])
                    request.httpBody = jsonData
                    
                    let requestJSON = String(data: jsonData, encoding: String.Encoding.utf8)
                    DLog("JSON Request ==> \(requestJSON!)")
                }
                catch {
                    DLog("Array to JSON conversion failed: \(error.localizedDescription)")
                }
            }
        }
        
        
        request.httpMethod = reqEndpoint.apiRequestType
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        request.allHTTPHeaderFields = getUserSessionHeaders()
        
        self.apiRequestToServer( apiRequest: request, type: type, completion: completion)
        
    }
    
    private func apiRequestToServer<T: Codable>( apiRequest: URLRequest, type: T.Type, completion: @escaping completionDataHandler<T>) {
        
        //Request to Server
        manager!.request(apiRequest)
            .responseJSON { response in
                
                switch response.result {
                case .failure(let error):
                    DLog("Error ==> \(error)")
                    
                case .success(let responseObject):
                    DLog("Request ==> \((apiRequest.url)!)\n Response ==> \(responseObject)")
                }
                
                if let httpError = response.error {
                    
                    //TODO: HTTP ERROR
                    let statusCode = httpError._code
                    
                    //TODO: HTTP - Authentication Required 🤔
                    if statusCode == 401 {
                        
                        let errorMsg = "Authentication Required"
                        let customError = APIErrorManager.getServerErrorMessage(status: statusCode, errMsg: errorMsg, api: (apiRequest.url?.absoluteString)!)
                        completion(false, nil, customError)
                        return
                    }
                    else {
                        //TODO: HTTP - Another Error
                        //Callback
                        if statusCode != 15 {
                            let strErrorMsg = APIErrorManager.getHTTPErrorMessage(status: statusCode)
                            let customError = APIErrorManager.getServerErrorMessage(status: statusCode, errMsg: strErrorMsg, api: (apiRequest.url?.absoluteString)!)
                            completion(false, nil, customError)
                        }
                        return
                    }
                }
                else {
                    //TODO: HTTP Response
                    let statusCode = response.response?.statusCode ?? 0
                    
                    //TODO: Authentication Required 🤔
                    if statusCode == 401 {
                        let errorMsg = "Authentication Required"
                        let customError = APIErrorManager.getServerErrorMessage(status: statusCode, errMsg: errorMsg, api: (apiRequest.url?.absoluteString)!)
                        completion(false, nil, customError)
                        return
                    }
                    //TODO: Server Maintainance 😢
                    else if statusCode == 503 {
                        
                        DispatchQueue.main.asyncAfter(deadline: .now() + 0.1, execute: {
                            //Server Maintainance Prompt
                        })
                        
                        let errorMsg = "Server Under Maintainance"
                        let customError = APIErrorManager.getServerErrorMessage(status: statusCode, errMsg: errorMsg, api: (apiRequest.url?.absoluteString)!)
                        completion(false, nil, customError)
                        return
                    }
                    
                    //TODO: Valid API Response - Data Parsing 😇
                    //Data Parsing
                    do {
                        if let data = response.data {
                            
                            let dictResponse = try? JSONSerialization.jsonObject(with: data, options: []) as? NSDictionary
                            
                            //dict
                            if let dataObj = objectToData(stringArray: dictResponse!){
                                let resultData = ResponseData(data: dataObj)
                                let decodedResponse = resultData.decode(type)
                                print("decodedResponse :- \(decodedResponse)")
                                guard let decodedData = decodedResponse.decodedData else {
                                    
                                    if let err = decodedResponse.error {
                                        let error = APICustomError(title: "Data not decoded", desc: err.localizedDescription, code: 200, api: "\(response.request?.url?.absoluteString ?? "")")
                                        completion(false, nil, error)
                                        return
                                    }
                                    completion(false, nil, nil)
                                    return
                                }
                                
                                //MARK: Valid Response
                                completion(true, decodedData, nil)
                            }
                            else{
                                //error
                                let error = APICustomError(title: "Data not decoded", desc: "Data not decoded", code: 200, api: "\(response.request?.url?.absoluteString ?? "")")
                                completion(false, nil, error)
                                return
                            }
                            
                        }
                        else {
                            //Callback
                            let errorMsg = "Data not found"
                            let customError = APIErrorManager.getServerErrorMessage(status: statusCode, errMsg: errorMsg, api: (apiRequest.url?.absoluteString)!)
                            completion(false, nil, customError)
                        }
                    }
                    catch {
                        //Callback
                        let errorMsg = "Something went wrong"
                        let customError = APIErrorManager.getServerErrorMessage(status: statusCode, errMsg: errorMsg, api: (apiRequest.url?.absoluteString)!)
                        completion(false, nil, customError)
                    }
                }
            }
    }
}

extension Dictionary {
    var queryString: String {
        var output: String = ""
        for (key,value) in self {
            output +=  "\(key)=\(value)&"
        }
        output = String(output.dropLast())
        return output
    }
}
