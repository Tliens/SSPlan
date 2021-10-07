//
//  DateChooseViewController.swift
//  TodayPlan
//
//  Created by Quinn on 2021/9/22.
//

import UIKit
import SpeedySwift
class DateChooseViewController: UIViewController {

    @IBOutlet weak var dateContinerView: UIView!
    @IBOutlet weak var collectionView: UICollectionView!
    @IBOutlet weak var selectedDateTitleView: UILabel!
    @IBOutlet weak var dateContainerViewTop: NSLayoutConstraint!
    
    var selectedDate:Date = Date(){
        didSet{
            DispatchQueue.main.async {
                self.showDate = self.selectedDate
            }
        }
    }
    /// 当前选择的日期所在月份，对应的所有日期
    var currentMonthDates:[Date] = [Date]()
    /// 当前选择的日期所在月份，是否有计划
    var planInfo:[Date:Bool] = [:]

    /// 时间选择器正在显示的时间
    var showDate:Date = Date()
    
    override init(nibName nibNameOrNil: String?, bundle nibBundleOrNil: Bundle?) {
        super.init(nibName: nibNameOrNil, bundle: nibBundleOrNil)
        modalPresentationStyle = .overCurrentContext
    }
    
    required init?(coder: NSCoder) {
        super.init(coder: coder)
        modalPresentationStyle = .overCurrentContext
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        dateContainerViewTop.constant = -300
        setupCollectionView()
        updateDateView()
    }
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        dateContainerViewTop.constant = 100
        UIView.animate(withDuration: 0.25) {
            self.view.layoutIfNeeded()
        }
    }
    func setupCollectionView(){
        let layout = SSCollectionViewLayout(longitude: 5, latitude: 5, itemSize: CGSize(width: (SS.w-80-36)/6, height: (SS.w-80-36)/6), sectionInset: UIEdgeInsets.init(top: 20, left: 20, bottom: 0, right: 20), direction: .vertical)
        self.collectionView.collectionViewLayout = layout
        self.collectionView.register(UINib(nibName:PlanChooseDateCollectionViewCell.named, bundle:nil),
                                     forCellWithReuseIdentifier: PlanChooseDateCollectionViewCell.named)
        self.collectionView.delegate = self
        self.collectionView.dataSource = self
    }
    @IBAction func left_month_action(_ sender: Any) {
        self.showDate.addMonth(n: -1)
        updateDateView()
    }
    
    @IBAction func left_year_action(_ sender: Any) {
        self.showDate.addYear(n: -1)
        updateDateView()
    }
    @IBAction func right_month_action(_ sender: Any) {
        self.showDate.addMonth(n: 1)
        updateDateView()
    }
    
    @IBAction func right_year_action(_ sender: Any) {
        self.showDate.addYear(n: 1)
        updateDateView()
    }
    @IBAction func tapToHiddenDateViewAction(_ sender: Any) {
        dateContainerViewTop.constant = -400
        UIView.animate(withDuration: 0.25) {
            self.view.layoutIfNeeded()
            self.view.alpha = 0
        } completion: { _ in
            self.dismiss(animated: false, completion: nil)
        }
    }
    func updatePlanInfo(){
        if let list = PlanModel.getDateList(date: showDate.toString(dateFormat: "yyyy-MM-dd")){
            planInfo.removeAll()
            currentMonthDates.forEach { date in
                let date_str = date.toString(dateFormat: "yyyy-MM-dd")
                if list.contains(date_str){
                    planInfo[date] = true
                }else{
                    planInfo[date] = false

                }
            }
        }
    }
    func updateDateView(){
        self.selectedDateTitleView.text = showDate.toString(dateFormat: "yyyy年M月")
        self.currentMonthDates = showDate.datesOfMonth()
        self.updatePlanInfo()
        self.collectionView.reloadData()
    }
}
extension DateChooseViewController:UICollectionViewDelegate,UICollectionViewDataSource{
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return currentMonthDates.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: PlanChooseDateCollectionViewCell.named, for: indexPath) as! PlanChooseDateCollectionViewCell
        let date = currentMonthDates[indexPath.row]
        cell.update(date: date, isChoose: date.toString() == selectedDate.toString(),isCanSelected: planInfo[date] ?? false)
        return cell
    }
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        self.selectedDate = currentMonthDates[indexPath.row]
        self.collectionView.reloadData()
        self.lastVC()?.selectedDate = currentMonthDates[indexPath.row]
        self.lastVC()?.reloadTableView()
    }
    
    private func lastVC()->PlanHomeViewController?{
        if let last = self.presentingViewController as? TPTabBarController{
            return last.planVc
        }
        return nil
    }
    func collectionView(_ collectionView: UICollectionView, willDisplay cell: UICollectionViewCell, forItemAt indexPath: IndexPath) {
        let date = currentMonthDates[indexPath.row]
        if date.toString() == selectedDate.toString(){
            cell.transform = CGAffineTransform.identity.scaledBy(x: 1.1, y: 1.1)
            UIView.animate(withDuration: 0.25, delay: 0, options: .curveEaseInOut) {
                cell.transform = CGAffineTransform.identity
            }
        }
    }
}
