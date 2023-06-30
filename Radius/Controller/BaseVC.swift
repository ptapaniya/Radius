//
//  BaseVC.swift
//  Radius
//
//  Created by iMac on 29/06/23.
//

import UIKit
import NVActivityIndicatorView

class BaseVC: UIViewController, UIGestureRecognizerDelegate, NVActivityIndicatorViewable{
    
    //MARK: - VARIABLES
    var reachability: Reachability = Reachability()!
    
    var hasSafeArea: Bool {
        guard let topPadding = UIApplication.shared.keyWindow?.safeAreaInsets.top, topPadding > 24 else {
            return false
        }
        return true
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
      
    }
    
    
    //MARK: - **********************  REGISTER XIB **********************
    
    func registerTableViewCell(cellName : String , to tableView: UITableView) {
        
        let cellNIB = UINib(nibName: cellName, bundle: nil)
        tableView.register(cellNIB, forCellReuseIdentifier: cellName)
    }

    
    //  MARK: - Loader Methods
    func createMainLoaderInView(_ message : String) {
        runOnMainThread {
            let size = CGSize(width: 40, height: 40)
            self.startAnimating(size, message: message, type: .ballSpinFadeLoader)
        }
    }
    
    func stopLoaderAnimation() {
        runOnMainThread {
            self.stopAnimating()
        }
    }
   
}
