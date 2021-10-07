//
//  PlanHomeTableViewCell.swift
//  TodayPlan
//
//  Created by Quinn on 2021/9/8.
//

import UIKit

class PlanHomeTableViewCell: UITableViewCell {

    @IBOutlet weak var infoLabel: UILabel!
    
    @IBOutlet weak var planTagView: UIImageView!
    override func awakeFromNib() {
        super.awakeFromNib()
        
        
    }

   
    func updateCell(title:String,isDone:Bool){
        self.infoLabel.text = title
        planTagView.image = isDone ? UIImage(named: "plan_tag_yes") : UIImage(named: "plan_tag_no")
    }
    
}
