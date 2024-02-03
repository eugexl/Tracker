//
//  AppDelegate.swift
//  Tracker 16
//
//  Created by Eugene Dmitrichenko on 20.12.2023.
//

import UIKit
import CoreData

@main
class AppDelegate: UIResponder, UIApplicationDelegate {
    
    var window: UIWindow?
    
    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?) -> Bool {
        
        self.window = UIWindow(frame: UIScreen.main.bounds)
        
        var rootController: UIViewController
        
        if UserDefaults.standard.object(forKey: OnboardingViewController.onboardingWasShownKey) != nil {
            rootController = TabBarController()
        } else {
            rootController = OnboardingPageController(transitionStyle: .scroll,
                                                                   navigationOrientation: .horizontal,
                                                                   options: nil)
        }
        
        self.window?.rootViewController = rootController
        self.window?.makeKeyAndVisible()
        
        ScheduleTransformer.register()
        return true
    }
    
    lazy var persistentContainer: NSPersistentContainer = {
        
        let container = NSPersistentContainer(name: "Tracker")
        
        container.loadPersistentStores(completionHandler: { (storeDescription, error) in
            
            if let error = error as NSError? {
                fatalError("Unresolved error \(error), \(error.userInfo)")
            }
        })
        
        return container
    }()
}
