//
//  NotepadAddViewController.swift
//  TodayPlan
//
//  Created by Quinn on 2021/9/24.
//

import UIKit
import GrowingTextView
import SpeedySwift
class NotepadAddViewController: SSFullViewController {

    @IBOutlet weak var textView: GrowingTextView!
    var model:NotepadItemModel?
    var doneBtnCallback:((_ str:String)->Void)?
    var keyboardOberver:KeyboardOberver?
    var lastContent = ""
    override func viewDidLoad() {
        super.viewDidLoad()
        
        textView.layer.cornerRadius = 4.0
        textView.placeholder = "我想..."
        textView.font = UIFont.systemFont(ofSize: 15)
        textView.minHeight = 30
        textView.maxHeight = 150
        textView.returnKeyType = .done
        textView.delegate = self
        textView.text = model?.title
        textView.becomeFirstResponder()
        lastContent = model?.title ?? ""
        
    }
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        keyboardOberver = KeyboardOberver()
        keyboardOberver?.addKeyboardNotification()
        keyboardOberver?.keyboardNotificationHandler = { [weak self](state, notifi, height, identifier) in
            if state == .hide{
                guard let self = self else{
                    return
                }
                if self.lastContent != self.textView.text{                    
                    self.doneBtnCallback?(self.textView.text)
                }
                self.textView.resignFirstResponder()
                self.miss()
            }
        }
    }
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        keyboardOberver?.removeKeyboardNotification()
    }
    @IBAction func tapGestureAction(_ sender: Any) {
        textView.resignFirstResponder()
    }
    
}
extension NotepadAddViewController: GrowingTextViewDelegate {
        
    func textViewDidChangeHeight(_ textView: GrowingTextView, height: CGFloat) {
        UIView.animate(withDuration: 0.3, delay: 0.0, usingSpringWithDamping: 0.7, initialSpringVelocity: 0.7, options: [.curveLinear], animations: { () -> Void in
            self.view.layoutIfNeeded()
        }, completion: nil)
    }
    func textView(_ textView: UITextView, shouldChangeTextIn range: NSRange, replacementText text: String) -> Bool {
        if text == "\n"{
            textView.resignFirstResponder()
            return false
        }
        return true
    }
}
