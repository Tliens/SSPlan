//
//  MeViewController.swift
//  TodayPlan
//
//  Created by Quinn on 2021/9/8.
//

import UIKit
import SpeedySwift
import MMKV
class MeViewController: SSViewController {
    
    @IBOutlet weak var tableView: UITableView!
    var titles = ["开启FaceID/指纹锁","自动生成每日计划","数据统计","建议与反馈"]
    override func viewDidLoad() {
        super.viewDidLoad()
        showFakeNavBar()
        fakeNav.titleLabel.text = "我的设置"
        fakeNav.rightButton.isHidden = false
        fakeNav.rightButton.image = UIImage(named: "share_app")
        setupTableView()
        view.backgroundColor = .hex("#F2F2F2")
    }
    
    override func handleNavigationBarButton(buttonType: SSUINavigationBarButtonType) {
        if buttonType == .right{
            let vc = VisualActivityViewController(url: URL(string: "https://apps.apple.com/cn/app/id1505020317")!)
            vc.previewNumberOfLines = 1
            presentActionSheet(vc, from: self.view)
        }
    }
    private func presentActionSheet(_ vc: VisualActivityViewController, from view: UIView) {
        if UIDevice.current.userInterfaceIdiom == .pad {
            vc.popoverPresentationController?.sourceView = view
            vc.popoverPresentationController?.sourceRect = view.bounds
            vc.popoverPresentationController?.permittedArrowDirections = [.right, .left]
        }
        
        present(vc, animated: true, completion: nil)
    }
    func setupTableView(){
        self.tableView.register(UINib(nibName:MeViewCell.named, bundle:nil),
                                forCellReuseIdentifier:MeViewCell.named)
        self.tableView.delegate = self
        self.tableView.dataSource = self
    }
    @IBAction func cleanAllDataBtnAction(_ sender: Any) {
        SSTapBuzz.warning()
        self.showAlert(title: "是否删除！", message:"删除后无法找回", buttonTitles: ["取消","删除"], highlightedButtonIndex: 1) { [weak self] index in
            if index == 1{
                self?.clearAll()
                DispatchQueue.main.asyncAfter(deadline: .now()+0.5) {
                    self?.toast(message: "已清空所有数据")
                }
            }
        }
    }
    
    func clearAll(){
        AppDefaults.defaultSystemPlanModel = ""
        MMKV.default()?.clearAll()
    }
    
    
}
extension MeViewController:UITableViewDelegate,UITableViewDataSource{
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell:MeViewCell = tableView.dequeueReusableCell(withIdentifier: MeViewCell.named)
        as! MeViewCell
        let name = titles[indexPath.row]
        if indexPath.row == 0{
            let isOpen = MMKV.default()?.bool(forKey: "face_id_open",defaultValue: false) ?? false
            cell.update(title: name, isOpen: isOpen)
            cell.switchBtn.isHidden = false
        }else if indexPath.row == 1{
            let isOpen =  MMKV.default()?.bool(forKey: "auto_generate_plan",defaultValue: true) ?? true
            cell.update(title: name, isOpen: isOpen)
            cell.switchBtn.isHidden = false
        }else {
            cell.update(title: name, isOpen: false)
            cell.switchBtn.isHidden = true
        }
        cell.switchBtn.addTarget(self, action: #selector(switchBtnAction(sender:)), for: .valueChanged)
        cell.clipsToBounds = true
        return cell
    }
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        if indexPath.row == 3{
            SSTapBuzz.success()
            showAlert(title: "建议与反馈", message: "有什么建议或者想法都可以告诉我", buttonTitles: ["取消","填写"], highlightedButtonIndex: 1) { index in
                if index == 1{
                    let url = "https://apps.apple.com/cn/app/id1505020317?action=write-review"
                    SS.jump(url: URL(string: url)!)
                }
            }
        }else if indexPath.row == 2{
            let isOpen = MMKV.default()?.bool(forKey: "face_id_open",defaultValue: false) ?? false
            if isOpen{
                if !SS.topVC()!.isKind(of: FaceTouchIDCheckViewController.self){
                    SS.topVC()?.present(FACECHECK_VC, animated: true, completion: nil)
                    FACECHECK_VC.ENTER_USERLOCK = true
                }else{
                    FACECHECK_VC.unlock()
                }
            }else{
                showAlert(title: "获取数据失败", message:"请先开启『开启FaceID/指纹锁』", buttonTitles: ["取消","开启"], highlightedButtonIndex: 1) { [weak self] index in
                    if index == 1{
                        let cell = self!.tableView.cellForRow(at: IndexPath.init(row: 0, section: 0)) as! MeViewCell
                        cell.switchBtn.isOn = true
                        self!.openFaceID(cell.switchBtn,needShow:true)
                    }
                }
            }
        }
    }
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 75
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return 4
    }
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    @objc func switchBtnAction(sender:UISwitch){
        if let indexPath = self.tableView.indexPath(by: sender){
            if indexPath.row == 0{
                openFaceID(sender)
            }else if indexPath.row == 1{
                MMKV.default()?.set(sender.isOn, forKey: "auto_generate_plan")
                showAlert(title: sender.isOn ? "设置成功" : "取消成功", message: sender.isOn ? "每天将根据默认模板自动生成计划" : "你可以再次开启", buttonTitles: ["确定"], highlightedButtonIndex: 0, completion: nil)
            }
        }
        
    }
    
    func openFaceID(_ sender:UISwitch,needShow:Bool = false){
        FaceTouchIDCheckManager.shared.showPasscodeAuthentication(message: "密码保护设置确认", success: {[weak self] in
            MMKV.default()?.set(sender.isOn, forKey: "face_id_open")
            if needShow{
                FACECHECK_VC.ENTER_USERLOCK = true
                self?.present(FACECHECK_VC, animated: true, completion: nil)
            }
        }, failure: { [weak self] msg in
            let isOpen = MMKV.default()?.bool(forKey: "face_id_open",defaultValue: false) ?? false
            sender.isOn = isOpen
            self?.showAlert(title: "Error", message: "开启保护失败")
        })
    }
}
