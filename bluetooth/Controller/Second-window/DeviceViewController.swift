//
//  DeviceViewController.swift
//  bluetooth
//
//  Created by 王柏崴 on 8/29/23.
//

import UIKit

class DeviceViewController: UIViewController, UITableViewDataSource, UITableViewDelegate {
    
    // MARK: - IBOutlet
    
    @IBOutlet weak var tvDeviceInfo: UITableView!
    // MARK: - Variables
    
    weak var deviceVCdelegate: DeviceVCDelegate?
    
    var safe: Bool = true
    
    // MARK: - LifeCycle
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        setupUI()
    }
    // MARK: - UI Settings
    
    func setupUI() {
        
        setuptvDeviceInfo()
        setupNavigation()
    }
    
    // 設置導航欄介面
    func setupNavigation() {
       
        let navBar = UINavigationBar(frame: CGRect(x: 0, y: 0, width: self.view.frame.width, height: 50))
        let navItem = UINavigationItem(title: "DeviceName")
        navBar.setItems([navItem], animated: false)
        self.view.addSubview(navBar)
    }
    
    func setuptvDeviceInfo() {
        tvDeviceInfo.delegate = self
        tvDeviceInfo.dataSource = self
        tvDeviceInfo.register(DeviceInfoTableViewCell.self, forCellReuseIdentifier: "infoCell")
        tvDeviceInfo.rowHeight = 55
        tvDeviceInfo.layer.cornerRadius = 10
        tvDeviceInfo.layer.masksToBounds = true
        tvDeviceInfo.layer.borderWidth = 1
        tvDeviceInfo.layer.borderColor = UIColor.systemGray.cgColor
        tvDeviceInfo.isScrollEnabled = false
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        
        return 1
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        let cell = tableView.dequeueReusableCell(withIdentifier: "infoCell", for: indexPath)
        configureCell(cell as! DeviceInfoTableViewCell, forItemAt: indexPath)
        return cell
    }
    
    func configureCell(_ cell: DeviceInfoTableViewCell, forItemAt indexPath: IndexPath) {
        
        // 設置 cell 文字
        cell.textLabel?.text = "忘記此裝置設定"

        // 設置 cell 文字置中
        cell.textLabel?.textAlignment = .center
        
        // 設置 cell 背景顏色
        cell.backgroundColor = UIColor.systemRed
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
     
        handleRepeatRowSelection()
    }
    
    func handleRepeatRowSelection() {
            
        let alert = UIAlertController(title: "忘記此裝置設定", message: "確定要忘記此裝置設定?", preferredStyle: .alert)
        
        let okAction = UIAlertAction(title: "確定", style: .default) { (action) in
            
            self.deviceVCdelegate?.didForgetDevice(isClick: self.safe)
            
            //self.navigationController?.popViewController(animated: true)  使用 push 時回收
            self.dismiss(animated: true, completion: nil) //使用 present 時回收
        
        }
        
        let cancelAction = UIAlertAction(title: "取消", style: .cancel) { (action) in
            
            if let selectedIndexPath = self.tvDeviceInfo.indexPathForSelectedRow,
               
               let _ = self.tvDeviceInfo.cellForRow(at: selectedIndexPath) {
                // 取消選擇 cell
                self.tvDeviceInfo.deselectRow(at: selectedIndexPath, animated: true)
            }
        }
        alert.addAction(okAction)
        alert.addAction(cancelAction)
        
        present(alert, animated: true, completion: nil)
    }
}

// MARK: - Protocol

protocol DeviceVCDelegate: AnyObject {

    func didForgetDevice(isClick: Bool)
}
