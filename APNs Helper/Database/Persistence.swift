//
//  Persistence.swift
//  APNs Helper
//
//  Created by joker on 2022/9/24.
//

import CoreData

struct PersistenceController {
    
    static var preview = PersistenceController(inMemory: true)
    
    static let shared = PersistenceController()
    
    let container: NSPersistentContainer
    
    init(inMemory: Bool = false) {
        
        container = NSPersistentContainer(name: "CoreDataStore")
        
        if inMemory {
            container.persistentStoreDescriptions.first!.url = URL(fileURLWithPath: "/dev/null")
        }
        
        container.loadPersistentStores(completionHandler: { (storeDescription, error) in
            if let error = error as NSError? {
                /*
                 Typical reasons for an error here include:
                 * The parent directory does not exist, cannot be created, or disallows writing.
                 * The persistent store is not accessible, due to permissions or data protection when the device is locked.
                 * The device is out of space.
                 * The store could not be migrated to the current model version.
                 */
                fatalError("Unresolved error \(error), \(error.userInfo)")
            }
        })
        
        container.viewContext.automaticallyMergesChangesFromParent = true
    }
}

extension NSManagedObjectContext {
    
    func synchronize() {
        do {
            try self.save()
        } catch {
#if DEBUG
            let nsError = error as NSError
            fatalError("Unresolved error \(nsError), \(nsError.userInfo)")
#endif
        }
    }
}
