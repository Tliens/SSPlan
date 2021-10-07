//
//  FaceTouchIDCheckManager.swift
//  App1125
//
//  Created by Quinn on 2021/1/7.
//

import Foundation
import BiometricAuthentication
import SpeedySwift
class FaceTouchIDCheckManager {
    static let shared = FaceTouchIDCheckManager()
    private init(){
        // Set AllowableReuseDuration in seconds to bypass the authentication when user has just unlocked the device with biometric
        BioMetricAuthenticator.shared.allowableReuseDuration = 1
    }
    func check(success:@escaping(()->Void),failure:@escaping((_ msg:String)->Void)){
        
        // start authentication
        BioMetricAuthenticator.authenticateWithBioMetrics(reason: "") { [weak self] (result) in
            switch result {
            case .success( _):
                success()
            case .failure(let error):
                switch error {
                case .biometryNotAvailable:
                    self?.showErrorAlert(message: error.message())
                case .biometryNotEnrolled:
                    self?.showGotoSettingsAlert(message: error.message())
                case .fallback:
                    self?.showPasscodeAuthentication(message: error.message(),success:success, failure: failure)
                case .biometryLockedout:
                    self?.showPasscodeAuthentication(message: error.message(),success:success, failure: failure)
                case .canceledBySystem, .canceledByUser:
                    break
                default:
                    self?.showErrorAlert(message: error.message())
                }
                failure(error.message())
            }
        }
    }
    // show passcode authentication
    func showPasscodeAuthentication(message: String, success:@escaping(()->Void),failure:@escaping((_ msg:String)->Void)){
        
        BioMetricAuthenticator.authenticateWithPasscode(reason: message) { (result) in
            switch result {
            case .success( _):
                success()
            case .failure(let error):
                print(error.message())
                failure(error.message())
            }
        }
    }
}

// MARK: - Alerts
extension FaceTouchIDCheckManager {
    
    func showAlert(title: String, message: String) {
        SS.topVC()?.showAlert(title: title, message: message)
    }
    
    func showErrorAlert(message: String) {
        showGotoSettingsAlert(message: "是否去设置，打开面容ID权限")
    }
    
    func showGotoSettingsAlert(message: String) {
        SS.topVC()?.showAlert(title: "无法使用面容ID", message: message, buttonTitles: ["Cancle","Settings"], highlightedButtonIndex: 1, completion: { (index) in
            if index == 1{
                let url = URL(string: UIApplication.openSettingsURLString)
                if UIApplication.shared.canOpenURL(url!) {
                    UIApplication.shared.open(url!, options: [:])
                }
            }
        })
    }
}
