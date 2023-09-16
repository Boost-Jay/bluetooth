//
//  MainTableViewCell.swift
//  bluetooth
//
//  Created by 王柏崴 on 8/28/23.
//

import UIKit

class DeviceTableViewCell: UITableViewCell {
    
    // MARK: - IBOutlet
    @IBOutlet weak var lbDevice: UILabel!
    @IBOutlet weak var lbConnect: UILabel!
    @IBOutlet weak var btnInfo: UIButton!
    
    // MARK: - IBAction
    
    @IBAction func DeviceVC(_ sender: Any) {
        let storyboard = UIStoryboard(name: "Main", bundle: nil)
        let controller = storyboard.instantiateViewController(withIdentifier: "DeviceViewController") as! DeviceViewController
        controller.modalPresentationStyle = .fullScreen
        self.window?.rootViewController?.present(controller, animated: true, completion: nil)
    }
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
        // Configure the view for the selected state
    }
}
