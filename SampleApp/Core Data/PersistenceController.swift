//
//  PersistenceController.swift
//  CoreDataSync
//

import CoreData
import UIKit
import OpenCloudData
import CloudKit

struct PersistenceController {
    static let shared = PersistenceController()

    static var preview: PersistenceController = {
        let result = PersistenceController()
        let viewContext = result.container.viewContext
        for i in 0 ..< 10 {
            let newContact = Contact(context: viewContext)
            newContact.name = "Contact #\(i)"
            newContact.photo = UIImage(systemName: "multiply.circle.fill")
        }
        do {
            try viewContext.save()
        } catch {
            // Replace this implementation with code to handle the error appropriately.
            // fatalError() causes the application to generate a crash log and terminate. You should not use this function in a shipping application, although it may be useful during development.
            let nsError = error as NSError
            fatalError("Unresolved error \(nsError), \(nsError.userInfo)")
        }
        return result
    }()

    let container: NSPersistentContainer = {
        let managedObjectModel: NSManagedObjectModel = {
            let modelURL = Bundle.main.url(forResource: "CoreDataSync", withExtension: "momd")!
            return NSManagedObjectModel(contentsOf: modelURL)!
        }()
        
//        for entity in managedObjectModel.entities {
//            if entity.name == "Entity" {
//                for (name, attribute) in entity.attributesByName {
//                    if name == "string" {
//                        attribute.userInfo = ["NSCloudKitMirroringDelegateIgnoredPropertyKey": true]
//                        break
//                    }
//                }
//                break
//            }
//        }
        
        let container: NSPersistentContainer
        if ProcessInfo.processInfo.environment["USE_OPEN_CLOUD_DATA"] == "1" {
            container = OCPersistentCloudKitContainer(name: "Container", managedObjectModel: managedObjectModel)
        } else {
            container = NSPersistentCloudKitContainer(name: "Container", managedObjectModel: managedObjectModel)
        }
        
        container.viewContext.automaticallyMergesChangesFromParent = true
        container.persistentStoreDescriptions.last!.shouldAddStoreAsynchronously = false
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
//            try! (container as! NSPersistentCloudKitContainer).initializeCloudKitSchema()
            
//            Task {
//                try! await Task.sleep(for: .seconds(1))
//                try! container.persistentStoreCoordinator.remove(container.persistentStoreCoordinator.persistentStores.first!)
//                print("Removed!")
//            }
        })

        return container
    }()
}
