//
//  PlanEditViewController.swift
//  TodayPlan
//
//  Created by Quinn on 2021/9/11.
//

import UIKit
import SpeedySwift
import MMKV
class PlanEditViewController: SSViewController {
    @IBOutlet weak var textView: UITextView!
    
    @IBOutlet weak var tipView: UIView!
    
    @IBOutlet weak var tipViewTipLabel: UILabel!
    
    @IBOutlet weak var tipDetailView: UIView!
    
    @IBOutlet weak var excampleLabel: UILabel!
    
    @IBOutlet weak var inbutToolBar: UIView!
    
    @IBOutlet weak var editToolBar: UIView!
    
    
    @IBOutlet weak var textViewBottom: NSLayoutConstraint!
    
    @IBOutlet weak var bottomTipView: UIView!
    
    @IBOutlet weak var closeBottomTipBtn: UIButton!
    var model:PlanModel?
    var keyboardObserver:KeyboardOberver?
    var isChanged:Bool = false{
        didSet{
            if isChanged{
                self.closePopGestureRecognizer = true
            }
        }
    }
    var plan_bottom_tip_close = false{
        didSet{
            if plan_bottom_tip_close{
                closeBottomTipBtn.isHidden = plan_bottom_tip_close
                bottomTipView.isHidden = plan_bottom_tip_close
                textViewBottom.constant = 80
            }
        }
    }
    override func viewDidLoad() {
        super.viewDidLoad()
        tipViewTipLabel.attributedText = NSAttributedString(string: tipViewTipLabel.text!).wordSpaceing(1)
        excampleLabel.attributedText = NSAttributedString(string: excampleLabel.text!).wordSpaceing(1)
        tipView.isHidden = true
        setupTextView()
        
        plan_bottom_tip_close = MMKV.default()!.bool(forKey: "plan_bottom_tip_close", defaultValue: false)
        
    }
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        addKeyboardObserver()
    }
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        rmKeyboardObserver()
    }
    func setupTextView(){
        textView.delegate = self
        textView.inputAccessoryView = inbutToolBar
        textView.text = model?.toMarkDown()
        textViewDidChange(textView)
        if textView.text.count < 100{
            textView.becomeFirstResponder()
        }
    }
    func addKeyboardObserver(){
        keyboardObserver = KeyboardOberver()
        keyboardObserver?.identifier = "textView"
        keyboardObserver?.addKeyboardNotification()
        keyboardObserver?.keyboardNotificationHandler = { [weak self](state,notifacation,keyboardHeight,identifier) in
            if identifier == "textView"{
                self?.inputViewAnimation(state:state, keyboardHeight: keyboardHeight)
            }
        }
    }
    func rmKeyboardObserver(){
        keyboardObserver?.removeKeyboardNotification()
    }
    func inputViewAnimation(state:KeyBoardState,keyboardHeight:CGFloat){
        switch state {
        case .show:
            inbutToolBar.isHidden = false
            editToolBar.isHidden = true
            textViewBottom.constant = keyboardHeight
        case .hide:
            inbutToolBar.isHidden = true
            editToolBar.isHidden = false
            if plan_bottom_tip_close{
                textViewBottom.constant = 80
            }else{
                textViewBottom.constant = 150
            }
        }
    }
    
    @IBAction func closeBottomTipBtnAction(_ sender: Any) {
        MMKV.default()!.set(true, forKey: "plan_bottom_tip_close")
        plan_bottom_tip_close = true
    }
    @IBAction func defaultBtnAction(_ sender: UIButton) {
        if let date = model?.date{
            let markdown = textView.text.replacingOccurrences(of: "- [o]", with: "- [x]")
            
            showAlert(title: "设置默认模板", message: "每天将根据模板自动生成的内容", buttonTitles: ["取消","设置"], highlightedButtonIndex: 1) {[weak self] index in
                if index == 1{
                    self?.toast(message: "设置默认模板成功")
                    UIPasteboard.general.string = markdown
                    PlanModel.saveMarkdown(date: date, markdown: markdown, just: true)
                }
            }
        }
    }
    @IBAction func copyBtnAction(_ sender: Any) {
        UIPasteboard.general.string = excampleLabel.text
    }
    @IBAction func tapShowTipView(_ sender: UITapGestureRecognizer) {
        tipView.isHidden = false
    }
    @IBAction func closeBtnAction(_ sender: Any) {
        if isChanged{
            showAlert(title: "是否放弃修改", message: "放弃修改会造成数据丢失", buttonTitles: ["继续编辑","返回"], highlightedButtonIndex: 1) { [weak self] index in
                if index == 1{
                    self?.pop()
                }
            }
        }else{
            self.pop()
        }
    }
    @IBAction func saveBtnAction(_ sender: Any) {
        textView.resignFirstResponder()

        if let date = model?.date,let markdown = textView.text{
            PlanModel.saveMarkdown(date: date, markdown: markdown, just: false)
            toast(message: "保存成功")
            DispatchQueue.main.asyncAfter(deadline: .now()+0.5) {
                self.back(svc: PlanHomeViewController.self)
            }
        }
    }
    
    @IBAction func closeTipAction(_ sender: Any) {
        tipView.isHidden = true
        
    }
    
    @IBAction func addSectionAction(_ sender: Any) {
        isChanged = true
        insert("\(newlines())# ", into: textView)
        textViewDidChange(textView)
        if !textView.isFirstResponder{
            textView.becomeFirstResponder()
        }
    }
    
    @IBAction func addPlanAction(_ sender: Any) {
        isChanged = true
        let res = getNewIndex()
        if res.0 == true{
            let x = "\n- [x][\(res.1)]"
            insert(x, into: textView)
        }else{
            let x = "- [x][\(res.1)]"
            insert(x, into: textView)
        }
        textViewDidChange(textView)
        if !textView.isFirstResponder{
            textView.becomeFirstResponder()
        }
    }
    
    @IBAction func toolbar_tipBtnAction(_ sender: Any) {
        textView.resignFirstResponder()
        tipView.isHidden = false
    }
    @IBAction func doneAction(_ sender: Any) {
        textView.resignFirstResponder()
    }
    
    @IBAction func clearBtnAction(_ sender: UIButton) {
        isChanged = true
        textView.attributedText = nil
    }
    func insert(_ insertingString: String, into textView: UITextView) {
        var range = textView.selectedRange
        let firstHalfString = (textView.text as NSString).substring(to: range.location )
        let secondHalfString = (textView.text as NSString).substring(from: range.location)
        textView.isScrollEnabled = false
        textView.text = "\(firstHalfString)\(insertingString)\(secondHalfString)"
        range.location += insertingString.count
        textView.selectedRange = range
        textView.isScrollEnabled = true
    }
    
    func getNewIndex()->(Bool,Int){
        var res = 0
        let range = textView.selectedRange
        let txt = (textView.text as NSString).substring(to: range.location )
        var isNeedReturn = true
        if (txt as NSString).length >= 2{
            let lastStr = (txt as NSString).substring(from: (txt as NSString).length-1)
            if lastStr == "\n"{
                isNeedReturn = false
            }
        }
        if txt.count == 0{
            isNeedReturn = false
        }
        
        if let x = txt.components(separatedBy: "# ").last?.components(separatedBy: "- [").last{
            if x.countOfChars() > 5{
                let new = x.sub(from: 5).replacingOccurrences(of: "o][", with: "").replacingOccurrences(of: "x][", with: "").replacingOccurrences(of: "]", with: "")
                if let index = Int(String(new)){
                    res = index
                }
            }else if x.countOfChars() > 4{
                let new = x.sub(from: 4).replacingOccurrences(of: "o][", with: "").replacingOccurrences(of: "x][", with: "").replacingOccurrences(of: "]", with: "")
                if let index = Int(String(new)){
                    res = index
                }
            }
        }
        return (isNeedReturn,res + 1)
    }
    func newlines()->String{
        var newlines = "\n\n"
        let range = textView.selectedRange
        let txt = (textView.text as NSString).substring(to: range.location )
        if (txt as NSString).length >= 1{
            let lastStr = (txt as NSString).substring(from: (txt as NSString).length-1)
            if lastStr == "\n"{
                newlines = "\n"
            }
        }
        if (txt as NSString).length >= 2{
            let lastStr = (txt as NSString).substring(from: (txt as NSString).length-2)
            if lastStr == "\n\n"{
                newlines = ""
            }
        }
        return newlines
    }
}

extension PlanEditViewController:UITextViewDelegate{
    func textViewDidBeginEditing(_ textView: UITextView) {

    }
    func textView(_ textView: UITextView, shouldChangeTextIn range: NSRange, replacementText text: String) -> Bool {
        if text == "\n"{
            addPlanAction(UIButton())
            return false
        }
        return true
    }
    
    func textViewDidChange(_ textView: UITextView) {
        if let selectedRange = textView.markedTextRange,
           let newText = textView.text(in: selectedRange), newText.count > 0  {
            return
        }
        let loc = textView.selectedRange.location
        let len = textView.selectedRange.length
        
        let attri = NSAttributedString(string: textView.text).colored(with: .hex("#333333")).wordSpaceing(1).font(UIFont.sc_regular(size: 16))
        textView.attributedText = attri
        
        textView.selectedRange = NSMakeRange(loc, len)
        
        textView.scrollRangeToVisible(textView.selectedRange)
    }
}
