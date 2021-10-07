//
//  PlanModel.swift
//  TodayPlan
//
//  Created by Quinn on 2021/9/11.
//

import UIKit
import SpeedySwift
import MMKV
import MMKVCore



class PlanModel: Codable {
    var sections:[SectionModel] = []
    var date:String = ""
    
    /// 默认计划模板
    class func defaultPlanModel(date:Date)->PlanModel{
        let x = AppDefaults.defaultSystemPlanModel
        if let data = x.data(using: .utf8),let res = try? JSONDecoder().decode(PlanModel.self, from: data){
            res.date = date.toString(dateFormat: "yyyy-MM-dd")
            return res
        }else{
            let data = systemDefaultPlanModelJson.data(using: .utf8)
            let res = try! JSONDecoder().decode(PlanModel.self, from: data!)
            res.date = date.toString(dateFormat: "yyyy-MM-dd")
            return res
        }
    }
    /// 根据日期获取model
    class func getModel(date:Date)->PlanModel?{
        let date_str = date.toString(dateFormat: "yyyy-MM-dd")
        if let x = MMKV.default()?.string(forKey: "plan_model_\(date_str)"){
            if let data = x.data(using: .utf8),let res = try? JSONDecoder().decode(PlanModel.self, from: data){
                res.date = date_str
                return res
            }
        }
        return nil
    }
    /// 根据日期存model
    class func saveModel(date:String,model:PlanModel){
        if let data = try? JSONEncoder().encode(model),let x = String.init(data: data, encoding: .utf8){
            MMKV.default()?.set(x, forKey: "plan_model_\(date)")
            saveDateList(date: date)
        }
    }
    class func defaultModelSeting(model:PlanModel){
        if let data = try? JSONEncoder().encode(model),let x = String.init(data: data, encoding: .utf8){
            AppDefaults.defaultSystemPlanModel = x
        }
    }
    /// 自动生成
    class func autoGenerate(){
        if let _ = getModel(date: Date()){
            
        }else{
            let model = defaultPlanModel(date:Date())
            saveModel(date: Date().toString(dateFormat: "yyyy-MM-dd"), model: model)
            saveDateList(date: Date().toString(dateFormat: "yyyy-MM-dd"))
        }
        
    }
    /// 存档
    class func saveDateList(date:String){
        if let month = date.toDate(withFormat: "yyyy-MM-dd")?.month(),let year = date.toDate(withFormat: "yyyy-MM-dd")?.year(){
            if var x = MMKV.default()?.string(forKey: "plan_history_\(year)_\(month)"){
                if !x.components(separatedBy: ",").contains(date){
                    x += ",\(date)"
                    MMKV.default()?.set(x, forKey: "plan_history_\(year)_\(month)")
                }
            }else{
                MMKV.default()?.set(date, forKey: "plan_history_\(year)_\(month)")
            }
        }
    }
    
    /// 读档
    class func getDateList(date:String)->String?{
        if let month = date.toDate(withFormat: "yyyy-MM-dd")?.month(),let year = date.toDate(withFormat: "yyyy-MM-dd")?.year(){
            return MMKV.default()?.string(forKey: "plan_history_\(year)_\(month)") ?? ""
        }
        return ""
    }
    
    /// 过去一年中有多少个计划日
    class func totalTodayPlan()->Int{
        var date = Date()
        let now_year = date.year().int!
        date.addYear(n: -1)
        var totalCount = 0
        if let year = date.year().int,
           let month = date.month().int{
            
            for m in month...12{
                let listStr = MMKV.default()?.string(forKey: "plan_history_\(year)_\(m)") ?? ""
                let list = listStr.components(separatedBy: ",")
                if listStr != ""{
                    totalCount += list.count
                }
            }
            for m in 1...month{
                let listStr = MMKV.default()?.string(forKey: "plan_history_\(now_year)_\(m)") ?? ""
                let list = listStr.components(separatedBy: ",")
                if listStr != ""{
                    totalCount += list.count
                }
            }
        }
        return totalCount
    }
}

class SectionModel:Codable{
    var title:String = ""
    var items:[ItemModel] = []
}

class ItemModel:Codable{
    var name:String = ""
    var id:Int = 0
    var isDone = false
}

let systemDefaultPlanModelJson =
    """
{
    "date": "2021-09-21",
    "sections": [{
        "title": "清晨",
        "items": [{
            "name": "7:00 起床",
            "isDone": false,
            "id": 1
        }, {
            "name": "7:30 洗漱、护肤、吃饭",
            "isDone": false,
            "id": 2
        }, {
            "name": "8:00 出发🌈",
            "isDone": false,
            "id": 2
        }]
    }, {
        "title": "上午",
        "items": [{
            "name": "8:30 算法",
            "isDone": false,
            "id": 1
        }, {
            "name": "9:30 开始工作",
            "isDone": false,
            "id": 2
        }]
    }, {
        "title": "中午",
        "items": [{
            "name": "12:30 吃饭🍖",
            "isDone": false,
            "id": 1
        }, {
            "name": "13:00 算法",
            "isDone": false,
            "id": 2
        }, {
            "name": "13:30 休息",
            "isDone": false,
            "id": 3
        }]
    }, {
        "title": "下午",
        "items": [{
            "name": "14:00 工作💼",
            "isDone": false,
            "id": 1
        }, {
            "name": "19:00 吃饭",
            "isDone": false,
            "id": 2
        }, {
            "name": "19:30 休息",
            "isDone": false,
            "id": 3
        }]
    }, {
        "title": "晚上",
        "items": [{
            "name": "20:00 算法",
            "isDone": false,
            "id": 1
        }, {
            "name": "21:30 回家",
            "isDone": false,
            "id": 2
        }]
    }, {
        "title": "深夜",
        "items": [{
            "name": "22:00 休息游戏🐠",
            "isDone": false,
            "id": 1
        }, {
            "name": "22:30  洗漱、护肤、锻炼",
            "isDone": false,
            "id": 2
        }, {
            "name": "23:00 算法",
            "isDone": false,
            "id": 2
        }, {
            "name": "23:20 准备入睡🌙",
            "isDone": false,
            "id": 2
        }]
    }]
}
"""
