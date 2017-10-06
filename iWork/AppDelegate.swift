//
//  AppDelegate.swift
//  iWork
//
//  Created by Erick Sanchez on 7/1/17.
//  Copyright © 2017 Erick Sanchez. All rights reserved.
//

import UIKit
import CoreData

@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate, UNUserNotificationCenterDelegate {

    var window: UIWindow?

    class var sharedInstance: AppDelegate {
        return UIApplication.shared.delegate! as! AppDelegate
    }

    class var viewContext: NSManagedObjectContext {
        return AppDelegate.sharedInstance.persistentContainer.viewContext
    }

    var currentEmployer: Employer {
        get {
            if let employer = UserDefaults.standard.string(forKey: "employer") { //Fetches the default employer
                if let objectId = persistentContainer.persistentStoreCoordinator.managedObjectID(forURIRepresentation: URL(string: employer)!) {
                    if let fetchedObject = persistentContainer.viewContext.object(with: objectId) as? Employer {
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
                let defaultEmployer = Employer(inContext: persistentContainer.viewContext)
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

    /// Will call saveContext() on set
    var currentRole: Role {
        get {
            return currentEmployer.selectedRole!
        }
        set {
            currentEmployer.selectedRole = newValue
            saveContext()
        }
    }

    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplicationLaunchOptionsKey: Any]?) -> Bool {
        // Override point for customization after application launch.

        // if the application has NOT already launched, then set up first-time settings
        if (UserDefaults.standard.value(forKey: "hasAlreadyLaunched") as? Bool ?? false) == false {

        }

        AppDelegate.userNotificationCenter.configNotificationCategories(delegate: self)

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

    func userNotificationCenter(_ center: UNUserNotificationCenter, didReceive response: UNNotificationResponse, withCompletionHandler completionHandler: @escaping () -> Swift.Void) {
        if response.notification.request.content.categoryIdentifier == "UTILS_PUNCH_CLOCK" {
            if response.actionIdentifier == "ACT_PUNCH_NOW" {

            } else if response.actionIdentifier == "ACT_LUANCH" {

            } else if response.actionIdentifier == "ACT_PUNCH_MUTE" {
                UNUserNotificationCenter.current().removePendingFifthHourNotificationRequests()
            }
        }
        completionHandler()
    }
}

import CoreData

private typealias CoreData = AppDelegate
extension CoreData {

    override var canBecomeFirstResponder: Bool {
        return true
    }

    //Debuging
    override func motionEnded(_ motion: UIEventSubtype, with event: UIEvent?) {
    }
}

import UserNotifications

private typealias UserPermissions = AppDelegate
extension UserPermissions {
    public static let userNotificationCenter: UNUserNotificationCenter = UNUserNotificationCenter.current()

    private func userNotificationCenter(_ center: UNUserNotificationCenter, willPresent notification: UNNotification, withCompletionHandler completionHandler: @escaping (UNNotificationPresentationOptions) -> Void) {
        completionHandler(UNNotificationPresentationOptions.sound)
    }
}

extension UNUserNotificationCenter {

    public func configNotificationCategories(delegate: UNUserNotificationCenterDelegate?) {
        let generalCategory = UNNotificationCategory(identifier: "GENERAL",
                                                     actions: [],
                                                     intentIdentifiers: [],
                                                     options: .customDismissAction)

        let launchAction = UNNotificationAction(identifier: "ACT_LUANCH",
                                                title: "Edit Punches",
                                                options: .foreground)
        let punchMute = UNNotificationAction(identifier: "ACT_PUNCH_MUTE",
                                                title: "Mute")
        let punchClock = UNNotificationCategory(identifier: "UTILS_PUNCH_CLOCK",
                                                     actions: [launchAction, punchMute],
                                                     intentIdentifiers: [],
                                                     options: .init(rawValue: 0))

        UserPermissions.userNotificationCenter.setNotificationCategories([generalCategory,punchClock])
        UserPermissions.userNotificationCenter.delegate = delegate
    }
}
