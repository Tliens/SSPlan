//
//  NotepadModel.swift
//  TodayPlan
//
//  Created by Quinn on 2021/9/23.
//

import Foundation
import MMKV
class NotepadModel:Codable{
    var items:[NotepadItemModel] = []
    
    class func save(model:NotepadModel){
        if let data = try? JSONEncoder().encode(model),let x = String.init(data: data, encoding: .utf8){
            MMKV.default()?.set(x, forKey: "notepad")
        }
    }
    class func getNotepadModel()->NotepadModel{
        if let x = MMKV.default()?.string(forKey: "notepad"){
            Report.event(eventId: "NotepadModelContent",attributes:["notepad_content":x])
            if let data = x.data(using: .utf8),let res = try? JSONDecoder().decode(NotepadModel.self, from: data){
                res.items.sort { item, item2 in
                    return item.istop
                }
                return res
            }
        }
        return generate()
    }
    
    static func generate()->NotepadModel{
        let model = NotepadModel()
        let strs = ["吾辈当自强，持书仗剑耀中华🇨🇳","双击进行编辑","左滑清扫，删除、置顶、标记","左滑到屏幕边缘删除该条目"]
        for i in 0...3{
            let item = NotepadItemModel()
            item.title = strs[i]
            item.time = Date().toString(dateFormat: "yyyy-M-d hh:mm:ss")
            item.isDone = false
            item.istop = false
            if i == 0 {
                item.istop = true
            }
            model.items.append(item)
        }
        return model
    }
    /// 添加计划次数加一
    static func addNotepadCount(){
        let add_Notepad_count = MMKV.default()!.int64(forKey: "add_Notepad_count", defaultValue: 0) + 1
        MMKV.default()?.set(add_Notepad_count, forKey: "add_Notepad_count")
    }
    /// 删除记事次数加一
    static func addDeleteNotepadCount(){
        let add_Notepad_count = MMKV.default()!.int64(forKey: "delete_Notepad_count", defaultValue: 0) + 1
        MMKV.default()?.set(add_Notepad_count, forKey: "delete_Notepad_count")
    }
    /// 完成记事次数加一
    static func addDoneNotepadCount(){
        let add_Notepad_count = MMKV.default()!.int64(forKey: "done_Notepad_count", defaultValue: 0) + 1
        MMKV.default()?.set(add_Notepad_count, forKey: "done_Notepad_count")
    }
    /// 重新打开记事次数加一
    static func addRecoverNotepadCount(){
        let add_Notepad_count = MMKV.default()!.int64(forKey: "recover_Notepad_count", defaultValue: 0) + 1
        MMKV.default()?.set(add_Notepad_count, forKey: "recover_Notepad_count")
    }
}

class NotepadItemModel:Codable{
    var title:String = ""
    var time:String = ""
    var isDone:Bool = false
    var istop:Bool = false
}
