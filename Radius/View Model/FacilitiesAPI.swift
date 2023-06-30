//
//  FacilitiesAPI.swift
//  Radius
//
//  Created by iMac on 29/06/23.
//

import Foundation

class Service: BaseVC {
    
    static let shareInstance = Service()

    func GetFacilityAPICall(completion: @escaping(FacilityModel?, Error?) -> ()) {
        
        if reachability.connection != .none {
            
            self.createMainLoaderInView("Loading...")
            
            APIManager.sharedInstance.generateAPIRequest(reqEndpoint: APIConstants.getFacilities, type: FacilityModel.self, isAccessToken: false, reqBodyData: nil) { (status, objData, error) in
                
                self.stopLoaderAnimation()
                
                if status {
                
                    if objData != nil
                    {
                        completion(objData, nil)
                    }
                    
                } else {
                    print("Status else - \(status)")
                    let _ = CustomAlertController.alert(title: "Try again!", message: error?.localizedDescription ?? defaultString.messageSomethingWrong)
                }
            }
            
        } else {
            showNoInternetAlert()
        }
        
    }
}
