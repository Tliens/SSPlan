//
//  SSDefault.swift
//  TodayPlan
//
//  Created by Quinn on 2021/9/11.
//

import UIKit
import SpeedySwift

struct AppDefaults {
    @SSDefault("defaultSystemPlanModel", defaultValue: systemDefaultPlanModelJson)
    static var defaultSystemPlanModel: String
    
    @SSDefault("open_password", defaultValue: false)
    static var open_password: Bool
}
