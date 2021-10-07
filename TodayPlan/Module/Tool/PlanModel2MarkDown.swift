//
//  Json2MarkDown.swift
//  TodayPlan
//
//  Created by Quinn on 2021/9/12.
//

import Foundation

extension PlanModel{
    func toMarkDown()->String{
        var x = ""
        self.sections.forEach { section in
            x += "# " + section.title + "\n"
            section.items.sorted(by: { item1, item2 in
                return item1.id > item1.id
            }).forEach { item in
                if item.isDone{
                    x += "- [o][\(item.id)]" + item.name + "\n"
                }else{
                    x += "- [x][\(item.id)]" + item.name + "\n"
                }
            }
            x += "\n"
        }
        return x
    }
    func toShareMarkDown()->String{
        var x = ""
        self.sections.forEach { section in
            x += "# " + section.title + "\n"
            section.items.sorted(by: { item1, item2 in
                return item1.id > item1.id
            }).forEach { item in
                if item.isDone{
                    x += "- \(item.id). " + item.name + "\n"
                }else{
                    x += "- \(item.id). " + item.name + "\n"
                }
            }
            x += "\n"
        }
        return x
    }
}
extension PlanModel{
    @discardableResult
    static func saveMarkdown(date:String,markdown:String,just defaultSetting:Bool)->PlanModel{
        
        let model = PlanModel()
        var m_sections:[SectionModel] = [SectionModel]()
        model.date = date
        let sections = markdown.components(separatedBy: "# ")
        for section in sections{
            let array = section.components(separatedBy: "\n")
            if array.count > 0{
                let m_section = SectionModel()
                let section_title = array[0]
                if array.count > 2{
                    let items = array[1..<array.count]
                    var index = 0
                    for item in items{
                        index += 1
                        let m_item = ItemModel()
                        m_item.id = index
                        let regex = "- \\[[ox]\\]\\[[123456789]\\]"
                        let regex2 = "- \\[[ox]\\]\\[[123456789][0123456789]\\]"

                        if let result = regulayExpression(regularExpress: regex, validateString: item).first{
                            let name = item.replacingOccurrences(of: result, with: "")
                            m_item.name = name
                            if name.trimmingCharacters(in: .whitespacesAndNewlines) != ""{
                                if let x = item.components(separatedBy: "- [").last{
                                    if x.countOfChars() > 2{
                                        let new = x.sub(from: 2).replacingOccurrences(of: "- [", with: "").replacingOccurrences(of: "]", with: "")
                                        if new == "o"{
                                            m_item.isDone = true
                                        }else{
                                            m_item.isDone = false
                                        }
                                    }
                                }
                                m_section.items.append(m_item)
                            }
                        }else if let result2 = regulayExpression(regularExpress: regex2, validateString: item).first{
                            let name = item.replacingOccurrences(of: result2, with: "")
                            m_item.name = name
                            if name.trimmingCharacters(in: .whitespacesAndNewlines) != ""{
                                if let x = item.components(separatedBy: "- [").last{
                                    if x.countOfChars() > 2{
                                        let new = x.sub(from: 2).replacingOccurrences(of: "- [", with: "").replacingOccurrences(of: "]", with: "")
                                        if new == "o"{
                                            m_item.isDone = true
                                        }else{
                                            m_item.isDone = false
                                        }
                                    }
                                }
                                m_section.items.append(m_item)
                            }
                        }
                        
                    }
                }
                if section_title.count > 0{
                    m_section.title = section_title
                    m_sections.append(m_section)
                }
            }
        }
        model.sections = m_sections
        
        if defaultSetting{
            PlanModel.defaultModelSeting(model: model)
        }else{
            PlanModel.saveModel(date: date, model: model)
        }
        return model
    }
    
    static func regulayExpression(regularExpress: String, validateString: String) -> [String] {
        do {
            let regex = try NSRegularExpression.init(pattern: regularExpress, options: [])
            let matches = regex.matches(in: validateString, options: [], range: NSRange(location: 0, length: validateString.count))
            var res: [String] = []
            for item in matches {
                let str = (validateString as NSString).substring(with: item.range)
                res.append(str)
            }
            return res
        } catch {
            return []
        }
    }
}
