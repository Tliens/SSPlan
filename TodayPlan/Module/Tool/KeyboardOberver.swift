//
//  KeyboardOberver.swift
//  TPlan
//
//  Created by Quinn Von on 2/28/20.
//  Copyright © 2020 Better. All rights reserved.
//

import Foundation
import UIKit

enum KeyBoardState{
    case show
    case hide
}
class KeyboardOberver{
    //用于标识不同的编辑位置
    var identifier:String = String.identifier
    var state = KeyBoardState.hide
    deinit {
        removeKeyboardNotification()
    }
    var keyboardNotificationHandler:((_ state:KeyBoardState,_ notification:Notification, _ height:CGFloat,_ identifier:String)->())?
    //添加
    func addKeyboardNotification(){
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillShow(_:)), name:UIResponder.keyboardWillShowNotification, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillHide(_:)), name:UIResponder.keyboardWillHideNotification, object: nil)

    }
    //移除
    func removeKeyboardNotification(){
        NotificationCenter.default.removeObserver(self, name: UIResponder.keyboardWillShowNotification, object: nil)
        NotificationCenter.default.removeObserver(self, name: UIResponder.keyboardWillHideNotification, object: nil)
    }
    
    @objc func keyboardWillShow(_ notification: NSNotification) {
        keyboardNotification(state: .show, notification:notification as Notification)
    }
    
    @objc func keyboardWillHide(_ notification: NSNotification) {
        keyboardNotification(state: .hide, notification:notification as Notification)
    }
    
    //重写此方法 实现监听键盘
    func keyboardNotification(state:KeyBoardState,notification:Notification){
        let keyboardHeight = (notification.userInfo![UIResponder.keyboardFrameEndUserInfoKey] as! NSValue).cgRectValue.height
        self.state = state
        keyboardNotificationHandler?(state,notification,keyboardHeight,identifier)
    }
}
