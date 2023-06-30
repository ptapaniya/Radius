//
//  APIConstants.swift
//  Radius
//
//  Created by iMac on 29/06/23.
//

import UIKit

struct APIServerConstants {
    static let liveServerURL = URL(string: "https://my-json-server.typicode.com/")!
    static let serverBaseURL = liveServerURL
    static let serverTimeout = 30.0
}

protocol EndpointType {
    var apiPath: String { get }
    var apiRequestType: String { get }
}

enum APIConstants {
    
    case getFacilities
    
}

extension APIConstants: EndpointType {
    
    var apiPath: String {
        switch self {
        case .getFacilities:
            return "iranjith4/ad-assignment/db"
        }
    }
    
    var apiRequestType: String {
        
        switch self {
        case .getFacilities:
            return "GET"
        }
    }
}
