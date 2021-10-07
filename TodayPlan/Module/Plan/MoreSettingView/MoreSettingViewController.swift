//
//  MoreSettingViewController.swift
//  TodayPlan
//
//  Created by Quinn on 2021/9/8.
//

import UIKit
import SpeedySwift
class MoreSettingViewController: SSViewController {

    @IBOutlet weak var transformViewBottom: NSLayoutConstraint!
    @IBOutlet weak var transformView: UIView!
    var model:PlanModel?
    override init(nibName nibNameOrNil: String?, bundle nibBundleOrNil: Bundle?) {
        super.init(nibName: nibNameOrNil, bundle: nibBundleOrNil)
        modalPresentationStyle = .overCurrentContext
    }
    
    required init?(coder: NSCoder) {
        super.init(coder: coder)
        modalPresentationStyle = .overCurrentContext
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .hex("#000000", alpha: 0.4)
        transformViewBottom.constant = -217

        transformView.topCornerRadius(rect: CGRect.init(x: 0, y: 0, width: SS.w, height: 217), radius: 22)
    }

    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        transformViewBottom.constant = 0
        UIView.animate(withDuration: 0.25) {
            self.view.layoutIfNeeded()
        }
    }
    
    
    @IBAction func cancelBtnAction(_ sender: UIButton) {
        dismiss()
    }
    
    @IBAction func tapgestureAction(_ sender: UITapGestureRecognizer) {
        dismiss()
    }
    func dismiss(){
        transformViewBottom.constant = -217
        UIView.animate(withDuration: 0.25) {
            self.view.layoutIfNeeded()
        } completion: { _ in
            self.dismiss(animated: false, completion: nil)
        }
    }
    @IBAction func editBtnAction(_ sender: Any) {
        let vc = PlanEditViewController()
        if let last = self.presentingViewController as? TPTabBarController{
            dismiss()
            vc.model = last.planVc.model
            last.planVc.push(vc)
        }
    }

    @IBAction func markdownBtnAction(_ sender: Any) {
        if let markdown = model?.toShareMarkDown(){
            UIPasteboard.general.string = markdown
            SSTapBuzz.success()
            toast(message: "已复制到剪贴板")
        }
    }
    
    @IBAction func feedbackBtnAction(_ sender: Any) {
        showAlert(title: "建议与反馈", message: "有什么建议或者想法都可以告诉我", buttonTitles: ["取消","填写"], highlightedButtonIndex: 1) { index in
            if index == 1{
                let url = "https://apps.apple.com/cn/app/id1505020317?action=write-review"
                SS.jump(url: URL(string: url)!)
            }
        }
    }
}
