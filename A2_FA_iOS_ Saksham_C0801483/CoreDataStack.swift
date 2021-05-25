//
//  CoreDataStack.swift
//  A2_FA_iOS_ Saksham_C0801483
//
//  Created by Saksham Arora on 23/05/21.
//

import Foundation
import CoreData

class CoreDataStack: NSObject {
    
    // MARK:- Initialization
    
    typealias CoreDataCompletionClosure = ((Any)->Swift.Void)
    var completion: CoreDataCompletionClosure?
    var storeName = "OfflineContent"
    fileprivate let modelExtension = "momd"
    fileprivate let storeFileExtension = "sqlite"
    static let shared = CoreDataStack()
    
    private override init() {
        
    }
    
    // MARK:- Core Data Stack
    fileprivate lazy var persistentContainer: NSPersistentContainer = {
        let container = NSPersistentContainer(name: self.storeName)
        container.loadPersistentStores(completionHandler: { (storeDescription, error) in
            container.viewContext.mergePolicy = NSMergeByPropertyObjectTrumpMergePolicy
            if let error = error as NSError? {
                print(error.localizedDescription)
            }
        })
        return container
    }()
    
    lazy var mainManagedObjectContext: NSManagedObjectContext = {
        if #available(iOS 10.0, *) {
            return self.persistentContainer.viewContext
        } else {
            let managedObjectContext = NSManagedObjectContext(concurrencyType: .mainQueueConcurrencyType)
//            managedObjectContext.mergePolicy = NSMergeByPropertyObjectTrumpMergePolicy
            managedObjectContext.parent = self.privateManagedObjectContext
            return managedObjectContext
        }
    }()
    
    fileprivate lazy var privateManagedObjectContext: NSManagedObjectContext = {
        if #available(iOS 10.0, *) {
            return self.persistentContainer.newBackgroundContext()
        } else {
            let managedObjectContext = NSManagedObjectContext(concurrencyType: .privateQueueConcurrencyType)
            managedObjectContext.persistentStoreCoordinator = self.persistentStoreCoordinator
            return managedObjectContext
        }
    }()
    
    fileprivate lazy var managedObjectModel: NSManagedObjectModel? = {
        guard let xcDataModelURL = Bundle.main.url(forResource: self.storeName, withExtension: self.modelExtension) else {
            return nil
        }
        let managedObjectModel = NSManagedObjectModel(contentsOf: xcDataModelURL)
        return managedObjectModel
    }()
    
    fileprivate lazy var persistentStoreCoordinator: NSPersistentStoreCoordinator? = {
        guard let managedObjectModel = self.managedObjectModel else {
            return nil
        }
        let persistentStoreCoordinator = NSPersistentStoreCoordinator(managedObjectModel: managedObjectModel)
        return persistentStoreCoordinator
    }()
    

    
    fileprivate var persistentStoreURL: URL? {
        let storeName = "\(self.storeName).\(self.storeFileExtension)"
        return self.documentsURL(with: storeName)
    }
    
    func documentsURL(with fileName: String)-> URL? {
        let documentURl = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).last
        return documentURl?.appendingPathComponent(fileName)
    }
    
    fileprivate lazy var objectModel: NSManagedObjectModel? = {
        if #available(iOS 10.0, *) {
            return self.persistentContainer.managedObjectModel
        } else {
            return self.persistentStoreCoordinator?.managedObjectModel
        }
    }()
    
    lazy var entities: [String]? = {
        if let entities = self.objectModel?.entities, entities.count > 0 {
            return entities.map { $0.name ?? "" }
        }
        return nil
    }()

    // MARK: Member Functions
    fileprivate func setupCoreData()->Any {
        // fetch PersistentStoreCoordinator
        _ = mainManagedObjectContext.persistentStoreCoordinator
        self.addPersistentStore()
        return self
    }
    
    fileprivate func addPersistentStore() {
        guard let persistentStoreCoordinator = self.persistentStoreCoordinator else {
            return
        }
        do {
            guard let persistentStoreURL: URL = self.persistentStoreURL else {
                return
            }
            let options = [NSMigratePersistentStoresAutomaticallyOption: true, NSInferMappingModelAutomaticallyOption: true]
            try persistentStoreCoordinator.addPersistentStore(ofType: NSSQLiteStoreType, configurationName: nil, at: persistentStoreURL, options: options)
        } catch {
            print(error.localizedDescription)
        }
    }
}


extension CoreDataStack {
    
    // MARK:- Open APIs
    func initialize(with modelName: String)->Any{
        self.storeName = modelName
        return self.setupCoreData()
    }
    
    func saveContext() {
        mainManagedObjectContext.performAndWait {
            do {
                if self.mainManagedObjectContext.hasChanges {
                    try self.mainManagedObjectContext.save()
                }
            } catch {
                print(error.localizedDescription)
            }
        }
        
        privateManagedObjectContext.perform {
            do {
                if self.privateManagedObjectContext.hasChanges {
                    try self.privateManagedObjectContext.save()
                }
            } catch {
                 print(error.localizedDescription)
            }
        }
    }
    
    func fetch(from entity: String, with predicate: NSPredicate?, sortDescriptor: NSSortDescriptor?) -> [NSManagedObject] {
        var managedObjects = [NSManagedObject]()
        let fetchrequest = NSFetchRequest<NSFetchRequestResult>(entityName: entity)
        if let predicate = predicate {
            fetchrequest.predicate = predicate
        }
        if let sortDescriptor = sortDescriptor {
            fetchrequest.sortDescriptors?.append(sortDescriptor)
        }
        do {
            managedObjects = try self.mainManagedObjectContext.fetch(fetchrequest) as! [NSManagedObject]
        } catch {
             // Log.error?.message("\(#function):Error:\(error.localizedDescription)")
        }
        return managedObjects
    }
    
    func delete(_ obj:NSManagedObject){
        self.mainManagedObjectContext.delete(obj)
        self.saveContext()
    }
    
    func object(for anEntity: String) -> AnyObject {
        return self.managedObject(for: anEntity)
    }
    
    private func managedObject(for anEntityName: String) -> NSManagedObject {
        let managedObject = NSEntityDescription.insertNewObject(forEntityName: anEntityName, into: (self.mainManagedObjectContext))
        return managedObject
    }
}
