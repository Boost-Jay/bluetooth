//
//  MainViewController.swift
//  bluetooth
//
//  Created by 王柏崴 on 8/28/23.
//


import UIKit
import CoreBluetooth

class MainViewController: UIViewController {
    
    // MARK: - IBOutlet
    
    @IBOutlet weak var tvMain: UITableView!
    
    @IBOutlet weak var btn: UIButton!
    
    @IBOutlet weak var lbLightCatch: UILabel!
    
    // MARK: - Variables
    
    var isSwitchOn = false  //追蹤 UISwitch 的狀態
    var connectPeripherals: [CBPeripheral] =  []
    var connectServices: [CBService]?
    var connectName: [String] = []
    var selectedIndexPath: IndexPath?
    
    var connectedPeripheral: CBPeripheral?
    var centralManager: CBCentralManager?
    
    //var isOpen: Bool?
    var isSelect: Bool = false
    
    var isChange: Bool = false {
            didSet {
                if isChange {
                    // 更新 lbConnect.text
                    if let cell = findCorrespondingCell() as? DeviceNameTableViewCell {
                        cell.lbConnect.text = "未連接"
                        cell.accessoryView = nil
                    }
                }
                isChange = false
            }
        }
    
    // MARK: - LifeCycle
    
    override func viewDidLoad() {
        super.viewDidLoad()
//        let deviceCell = DeviceNameTableViewCell()
//        deviceCell.dnVCelldelegate = self
        BluetoothServices.shared.delegate = self
        setupUI()
    }

    // MARK: - UI Settings
    func setupUI() {
        setupNavigation()
        setuptvMain()
        setuplbLightCatch()
    }
    
    func setuplbLightCatch() {
        lbLightCatch.layer.cornerRadius = 10
        lbLightCatch.layer.masksToBounds = true
        lbLightCatch.layer.borderColor = UIColor.systemGreen.cgColor
        lbLightCatch.layer.borderWidth = 3
    }
    
    func setupNavigation() {
        navigationController?.navigationBar.barTintColor = .systemYellow
        navigationController?.navigationBar.prefersLargeTitles = true
        navigationItem.title = "藍芽"
        
        let bar = UINavigationBarAppearance()
        bar.backgroundColor = UIColor.yellow
        bar.titleTextAttributes =
        [NSAttributedString.Key.foregroundColor: UIColor.black]
        navigationController?.navigationBar.scrollEdgeAppearance = bar
        navigationController?.navigationBar.standardAppearance = bar
        navigationController?.navigationBar.tintColor = .black
    }
    
    func setuptvMain() {
        tvMain.register(UITableViewCell.self, forCellReuseIdentifier: "switchCell")
        tvMain.register(UINib(nibName: "DeviceNameTableViewCell", bundle: nil), forCellReuseIdentifier: "DeviceNameCell")
        tvMain.register(UITableViewCell.self, forCellReuseIdentifier: "textCell")
        tvMain.register(UITableViewCell.self, forCellReuseIdentifier: "textEndCell")
        tvMain.dataSource = self
        tvMain.delegate = self
    }
    
//    func jump() {
//        // 加載 DeviceViewController 的 XIB
//        let deviceVC = DeviceViewController()
//
//        // 設定 sheetPresentationController 的 detents 屬性
//        if let sheetPresentationController = deviceVC.sheetPresentationController {
//            sheetPresentationController.detents = [.custom(resolver: { context in
//                300
//            })]
//            sheetPresentationController .preferredCornerRadius = 100
//        }
//
//        // 呈現 DeviceViewController
//        navigationController?.present(deviceVC, animated: true, completion: nil)
//    }
    
    // MARK: - IBAction
//    @IBAction func jump(_ sender: Any) {
//        // 加載 DeviceViewController 的 XIB
//        let deviceVC = DeviceViewController(nibName: "DeviceViewController", bundle: nil)
//
//        // 設定 sheetPresentationController 的 detents 屬性
//        if let sheetPresentationController = deviceVC.sheetPresentationController {
//            sheetPresentationController.detents = [.custom(resolver: { context in
//                300
//            })]
//            sheetPresentationController .preferredCornerRadius = 100
//        }
//
//        // 呈現 DeviceViewController
//        present(deviceVC, animated: true, completion: nil)
//    }
}

// MARK: - Extension
extension MainViewController: UITableViewDelegate, UITableViewDataSource {
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if section == 0 {
            return 2 // 一個用於 Switch，一個用於文字
        } else if section == 1 {
            return connectName.count
        } else {
            return 1
        }
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
            
//            if indexPath.row == 0 {
//                return 100
//            } else {
                return 50
//            }
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        if indexPath.section == 0 {
            if indexPath.row == 0 {
                
                // 這個 cell 用於顯示 Switch
                let cell = tableView.dequeueReusableCell(withIdentifier: "switchCell", for: indexPath)
                
                // 移除舊的 backgroundView
                for view in cell.contentView.subviews {
                    view.removeFromSuperview()
                }
                
                cell.textLabel?.text = "藍芽"
                
                // 創建一個新的 UIView
                let backgroundView = UIView(frame: CGRect(x: 10, y: 0, width: cell.frame.width - 20, height: cell.frame.height+42))
                
                // 設置 UIView 的背景顏色
                backgroundView.backgroundColor = UIColor.systemGreen.withAlphaComponent(0.5)
                // 設置圓角
                backgroundView.layer.cornerRadius = 10
                
                // 將 UIView 添加到 cell 的 contentView 上
                cell.contentView.addSubview(backgroundView)
                
                // 將 UIView 移到最底層，這樣其他 cell 內容會顯示在其上方
                cell.contentView.sendSubviewToBack(backgroundView)
                
                // 創建 UISwitch 並設為 cell 的 accessoryView
                let swtTV = UISwitch(frame: .zero)
                swtTV.isOn = false
                cell.accessoryView = swtTV
                
                if indexPath.section == 0 && indexPath.row == 0 {
                    // 創建 UISwitch 並設為 cell 的 accessoryView
                    let swtTV = UISwitch(frame: .zero)
                    swtTV.isOn = isSwitchOn  // 根據變數設定初始狀態
                    swtTV.onTintColor = UIColor.orange
                    swtTV.addTarget(self, action: #selector(switchChanged(_:)), for: .valueChanged)  // 添加事件監聽
                    cell.accessoryView = swtTV
                }
                
                return cell
                
            } else {
                // 這個 cell 用於顯示文字
                let cell = tableView.dequeueReusableCell(withIdentifier: "textCell", for: indexPath)
                if isSwitchOn {
                    cell.textLabel?.text = "『藍芽』開啟時，此設備可被偵測為『我D裝置』"
                } else {
                    cell.textLabel?.text = "SeaDrop、SeaPlay、『迷路服務』都使用藍芽"
                }
                cell.textLabel?.font = UIFont.systemFont(ofSize: 14)
                cell.selectionStyle = .none
                cell.isUserInteractionEnabled = false
                return cell
                
            }
        } else if indexPath.section == 1 {
            let cell = tableView.dequeueReusableCell(withIdentifier: "DeviceNameCell", for: indexPath) as! DeviceNameTableViewCell
            cell.dnVCelldelegate = self // 設定代理
            cell.lbDevice.text = "\(connectName[indexPath.row])"

            let checkmarkView = UIImageView(image: UIImage(systemName: "checkmark"))
            cell.accessoryView = nil
            if indexPath == selectedIndexPath {
                cell.accessoryView = checkmarkView
            } else {
                cell.accessoryView = nil
            }
            
            return cell
        } else {
            let cell = tableView.dequeueReusableCell(withIdentifier: "textEndCell", for: indexPath)
            cell.textLabel?.text = "若有其他問題煩請自行解決,本產品售出後恕不退貨😘"
            cell.textLabel?.font = UIFont.systemFont(ofSize: 13)
            
            cell.backgroundColor = UIColor.systemOrange
                
            return cell
        }
    }
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return isSwitchOn ? 3 : 1  // 根據 UISwitch 的狀態返回 section 數量
    }
    
    // MARK: - UITableViewDelegate
    func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        if section == 0 || section == 2 {
                return nil
            }
        
        let headerView = UIView(frame: CGRect(x: 0, y: 0, width: tableView.frame.width, height: 40))
        headerView.backgroundColor = UIColor.systemOrange
        
        let headerLabel = UILabel(frame: CGRect(x: 15, y: 5, width: tableView.frame.width - 30, height: 30))
        
       
        headerLabel.text = "所有裝置"
        
        headerLabel.textColor = UIColor.black
        headerLabel.font = UIFont.systemFont(ofSize: 12)  // 設定字體大小為 12
        headerView.addSubview(headerLabel)
        
        return headerView
    }
    
    func tableView(_ tableView: UITableView, willSelectRowAt indexPath: IndexPath) -> IndexPath? {
        if indexPath.section == 1 {
            return indexPath  // 允許 section 1 的 cell 被選擇
        } else {
            return nil  // 不允許其他 section 的 cell 被選擇
        }
    }

    
    func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        return 50
    }

    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        
        if let cell = tableView.cellForRow(at: indexPath) as? DeviceNameTableViewCell {
            
            cell.lbConnect.text = "已連接"
            
            if indexPath == selectedIndexPath {
                cell.accessoryView = nil
                selectedIndexPath = nil
            } else {
                let checkmarkView = UIImageView(image: UIImage(systemName: "checkmark"))
                cell.accessoryView = checkmarkView
                selectedIndexPath = indexPath
            }
        }
        
        
        let peripheral = connectPeripherals[indexPath.row]
        
//        let selectedCell = tableView.cellForRow(at: indexPath)
//        for cell in tableView.visibleCells {
//            if cell != selectedCell {
//
//                cell.accessoryView = nil
//            }
//        }
//        let checkmarkView = UIImageView(image: UIImage(systemName: "checkmark"))
//        selectedCell?.accessoryView = checkmarkView
//
//        selectedCell?.isSelected = true
        BluetoothServices.shared.connectPeripheral(peripheral: peripheral)
    }
    
//    func tableView(_ tableView: UITableView, canEditRowAt indexPath: IndexPath) -> Bool {
//        if indexPath.section == 0 {
//            return false
//        } else {
//            return true
//        }
//    }
    
    @objc func switchChanged(_ sender: UISwitch) {
        isSwitchOn = sender.isOn  // 更新變數
        tvMain.reloadData()  // 重新載入 table view 以更新 section 數量
    }
    
}

extension MainViewController: BluetoothServicesDelegate, CBPeripheralDelegate {
    
    func didUpdateConnectionStatus(_ status: String) {
        print("123")
    }
    
    
    func getBLEPeripherals(peripherals: [CBPeripheral]) {
        
        for i in peripherals {
            if !connectName.contains(i.name!) {
                connectName.append(i.name!)
            }
        }
        
        for peripheral in peripherals {
            if !connectPeripherals.contains(peripheral){
                connectPeripherals.append(peripheral)
            }
        }
        DispatchQueue.main.async { [self] in
            tvMain.reloadData()
        }
    }
    
    func getBlEPeripheralValue(value: UInt8) {
        
        DispatchQueue.main.async { [self] in
            lbLightCatch.text = "\(value)"
        }
    }
}


// MARK: - Protocol

extension MainViewController: DeviceNameCellDelegate {
    
    func didTapInfoButton() {
        
//        isOpen = isClick
//        if isOpen == true {
        let deviceVC = DeviceViewController()
        
        // 設定 sheetPresentationController 的 detents 屬性
        if let sheetPresentationController = deviceVC.sheetPresentationController {
            sheetPresentationController.detents = [.custom(resolver: { context in
                300
            })]
            sheetPresentationController .preferredCornerRadius = 100
        }
        
        // navigationController?.present(deviceVC, animated: true)
        present(deviceVC, animated: true, completion: nil)
//        } else {
//            return
//        }
    }
}

extension MainViewController:DeviceVCDelegate {
    
    func didForgetDevice(isClick: Bool) {
        
        if isSelect == isClick {
            
            // 檢查是否有已連接的藍牙裝置
            if let peripheral = connectedPeripheral {
                // 使用centralManager來取消連接
                centralManager?.cancelPeripheralConnection(peripheral)
            }
            
            isChange = isClick
        }
        
       
    }
}

