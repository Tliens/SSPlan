//
//  MeViewCell.swift
//  TodayPlan
//
//  Created by Quinn on 2021/9/30.
//

import UIKit

class MeViewCell: UITableViewCell {

    @IBOutlet weak var nameLabel: UILabel!
    
    @IBOutlet weak var switchBtn: UISwitch!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    
    func update(title:String,isOpen:Bool){
        nameLabel.text = title
        switchBtn.isOn = isOpen
    }
    
}
