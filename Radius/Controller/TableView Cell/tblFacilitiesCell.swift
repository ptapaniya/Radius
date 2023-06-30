//
//  tblFacilitiesCell.swift
//  Radius
//
//  Created by iMac on 30/06/23.
//

import UIKit

class tblFacilitiesCell: UITableViewCell {

    //MARK: - OUTLETS

    @IBOutlet weak var viewMain: UIView!
    @IBOutlet weak var lblFacilityTitle: UILabel!
    @IBOutlet weak var clvFacilityOptions: UICollectionView!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }

}
