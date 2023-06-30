//
//  ViewController.swift
//  Radius
//
//  Created by iMac on 29/06/23.
//

import UIKit

class ViewController: UIViewController {
    
    //MARK: - OUTLETS
    @IBOutlet weak var tblFacilities: UITableView!
    
    
    //MARK: - VARIABLES
    var arrFacilities: [Facilities]?
    var arrExclusion: [[Exclusions]]?
    var dictSelection = [String:String]()
    
    //MARK: - VIEW LIFECYCLE
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
        
        Initialize()
    }
    
    //MARK: - INITIALIZE METHOD
    func Initialize()
    {
        getData()
    }
    
    //MARK: - OTHER METHOD/FUNCTION
    
    func getData() {
        Service.shareInstance.GetFacilityAPICall() { (facilitiesData, error) in
            if (facilitiesData != nil){
                
                self.arrFacilities = facilitiesData?.facilities
                self.arrExclusion = facilitiesData?.exclusions
                
                DispatchQueue.main.async {
                    // reload table
                    self.tblFacilities.reloadData()
                }
            }
        }
    }
    
    func isDisable(_ indexpath: IndexPath) -> Bool {
        
        var isDisable = false
        
        for key in dictSelection.keys {
            
            let selectedFacilityId = key
            let selectedOptionId = dictSelection[key]
            
            let currentFacilityId = arrFacilities?[indexpath.section].facilityId ?? ""
            let currentOptionId = arrFacilities?[indexpath.section].options?[indexpath.item].id ?? ""
            
            if !isDisable {
                arrExclusion?.forEach({ arr in
                    let obj = arr.filter{ $0.facility_id == selectedFacilityId }.first
                    if obj?.facility_id == selectedFacilityId && obj?.options_id == selectedOptionId {
                        arr.forEach { subArr in
                            if (subArr.facility_id == currentFacilityId && subArr.options_id == currentOptionId) && (subArr.facility_id != selectedFacilityId && subArr.options_id != selectedOptionId) {
                                isDisable = true
                            }
                        }
                        
                    }
                })
            }
        }
        
        return isDisable
        
    }
}

extension ViewController: UITableViewDelegate, UITableViewDataSource {
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        
        if (self.arrFacilities?.count ?? 0) == 0
        {
            tableView.setEmptyMessage("No data available")
        }else
        {
            tableView.restore()
        }
        
        return self.arrFacilities?.count ?? 0
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        guard let cell = tableView.dequeueReusableCell(withIdentifier: "tblFacilitiesCell", for: indexPath) as? tblFacilitiesCell else { return UITableViewCell() }
        
        if let dict = self.arrFacilities?[indexPath.row]
        {
            cell.lblFacilityTitle.text = dict.name
        }
        
        runOnMainThread {
            cell.viewMain.shadowAllSides(color: UIColor.darkGray)
        }
        
        self.tblFacilities.setNeedsLayout()
        self.tblFacilities.layoutIfNeeded()
        
        cell.clvFacilityOptions.delegate = self
        cell.clvFacilityOptions.dataSource = self
        cell.clvFacilityOptions.tag = indexPath.row
        cell.clvFacilityOptions.register(UINib(nibName: "clvFacilityOptionCell", bundle: nil), forCellWithReuseIdentifier: "clvFacilityOptionCell")
        cell.clvFacilityOptions.reloadData()
        
        return cell
        
    }
    
}

extension ViewController : UICollectionViewDelegate,UICollectionViewDataSource,UICollectionViewDelegateFlowLayout
{
    func numberOfSections(in collectionView: UICollectionView) -> Int {
        return 1
    }
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        
        if (self.arrFacilities?[collectionView.tag].options?.count ?? 0) == 0
        {
            collectionView.setEmptyMessage("No data available")
        }else
        {
            collectionView.restore()
        }
        
        return self.arrFacilities?[collectionView.tag].options?.count ?? 0
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "clvFacilityOptionCell", for: indexPath) as! clvFacilityOptionCell
        
        if let dict = arrFacilities?[collectionView.tag].options?[indexPath.row]
        {
            cell.lblOptionTitle.text = dict.name
            
            cell.imgOption.image = UIImage(named: dict.icon ?? "")
            
            cell.viewMain.borderWidth = 1.0
            cell.viewMain.borderColor = UIColor.lightGray
            cell.viewMain.cornerRadius = 8.0
            
            let currentFacilityId = arrFacilities?[collectionView.tag].facilityId ?? ""
            let currentOptionId = arrFacilities?[collectionView.tag].options?[indexPath.row].id ?? ""
            
            if dictSelection[currentFacilityId] == currentOptionId {
                cell.viewSelected.isHidden = false
            } else {
                cell.viewSelected.isHidden = true
            }
            
            let currentIndexPath = IndexPath(item: indexPath.row, section: collectionView.tag)
            cell.viewMain.backgroundColor = isDisable(currentIndexPath) ? .red : .white
        }
        
        return cell
        
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        
        let facilityId = arrFacilities?[collectionView.tag].facilityId ?? ""
        let optionId = arrFacilities?[collectionView.tag].options?[indexPath.row].id ?? ""
        
        let currentIndexPath = IndexPath(item: indexPath.row, section: collectionView.tag)
        if !isDisable(currentIndexPath) {
            if dictSelection[facilityId] == optionId {
                dictSelection[facilityId] = nil
            } else {
                dictSelection[facilityId] = optionId
            }
            
            self.tblFacilities.reloadData()
        }
        
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        
        return CGSize(width: 110.0, height: 110.0)
        
    }
}
