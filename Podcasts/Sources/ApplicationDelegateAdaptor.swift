//
//  ApplicationDelegateAdaptor.swift
//  Podcasts
//
//  Created by Yu Tawata on 2020/08/27.
//

import UIKit
import FirebaseCore

class ApplicationDelegateAdaptor: UIResponder, UIApplicationDelegate {
    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey : Any]? = nil) -> Bool {
        FirebaseApp.configure()
        return true
    }
}
