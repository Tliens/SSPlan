//
//  FaceTouchIDCheckViewController.swift
//  App1125
//
//  Created by Quinn on 2021/1/7.
//

import Foundation
import SpeedySwift
import LTMorphingLabel
import Schedule
import SwiftDate
import MMKV
class FaceTouchIDCheckViewController:SSFullViewController{
    
    @IBOutlet weak var totalPlanLabel: UILabel!
    @IBOutlet weak var totalNotepadLabel: UILabel!
    @IBOutlet weak var totalDoneNotepadLabel: UILabel!
    @IBOutlet weak var totalRecoverNotepadLabel: UILabel!
    @IBOutlet weak var totalDeleteNotepadLabel: UILabel!
    
    private var contentLabel = LTMorphingLabel(text: "", textColor: .hex("#333333"), textFont: UIFont.sc_medium(size: 20))

    var ENTER_BACKGROUND = false
    var ENTER_USERLOCK = false

    let imageView = UIImageView(image: UIImage(named: "password_app_icon")!)
    var task : Task?
    let passwordButton:UIButton = {
        let btn = UIButton()
        btn.setImage(nil, for: .normal)
        btn.backgroundColor = UIColor.white
        btn.cornerRadius = 12.scale
        btn.title = "解锁"
        btn.titleFont = UIFont.sc_semibold(size: 16)
        btn.setTitleColor(UIColor.hex("#0091FF"), for: .normal)
        btn.addTarget(self, action: #selector(unlock), for: .touchUpInside)
        return btn
    }()
    override func viewDidLoad() {
        super.viewDidLoad()
        view.addSubview(imageView)
        view.addSubview(passwordButton)
        view.addSubview(contentLabel)
        view.backgroundColor = .hex("#F2F2F2")
        imageView.contentMode = .scaleAspectFill
        imageView.snp.makeConstraints { (maker) in
            maker.top.equalToSuperview().offset(80)
            maker.centerX.equalToSuperview()
            maker.width.height.equalTo(68)
        }
        passwordButton.snp.makeConstraints { (maker) in
            maker.height.equalTo(60.scale)
            maker.left.equalTo(30.scale)
            maker.right.equalTo(-30.scale)
            maker.bottom.equalToSuperview().offset(-SS.safeBottomHeight - 60.scale)
        }
        contentLabel.snp.makeConstraints { (maker) in
            maker.left.equalTo(20)
            maker.right.equalTo(-20)
            maker.top.equalTo(imageView.snp.bottom).offset(0)
            maker.height.equalTo(80)
        }
        
        contentLabel.numberOfLines = 0
        contentLabel.textAlignment = .center
        contentLabel.morphingEffect = .fall
        
        task = Plan.every(1.second).do {[weak self] in
            let time = Date()
            let days = 364-time.dayOfYear
            let hours = 23 - time.hour
            let minutes = 59 - time.minute
            let seconds = 60 - time.second
            self?.contentLabel.text = "今年还剩\(days)天" + "\(hours)小时\(minutes)分钟\(seconds)秒"
        }
    }
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        totalPlanLabel.text = "最近一年共有 \(PlanModel.totalTodayPlan()) 个计划日"
        let add_Notepad_count = MMKV.default()!.int64(forKey: "add_Notepad_count", defaultValue: 0)
        totalNotepadLabel.text = "共添加过 \(add_Notepad_count) 个记事"
        let done_Notepad_count = MMKV.default()!.int64(forKey: "done_Notepad_count", defaultValue: 0)
        totalDoneNotepadLabel.text = "标记完成 \(done_Notepad_count) 次记事"
        let recover_Notepad_count = MMKV.default()!.int64(forKey: "recover_Notepad_count", defaultValue: 0)
        totalRecoverNotepadLabel.text = "重新打开过 \(recover_Notepad_count) 次记事"
        let delete_Notepad_count = MMKV.default()!.int64(forKey: "delete_Notepad_count", defaultValue: 0)
        totalDeleteNotepadLabel.text = "删除过 \(delete_Notepad_count) 次记事"
    }
    @objc func unlock(){
        SSTapBuzz.light()
        FaceTouchIDCheckManager.shared.showPasscodeAuthentication(message: "使用密码解锁", success: {
            DispatchQueue.main.async {
                if self.ENTER_BACKGROUND || self.ENTER_USERLOCK {
                    self.ENTER_USERLOCK = false
                    self.dismiss(animated: true, completion: nil)
                }else{
                    UIApplication.shared.keyWindow?.rootViewController = APP_TABBAR
                }
            }
        }, failure: {_ in
            
        })
    }
}
