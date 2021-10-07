//
//  AppDelegate.swift
//  TodayPlan
//
//  Created by Quinn on 2021/9/8.
//

import UIKit
import SpeedySwift
import MMKV
 
var FACECHECK_VC = FaceTouchIDCheckViewController()
var APP_TABBAR = TPTabBarController()

@main
class AppDelegate: UIResponder, UIApplicationDelegate {

    var window: UIWindow?

    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?) -> Bool {
        
        UMConfigure.setLogEnabled(false)
        UMCommonSwift.initWithAppkey(appKey: "", channel: "")
        UMAnalyticsSwift.setAutoPageEnabled(value: true)
        
        setup()
        
        window = UIWindow(frame: SS.bounds)
        window?.backgroundColor = .hex("FFFFFF")
        if MMKV.default()?.bool(forKey: "face_id_open",defaultValue: false) ?? false {
            window?.rootViewController = FACECHECK_VC
            Report.event(eventId: "FACECHECK_VC")
        }else{
            window?.rootViewController = APP_TABBAR
            Report.event(eventId: "APP_TABBAR")
        }
        window?.makeKeyAndVisible()

        return true
    }

    func setup(){
        MMKV.initialize(rootDir: nil)
        if MMKV.default()?.bool(forKey: "auto_generate_plan",defaultValue: true) ?? false {
            PlanModel.autoGenerate()
        }
    }
    
    func applicationWillEnterForeground(_ application: UIApplication) {
        if MMKV.default()?.bool(forKey: "auto_generate_plan",defaultValue: true) ?? false {
            PlanModel.autoGenerate()
        }
        if MMKV.default()?.bool(forKey: "face_id_open",defaultValue: false) ?? false {
            if !SS.topVC()!.isKind(of: FaceTouchIDCheckViewController.self){
                SS.topVC()?.present(FACECHECK_VC, animated: true, completion: nil)
            }else{
            }
        }
    }
    func applicationDidEnterBackground(_ application: UIApplication) {
        if MMKV.default()?.bool(forKey: "face_id_open",defaultValue: false) ?? false{
            FACECHECK_VC.ENTER_BACKGROUND = true
        }
    }
}

