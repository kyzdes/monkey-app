import CoreData
import Foundation

class PersistenceController {
    static let shared = PersistenceController()

    let container: NSPersistentContainer

    init(inMemory: Bool = false) {
        container = NSPersistentContainer(name: "MonkeyTamagotchi")

        if inMemory {
            container.persistentStoreDescriptions.first?.url = URL(fileURLWithPath: "/dev/null")
        }

        container.loadPersistentStores { description, error in
            if let error = error {
                fatalError("Unable to load persistent stores: \(error)")
            }
        }

        container.viewContext.automaticallyMergesChangesFromParent = true
    }

    func save() {
        let context = container.viewContext

        if context.hasChanges {
            do {
                try context.save()
            } catch {
                print("Error saving context: \(error)")
            }
        }
    }

    // MARK: - Monkey Operations

    func saveMonkey(_ monkey: Monkey) {
        let context = container.viewContext

        do {
            let encoder = JSONEncoder()
            let data = try encoder.encode(monkey)

            let fetchRequest: NSFetchRequest<MonkeyEntity> = MonkeyEntity.fetchRequest()
            fetchRequest.predicate = NSPredicate(format: "id == %@", monkey.id as CVarArg)

            if let existingEntity = try context.fetch(fetchRequest).first {
                existingEntity.data = data
            } else {
                let entity = MonkeyEntity(context: context)
                entity.id = monkey.id
                entity.data = data
            }

            try context.save()
        } catch {
            print("Error saving monkey: \(error)")
        }
    }

    func loadMonkey() -> Monkey? {
        let context = container.viewContext

        do {
            let fetchRequest: NSFetchRequest<MonkeyEntity> = MonkeyEntity.fetchRequest()
            let entities = try context.fetch(fetchRequest)

            guard let entity = entities.first, let data = entity.data else {
                return nil
            }

            let decoder = JSONDecoder()
            let monkey = try decoder.decode(Monkey.self, from: data)
            return monkey
        } catch {
            print("Error loading monkey: \(error)")
            return nil
        }
    }

    func deleteMonkey() {
        let context = container.viewContext

        do {
            let fetchRequest: NSFetchRequest<NSFetchRequestResult> = MonkeyEntity.fetchRequest()
            let deleteRequest = NSBatchDeleteRequest(fetchRequest: fetchRequest)
            try context.execute(deleteRequest)
            try context.save()
        } catch {
            print("Error deleting monkey: \(error)")
        }
    }
}

// MARK: - Core Data Entities

@objc(MonkeyEntity)
public class MonkeyEntity: NSManagedObject {
    @NSManaged public var id: UUID?
    @NSManaged public var data: Data?
}

extension MonkeyEntity {
    @nonobjc public class func fetchRequest() -> NSFetchRequest<MonkeyEntity> {
        return NSFetchRequest<MonkeyEntity>(entityName: "MonkeyEntity")
    }
}
