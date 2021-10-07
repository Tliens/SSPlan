//
//  PlanChooseDateCollectionViewCell.swift
//  TodayPlan
//
//  Created by Quinn on 2021/9/15.
//

import UIKit
import SpeedySwift
class PlanChooseDateCollectionViewCell: UICollectionViewCell {

    @IBOutlet weak var titleView: UILabel!
    override init(frame: CGRect) {
        super.init(frame: frame)
        setup()
    }
    required init?(coder: NSCoder) {
        super.init(coder: coder)
        setup()
    }
    func setup(){
        contentView.cornerRadius = 8
    }
    func update(date:Date,isChoose:Bool,isCanSelected:Bool){
        titleView.text = "\(date.day())"
        if !isCanSelected{
            if isChoose{
                contentView.backgroundColor = .hex("#F6F6F6")
                titleView.textColor = .hex("#000000",alpha:0.25)
                contentView.border(color: .hex("#000000", alpha: 0.5), width: 2)
            }else{
                contentView.backgroundColor = .hex("#F6F6F6")
                titleView.textColor = .hex("#000000",alpha:0.25)
                contentView.border(color: .clear, width: 2)
            }
        }else{
            if isChoose{
                contentView.backgroundColor = .hex("#0091FF")
                titleView.textColor = .white
                contentView.border(color: .clear, width: 2)
            }else{
                contentView.backgroundColor = .white
                titleView.textColor = .hex("#000000")
                contentView.border(color: .hex("#0091FF", alpha: 1), width: 2)
            }
        }
    }

    
}
