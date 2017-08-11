//
//  AppDelegate.swift
//  iWork
//
//  Created by Erick Sanchez on 7/1/17.
//  Copyright © 2017 Erick Sanchez. All rights reserved.
//

import UIKit
import CoreData
import WatchConnectivity

@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate, WCSessionDelegate {

    var window: UIWindow?
    
    var currentEmployer: Employer {
        get {
            if let employer = UserDefaults.standard.string(forKey: "employer") { //Fetches the default employer
                if let objectId = self.persistentContainer.persistentStoreCoordinator.managedObjectID(forURIRepresentation: URL(string: employer)!) {
                    if let fetchedObject = self.persistentContainer.viewContext.object(with: objectId) as? Employer {
                        return fetchedObject
                    } else { //Not found, then remove the saved Id and create a new default
                        UserDefaults.standard.setValue(nil, forKey: "employer")
                        
                        return self.currentEmployer
                    }
                } else { //Not found, then remove the saved Id and create a new default
                    UserDefaults.standard.setValue(nil, forKey: "employer")
                    
                    return self.currentEmployer
                }
            } else { //Assume there is no employer saved in context and create a new one
                let defaultEmployer = Employer(inContext: self.persistentContainer.viewContext)
                self.saveContext()
                self.currentEmployer = defaultEmployer
                
                return defaultEmployer
            }
        }
        set {
            UserDefaults.standard.setValue(newValue.objectID.uriRepresentation().absoluteString, forKey: "employer")
            UserDefaults.standard.synchronize()
        }
    }
    
    /// Well call saveContext() on set
    var currentRole: Role {
        get {
            return currentEmployer.selectedRole!
        }
        set {
            currentEmployer.selectedRole = newValue
            saveContext()
        }
//        get {
//            if let role = UserDefaults.standard.string(forKey: "role") { //Fetches the default role
//                if let objectId = self.persistentContainer.persistentStoreCoordinator.managedObjectID(forURIRepresentation: URL(string: role)!) {
//                    if let fetchedObject = self.persistentContainer.viewContext.object(with: objectId) as? Role {
//                        return fetchedObject
//                    } else { //Not found, then remove the saved Id and create a new default
//                        UserDefaults.standard.setValue(nil, forKey: "role")
//                        
//                        return self.currentRole
//                    }
//                } else { //Not found, then remove the saved Id and create a new default
//                    UserDefaults.standard.setValue(nil, forKey: "role")
//                    
//                    return self.currentRole
//                }
//            } else { //Assume there is no role saved in context and create a new one
//                let defaultRole = Role(inContext: self.persistentContainer.viewContext, forEmployer: currentEmployer)
//                self.saveContext()
//                self.currentRole = defaultRole
//                
//                return defaultRole
//            }
//        }
//        set {
//            UserDefaults.standard.setValue(newValue.objectID.uriRepresentation().absoluteString, forKey: "role")
//            UserDefaults.standard.synchronize()
//        }
    }

    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplicationLaunchOptionsKey: Any]?) -> Bool {
        // Override point for customization after application launch.
        
        // if the application has NOT already launched, then set up first-time settings
        if (UserDefaults.standard.value(forKey: "hasAlreadyLaunched") as? Bool ?? false) == false {
            
        }
        
        if WCSession.isSupported() {
            watchKitSession.delegate = self
            watchKitSession.activate()
        }
        
        return true
    }

    func applicationWillResignActive(_ application: UIApplication) {
        // Sent when the application is about to move from active to inactive state. This can occur for certain types of temporary interruptions (such as an incoming phone call or SMS message) or when the user quits the application and it begins the transition to the background state.
        // Use this method to pause ongoing tasks, disable timers, and invalidate graphics rendering callbacks. Games should use this method to pause the game.
    }

    func applicationDidEnterBackground(_ application: UIApplication) {
        // Use this method to release shared resources, save user data, invalidate timers, and store enough application state information to restore your application to its current state in case it is terminated later.
        // If your application supports background execution, this method is called instead of applicationWillTerminate: when the user quits.
        self.saveContext()
    }

    func applicationWillEnterForeground(_ application: UIApplication) {
        // Called as part of the transition from the background to the active state; here you can undo many of the changes made on entering the background.
    }

    func applicationDidBecomeActive(_ application: UIApplication) {
        // Restart any tasks that were paused (or not yet started) while the application was inactive. If the application was previously in the background, optionally refresh the user interface.
    }

    func applicationWillTerminate(_ application: UIApplication) {
        // Called when the application is about to terminate. Save data if appropriate. See also applicationDidEnterBackground:.
        // Saves changes in the application's managed object context before the application terminates.
        self.saveContext()
    }

    // MARK: - Core Data stack

    lazy var persistentContainer: NSPersistentContainer = {
        /*
         The persistent container for the application. This implementation
         creates and returns a container, having loaded the store for the
         application to it. This property is optional since there are legitimate
         error conditions that could cause the creation of the store to fail.
        */
        let container = NSPersistentContainer(name: "iWork")
        container.loadPersistentStores(completionHandler: { (storeDescription, error) in
            if let error = error as NSError? {
                // Replace this implementation with code to handle the error appropriately.
                // fatalError() causes the application to generate a crash log and terminate. You should not use this function in a shipping application, although it may be useful during development.
                 
                /*
                 Typical reasons for an error here include:
                 * The parent directory does not exist, cannot be created, or disallows writing.
                 * The persistent store is not accessible, due to permissions or data protection when the device is locked.
                 * The device is out of space.
                 * The store could not be migrated to the current model version.
                 Check the error message to determine what the actual problem was.
                 */
                fatalError("Unresolved error \(error), \(error.userInfo)")
            }
        })
        return container
    }()

    // MARK: - Core Data Saving support

    func saveContext () {
        let context = persistentContainer.viewContext
        if context.hasChanges {
            do {
                try context.save()
            } catch {
                // Replace this implementation with code to handle the error appropriately.
                // fatalError() causes the application to generate a crash log and terminate. You should not use this function in a shipping application, although it may be useful during development.
                let nserror = error as NSError
                fatalError("Unresolved error \(nserror), \(nserror.userInfo)")
            }
        }
    }
    
    // MARK: - WatchKit Delegate
    
    private var watchKitSession: WCSession {
        return WCSession.default()
    }
    
    func session(_ session: WCSession, activationDidCompleteWith activationState: WCSessionActivationState, error: Error?) {
        switch activationState {
        case .activated:
            print("activated")
        case .notActivated:
            print("notActivated")
        case .inactive:
            print("inactive")
        }
        
    }
    
    func sessionReachabilityDidChange(_ session: WCSession) {
        if session.isReachable {
            watchKitSession.sendMessage(["object1":"Welcome!"], replyHandler: nil, errorHandler: { (error) in
                print(error.localizedDescription)
            })
//            let shift = Shift(inContext: persistentContainer.viewContext, forEmployer: currentEmployer)
//            watchKitSession!.sendMessageData(NSKeyedArchiver.archivedData(withRootObject: shift), replyHandler: nil, errorHandler: nil)
//            saveContext()
        }
    }
    
    func sessionDidBecomeInactive(_ session: WCSession) {
        
    }
    
    func sessionDidDeactivate(_ session: WCSession) {
        watchKitSession.activate()
    }
}

