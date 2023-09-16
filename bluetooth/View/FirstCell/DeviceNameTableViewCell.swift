//
//  DeviceNameTableViewCell.swift
//  bluetooth
//
//  Created by 王柏崴 on 9/15/23.
//

import UIKit

class DeviceNameTableViewCell: UITableViewCell {
    
    weak var dnVCelldelegate: DeviceNameCellDelegate?
    
    // MARK: - IBOutlet
    
    @IBOutlet weak var lbDevice: UILabel!
    @IBOutlet weak var lbConnect: UILabel!
    @IBOutlet weak var btnInfo: UIButton!
    var click: Bool = false

    // MARK: - IBAction
    
    @IBAction func btnInfoTapped(_ sender: Any) {

        //dnVCelldelegate?.didTapInfoButton(isClick: !click)
        dnVCelldelegate?.didTapInfoButton()
    }
}

// MARK: - Protocol

protocol DeviceNameCellDelegate: AnyObject {
    
    //func didTapInfoButton(isClick: Bool)
    func didTapInfoButton()
}

