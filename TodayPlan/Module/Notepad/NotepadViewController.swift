//
//  NotepadViewController.swift
//  TodayPlan
//
//  Created by Quinn on 2021/9/23.
//

import UIKit
import SpeedySwift
import DZNEmptyDataSet
class NotepadViewController: SSViewController {
    @IBOutlet weak var tableView: UITableView!
    
    @IBOutlet weak var notepadStateLabel: UILabel!
    var model : NotepadModel!

    @IBOutlet weak var backgroundView: UIView!
    @IBOutlet weak var sliderViewRight: NSLayoutConstraint!
    @IBOutlet weak var sliderView: UIView!
    override func viewDidLoad() {
        super.viewDidLoad()
        hideNavBar()
        model = NotepadModel.getNotepadModel()
        setupTableView()
        
    }
    func setupTableView(){
        self.tableView.register(UINib(nibName:NotepadTableViewCell.named, bundle:nil),
                                forCellReuseIdentifier:NotepadTableViewCell.named)
        self.tableView.estimatedRowHeight = 43
        self.tableView.rowHeight = UITableView.automaticDimension
        self.tableView.delegate = self
        self.tableView.dataSource = self
        self.tableView.emptyDataSetSource = self;
        self.tableView.emptyDataSetDelegate = self;
        
    }
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        model = NotepadModel.getNotepadModel()
        tableView.reloadData()
        refreshStateLabel()
    }
    func refreshStateLabel(){
        DispatchQueue.main.async {
            let totalCount = self.model.items.count
            if totalCount == 0{
                self.notepadStateLabel.text = ""
                return
            }
            var doneCount = 0
            for x in self.model.items{
                if x.isDone{
                    doneCount += 1
                }
            }
            let w = SS.w - 40
            let move = w * (1 - CGFloat(doneCount)/CGFloat(totalCount)) + 20
            self.sliderViewRight.constant = move
            self.notepadStateLabel.text = "已完成: \(doneCount) / \(totalCount)"
        }
    }
    @IBAction func addNewNotepadItemAction(_ sender: UIButton) {
        showAddVc(model:nil)
    }
    
    @IBAction func clearBtnAction(_ sender: Any) {
        SSTapBuzz.warning()
        showAlert(title: "确定清空吗?", message: "清空后不可恢复", buttonTitles: ["取消","清空"], highlightedButtonIndex: 1) {[weak self] index in
            if index == 1{
                guard let self = self else{return}
                self.model.items.removeAll()
                NotepadModel.save(model: self.model)
                self.tableView.reloadData()
                self.refreshStateLabel()
            }
        }
    }
    func showAddVc(model:NotepadItemModel?){
        let vc = NotepadAddViewController()
        vc.model = model
        vc.doneBtnCallback = { [weak self] str in
            guard let self = self else{return}
            if str.trimmingCharacters(in: .whitespacesAndNewlines).count == 0{
                return
            }
            let item = NotepadItemModel()
            item.title = str
            item.time = Date().toString(dateFormat: "yyyy-M-d hh:mm:ss")
            item.isDone = false
            item.istop = false
            self.model.items.insert(item, at: 0)
            NotepadModel.save(model: self.model)
            self.model = NotepadModel.getNotepadModel()
            self.tableView.reloadData()
            NotepadModel.addNotepadCount()
            self.refreshStateLabel()
        }
        show(vc)
    }
}
extension NotepadViewController:UITableViewDataSource,UITableViewDelegate{
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return model.items.count

    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell:NotepadTableViewCell = tableView.dequeueReusableCell(withIdentifier: NotepadTableViewCell.named)
                    as! NotepadTableViewCell
        let item = model.items[indexPath.row]
        cell.update(title: item.title, time: item.time, isDone: item.isDone, isTop: item.istop)
        cell.tapGestureRecognizer(target: self, action: #selector(doubleTapCell(tapgesture:)), numberOfTapsRequired: 2, numberOfTouchesRequired: 1)
        return cell
    }
    func tableView(_ tableView: UITableView, trailingSwipeActionsConfigurationForRowAt indexPath: IndexPath) -> UISwipeActionsConfiguration? {
        let deleteAction = UIContextualAction(style: .normal, title: "") {[weak self] (action, sourceView, completionHandler) in
            guard let self = self else{return}
            self.showAlert(title: "是否删除", message:"删除后无法找回", buttonTitles: ["取消","删除"], highlightedButtonIndex: 1) { index in
                if index == 1{
                    self.model.items.remove(at: indexPath.row)
                    NotepadModel.save(model: self.model)
                    tableView.deleteRows(at: [indexPath], with: .automatic)
                    tableView.reloadEmptyDataSet()
                    NotepadModel.addDeleteNotepadCount()
                    self.refreshStateLabel()
                }
            }
            // 需要返回true，否则没有反应
            completionHandler(true)
        }
        
        deleteAction.backgroundColor = self.tableView.backgroundColor
        if let cgImageTrashcan =  UIImage(named: "notepad_item_delete")?.cgImage {
            deleteAction.image = ImageWithoutRender(cgImage: cgImageTrashcan, scale: UIScreen.main.nativeScale, orientation: .up)
        }
        let toTopAction = UIContextualAction(style: .normal, title: "") {[weak self] (action, sourceView, completionHandler) in
            guard let self = self else{return}
            self.model.items[indexPath.row].istop = !self.model.items[indexPath.row].istop
            NotepadModel.save(model: self.model)
            self.model = NotepadModel.getNotepadModel()
            tableView.reloadData()
            // 需要返回true，否则没有反应
            completionHandler(true)
        }
        if self.model.items[indexPath.row].istop{
            if let cgImageTrashcan =  UIImage(named: "notepad_untop")?.cgImage {
                toTopAction.image = ImageWithoutRender(cgImage: cgImageTrashcan, scale: UIScreen.main.nativeScale, orientation: .up)
            }
        }else{
            if let cgImageTrashcan =  UIImage(named: "notepad_top")?.cgImage {
                toTopAction.image = ImageWithoutRender(cgImage: cgImageTrashcan, scale: UIScreen.main.nativeScale, orientation: .up)
            }
        }
        toTopAction.backgroundColor = self.tableView.backgroundColor
        
        let doneAction = UIContextualAction(style: .normal, title: "")  {[weak self] (action, sourceView, completionHandler) in
            guard let self = self else{return}
            self.model.items[indexPath.row].isDone = !self.model.items[indexPath.row].isDone
            NotepadModel.save(model: self.model)
            self.tableView.reloadRows(at: [indexPath], with: .automatic)
            if self.model.items[indexPath.row].isDone{
                NotepadModel.addDoneNotepadCount()
            }else{
                NotepadModel.addRecoverNotepadCount()
            }
            self.refreshStateLabel()
            // 需要返回true，否则没有反应
            completionHandler(true)
        }
        let img = self.model.items[indexPath.row].isDone ? UIImage(named: "plan_tag_yes") :  UIImage(named: "plan_tag_no")
        doneAction.backgroundColor = self.tableView.backgroundColor
        if let cgImageTrashcan =  img?.cgImage {
            doneAction.image = ImageWithoutRender(cgImage: cgImageTrashcan, scale: UIScreen.main.nativeScale, orientation: .up)
        }
        let config = UISwipeActionsConfiguration(actions: [doneAction,toTopAction,deleteAction])
        
        config.performsFirstActionWithFullSwipe = true
        
        return config
    }
    func tableView(_ tableView: UITableView, heightForFooterInSection section: Int) -> CGFloat {
        return 40
    }
    func tableView(_ tableView: UITableView, viewForFooterInSection section: Int) -> UIView? {
        return UIView()
    }
    @objc func doubleTapCell(tapgesture:UITapGestureRecognizer){
        if let view = tapgesture.view{
            if let indexPath = self.tableView.indexPath(by: view){
                self.showAddVc(model: self.model.items[indexPath.row])
            }
        }
    }
}
extension NotepadViewController:DZNEmptyDataSetSource, DZNEmptyDataSetDelegate{
    func title(forEmptyDataSet scrollView: UIScrollView!) -> NSAttributedString! {
        let attri = NSAttributedString(string: "暂无记事，点击添加").colored(with: .hex("#666666")).font(.sc_regular(size: 12))
        return attri
    }
    func image(forEmptyDataSet scrollView: UIScrollView!) -> UIImage! {
        return UIImage(named: "notepad_empty_icon")!
    }
    func emptyDataSet(_ scrollView: UIScrollView!, didTap view: UIView!) {
        showAddVc(model: nil)
    }

}

