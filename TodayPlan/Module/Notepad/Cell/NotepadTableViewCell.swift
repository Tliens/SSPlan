//
//  NotepadTableViewCell.swift
//  TodayPlan
//
//  Created by Quinn on 2021/9/23.
//

import UIKit

class NotepadTableViewCell: UITableViewCell {
    
    @IBOutlet weak var topTagView: UIImageView!
    @IBOutlet weak var titleLabel: AnimateDeleteLabel!
    @IBOutlet weak var timeLabel: UILabel!
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    func update(title:String,time:String,isDone:Bool,isTop:Bool){
        self.timeLabel.text = time
        self.titleLabel.text = title
        if isDone{
            self.titleLabel.textColor = .hex("#6E6E6E")
            self.titleLabel.progress = 1
            self.titleLabel.setNeedsDisplay()
        }else{
            self.titleLabel.textColor = .hex("#212121")
            self.titleLabel.progress = 0
            self.titleLabel.setNeedsDisplay()
        }
        topTagView.isHidden = !isTop
    }
    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        
    }
    
}
