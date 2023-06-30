//
//  Constants.swift
//  Radius
//
//  Created by iMac on 29/06/23.
//

import Foundation
import UIKit
import Alamofire

let APP_DELEGATE = UIApplication.shared.delegate as! AppDelegate

class Connectivity {
    class var isConnectedToInternet:Bool {
        return NetworkReachabilityManager()!.isReachable
    }
}

struct defaultString
{
    static let loadingString = "Loading..."
    static let messageSomethingWrong = "Something went wrong"
    static let noRecordsFound = "No record found..."

}
