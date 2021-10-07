//
//  PlanHomeSectionHeaderView.swift
//  TodayPlan
//
//  Created by Quinn on 2021/9/8.
//

import UIKit

class PlanHomeSectionHeaderView: UIView {

    let titleLabel = UILabel()
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        setup()
    }
    
    required init?(coder: NSCoder) {
        super.init(coder: coder)
        setup()
    }
    
    func setup(){
        addSubview(titleLabel)
        titleLabel.snp.makeConstraints { maker in
            maker.leading.equalToSuperview()
            maker.top.equalTo(14)
        }
        titleLabel.font = .sc_medium(size: 20)
        titleLabel.textColor = .black
        backgroundColor = .hex("#F2F2F2")
    }

}
