//
//  CommonFuncs.swift
//  Radius
//
//  Created by iMac on 29/06/23.
//

import Foundation

//MARK: - Log trace
public func DLog<T>(_ message:T,  file: String = #file, function: String = #function, lineNumber: Int = #line ) {
    #if DEBUG
    if let text = message as? String {
        
        print("\((file as NSString).lastPathComponent) -> \(function) line: \(lineNumber): \(text)")
    }
    #endif
}

//  MARK: - No internet alert
func showNoInternetAlert()  {
    runOnMainThread {
        let _ = CustomAlertController.alert(title: "Try again!", message: "No internet connection available. Please try again!")
    }
}

//MARK: - Thread Functions
public func runOnMainThread(_ block: @escaping () -> Void) {
    DispatchQueue.main.async(execute: {
        block()
    })
}

public func runOnAfterTime(afterTime : Double , block: @escaping () -> ()) {
    let dispatchTime = DispatchTime.now() + afterTime
    DispatchQueue.main.asyncAfter(deadline: dispatchTime) {
        block()
    }
}

