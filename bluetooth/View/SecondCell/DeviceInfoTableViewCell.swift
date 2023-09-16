//
//  DeviceInfoTableViewCell.swift
//  bluetooth
//
//  Created by 王柏崴 on 9/13/23.
//

import UIKit

class DeviceInfoTableViewCell: UITableViewCell {

    // 處理單元格高亮狀態的方法
    override func setHighlighted(_ highlighted: Bool, animated: Bool) {
        super.setHighlighted(highlighted, animated: animated)

        if highlighted {
            contentView.backgroundColor = UIColor.systemBlue // 如果高亮，設置背景顏色為系統藍色
        } else {
            contentView.backgroundColor = UIColor.clear // 如果不高亮，設置背景顏色為透明
        }
    }

}
