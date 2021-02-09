//
//  CodeDataStore.swift
//  Diary
//
//  Created by leeyuno on 2021/02/09.
//

import CoreData
import UIKit

struct CoreDataStore {
    static let dataStore = CoreDataStore()
    
    let managedObjectContext = (UIApplication.shared.delegate as! AppDelegate).persistentContainer.viewContext
    
    func createCoreData() {
        let entityDescription = NSEntityDescription.entity(forEntityName: "Diary", in: managedObjectContext)
        let contact = Diary(entity: entityDescription!, insertInto: managedObjectContext)
        
        contact.id = ""
        
        save()
    }
    
    func loadCoreData() -> CoreData? {
        let entityDescription = NSEntityDescription.entity(forEntityName: "Diary", in: managedObjectContext)
        let request = NSFetchRequest<NSFetchRequestResult>()
        request.entity = entityDescription
        
        do {
            let objects = try managedObjectContext.fetch(request)
            if objects.count > 0 {
                let match = objects[0] as! Diary
                Library.libObject.app_id = match.value(forKey: "id") as? String
                
                let coreData = CoreData(newId: match.value(forKey: "id") as? String)
                
                return coreData
                
            } else {
                createCoreData()
                return nil
            }
        } catch {
            print(debug: "error")
            return nil
        }
    }
    
    func setCoreData(data: CoreData) {
        let entityDescription = NSEntityDescription.entity(forEntityName: "Diary", in: managedObjectContext)
        let request = NSFetchRequest<NSFetchRequestResult>(entityName: "Diary")
        request.entity = entityDescription
        do {
            let objects = try managedObjectContext.fetch(request)
            
            if objects.count > 0 {
                let match = objects[0] as! Diary
                if data.id != nil {
                    match.setValue(data.id, forKey: "id")
                }
            }
            save()
        } catch {
            
        }
    }
    
    func removeCoreData() {
        let entityDescription = NSEntityDescription.entity(forEntityName: "Diary", in: managedObjectContext)
        let request = NSFetchRequest<NSFetchRequestResult>()
        request.entity = entityDescription
        do {
            let objects = try managedObjectContext.fetch(request)
            
            for object in objects {
                managedObjectContext.delete(object as! NSManagedObject)
            }
            save()
        } catch {
            print(error.localizedDescription)
        }
    }
    
    func save() {
        do {
            try managedObjectContext.save()
        } catch _ {
            
        }
    }
}

struct CoreData {
    var id: String?
    
    init(newId: String?) {
        id = newId
    }
}
