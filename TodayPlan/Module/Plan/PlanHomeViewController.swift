//
//  PlanHomeViewController.swift
//  TodayPlan
//
//  Created by Quinn on 2021/9/8.
//

import UIKit
import SpeedySwift
class PlanHomeViewController: SSViewController {

    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var dateTitleLabel: UILabel!
    
    var model:PlanModel!

    /// 当前选择的日期
    var selectedDate:Date = Date(){
        didSet{
            DispatchQueue.main.async {
                self.dateTitleLabel.text = self.selectedDate.toString(dateFormat: "yyyy.M.dd")
            }
        }
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        hideNavBar()
        selectedDate = Date()
        model = PlanModel.getModel(date: selectedDate) ?? PlanModel.defaultPlanModel(date: selectedDate)
        setupTableView()

        self.view.backgroundColor = .hex("#F2F2F2")
        
    }


    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        reloadTableView()
    }
    func reloadTableView(){
        model = PlanModel.getModel(date: selectedDate) ?? PlanModel.defaultPlanModel(date: selectedDate)
        tableView.reloadData()
        
    }
    func setupTableView(){
        self.tableView.register(UINib(nibName:PlanHomeTableViewCell.named, bundle:nil),
                                forCellReuseIdentifier:PlanHomeTableViewCell.named)
        self.tableView.delegate = self
        self.tableView.dataSource = self
    }
    
    @IBAction func moreBtnAction(_ sender: UIButton) {
        let vc = MoreSettingViewController()
        vc.model = self.model
        tabBarController?.present(vc, animated: false, completion: nil)
    }
    
    @IBAction func selectedDateAction(_ sender: UITapGestureRecognizer) {
        let vc = DateChooseViewController()
        vc.selectedDate = selectedDate
        vc.showDate = selectedDate
        tabBarController?.present(vc, animated: false, completion: nil)
    }
}

extension PlanHomeViewController:UITableViewDelegate,UITableViewDataSource{
        
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell:PlanHomeTableViewCell = tableView.dequeueReusableCell(withIdentifier: PlanHomeTableViewCell.named)
                    as! PlanHomeTableViewCell
        let item = model.sections[indexPath.section].items[indexPath.row]
        cell.updateCell(title: item.name,isDone: item.isDone)
        cell.clipsToBounds = true
        cell.tapGestureRecognizer(target: self, action: #selector(doubleTapCell(tapgesture:)), numberOfTapsRequired: 2, numberOfTouchesRequired: 1)
        return cell
    }
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let item = model.sections[indexPath.section].items[indexPath.row]
        item.isDone = !item.isDone
        if item.isDone{
            SSTapBuzz.light()
        }else{
            SSTapBuzz.error()
        }
        tableView.reloadRows(at: [indexPath], with: .automatic)
        PlanModel.saveModel(date: model.date, model: model)
    }
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 67
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return model.sections[section].items.count
    }
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return model.sections.count
    }
    
    func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        let x = PlanHomeSectionHeaderView()
        x.tapGestureRecognizer(target: self, action: #selector(sectionHeaderTapGestureAction(gesture: )), numberOfTapsRequired: 2, numberOfTouchesRequired: 1)
        x.titleLabel.text = model.sections[section].title
        return x
        
    }
    
    func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        return 42
    }
    func tableView(_ tableView: UITableView, trailingSwipeActionsConfigurationForRowAt indexPath: IndexPath) -> UISwipeActionsConfiguration? {
        let deleteAction = UIContextualAction(style: .normal, title: "") {[weak self] (action, sourceView, completionHandler) in
            guard let self = self else{return}
            self.showAlert(title: "是否删除", message:"删除后无法找回", buttonTitles: ["取消","删除"], highlightedButtonIndex: 1) { index in
                if index == 1{
                    self.model.sections[indexPath.section].items.remove(at: indexPath.row)
                    PlanModel.saveModel(date: self.model.date, model: self.model)
                    tableView.deleteRows(at: [indexPath], with: .automatic)
                }
            }
            completionHandler(true)
        }
        
        deleteAction.backgroundColor = self.tableView.backgroundColor
        if let cgImageTrashcan =  UIImage(named: "notepad_item_delete")?.cgImage {
            deleteAction.image = ImageWithoutRender(cgImage: cgImageTrashcan, scale: UIScreen.main.nativeScale, orientation: .up)
        }
        let editAction = UIContextualAction(style: .normal, title: "") {[weak self] (action, sourceView, completionHandler) in
            guard let self = self else{return}
            let vc = PlanEditViewController()
            vc.model = self.model
            self.push(vc)
            completionHandler(true)
        }
        
        editAction.backgroundColor = self.tableView.backgroundColor
        if let cgImageTrashcan =  UIImage(named: "notepad_item_edit")?.cgImage {
            editAction.image = ImageWithoutRender(cgImage: cgImageTrashcan, scale: UIScreen.main.nativeScale, orientation: .up)
        }
        let add_to_notepadAction = UIContextualAction(style: .normal, title: "") {[weak self] (action, sourceView, completionHandler) in
            guard let self = self else{return}
            let model = NotepadModel.getNotepadModel()
            let item = NotepadItemModel()
            item.title = self.model.sections[indexPath.section].items[indexPath.row].name
            item.time = Date().toString(dateFormat: "yyyy-M-d hh:mm:ss")
            item.isDone = false
            model.items.insert(item, at: 0)
            NotepadModel.save(model: model)
            NotepadModel.addNotepadCount()
            self.toast(message: "添加成功")
            SSTapBuzz.light()
            completionHandler(true)
        }
        
        add_to_notepadAction.backgroundColor = self.tableView.backgroundColor
        if let cgImageTrashcan =  UIImage(named: "plan_to_notepad")?.cgImage {
            add_to_notepadAction.image = ImageWithoutRender(cgImage: cgImageTrashcan, scale: UIScreen.main.nativeScale, orientation: .up)
        }

        let config = UISwipeActionsConfiguration(actions: [deleteAction,editAction,add_to_notepadAction])
        
        config.performsFirstActionWithFullSwipe = true
        
        return config
    }
    @objc func sectionHeaderTapGestureAction(gesture:UITapGestureRecognizer){
        let vc = PlanEditViewController()
        vc.model = self.model
        push(vc)
    }
    @objc func doubleTapCell(tapgesture:UITapGestureRecognizer){
        let vc = PlanEditViewController()
        vc.model = self.model
        push(vc)
    }
}
class ImageWithoutRender: UIImage {
    override func withRenderingMode(_ renderingMode: UIImage.RenderingMode) -> UIImage {
        return self
    }
}
