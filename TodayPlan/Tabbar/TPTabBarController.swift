//
//  TPTabBarController.swift
//  TodayPlan
//
//  Created by Quinn on 2021/9/8.
//

import UIKit
import SpeedySwift
class TPTabBarController: SSTabBarController {
    let planVc = PlanHomeViewController()
    let notepadVc = NotepadViewController()
    let meVc = MeViewController()
    override func viewDidLoad() {
        super.viewDidLoad()
        initialize(color: "FFFFFF")
        deleteBlackLine()
        
        addChildViewController(planVc, title: "今日计划", imageName: "tab_plan_unselected", selectedImageName: "tab_plan_selected", index: 1, normal: .hex("#000000"), selected: .hex("#0091FF"))
        addChildViewController(notepadVc, title: "记事本", imageName: "tab_timeforest_unselected", selectedImageName: "tab_timeforest_selected", index: 1, normal: .hex("#000000"), selected: .hex("#0091FF"))
        addChildViewController(meVc, title: "我的", imageName: "tab_me_unselected", selectedImageName: "tab_me_selected", index: 1, normal: .hex("#000000"), selected: .hex("#0091FF"))
        
        selectedIndex = 1
    }

    override func selectedTab(at index: Int, isDouble: Bool) {
        
    }
}
