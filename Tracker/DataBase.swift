//
//  DataBase.swift
//  Tracker
//
//  Created by Eugene Dmitrichenko on 28.12.2023.
//

import UIKit
import CoreData

final class DataBase {
    static let shared = DataBase()
    
    let context: NSManagedObjectContext = {
        
        let appDelegate = UIApplication.shared.delegate as! AppDelegate
        return appDelegate.persistentContainer.viewContext
    }()
    
    private init() {
        print("COREDATA INITIALIZED!")
        
    }
}
