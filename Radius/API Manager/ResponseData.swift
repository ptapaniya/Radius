//
//  ResponseData.swift
//  Radius
//
//  Created by iMac on 29/06/23.
//

import UIKit

struct ResponseData {
    
    fileprivate var data: Data
    init(data: Data) {
        self.data = data
    }
}

extension ResponseData {
    
      public func decode<T: Codable>(_ type: T.Type) -> (decodedData: T?, error: Error?) {
        
        let jsonDecoder = JSONDecoder()
        do {
            let response = try  jsonDecoder.decode(T.self, from: data)
            return (response, nil)
        }
        catch let error {
            DLog(error.localizedDescription)
            return (nil, error)
        }
    }
}

func objectToData(stringArray: Any) -> Data? {
  return try? JSONSerialization.data(withJSONObject: stringArray, options: [])
}
