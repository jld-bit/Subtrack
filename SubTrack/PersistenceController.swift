import CoreData

struct PersistenceController {
    static let shared = PersistenceController()

    let container: NSPersistentContainer

    init(inMemory: Bool = false) {
        let model = Self.makeManagedObjectModel()
        container = NSPersistentContainer(name: "SubTrack", managedObjectModel: model)

        if inMemory {
            container.persistentStoreDescriptions.first?.url = URL(fileURLWithPath: "/dev/null")
        }

        container.loadPersistentStores { _, error in
            if let error {
                fatalError("Unresolved Core Data error: \(error.localizedDescription)")
            }
        }
        container.viewContext.automaticallyMergesChangesFromParent = true
        container.viewContext.mergePolicy = NSMergeByPropertyObjectTrumpMergePolicy
    }

    private static func makeManagedObjectModel() -> NSManagedObjectModel {
        let model = NSManagedObjectModel()

        let subscription = NSEntityDescription()
        subscription.name = "SubscriptionEntity"
        subscription.managedObjectClassName = NSStringFromClass(SubscriptionEntity.self)

        let id = NSAttributeDescription()
        id.name = "id"
        id.attributeType = .UUIDAttributeType
        id.isOptional = false

        let name = NSAttributeDescription()
        name.name = "name"
        name.attributeType = .stringAttributeType
        name.isOptional = false

        let price = NSAttributeDescription()
        price.name = "price"
        price.attributeType = .doubleAttributeType
        price.isOptional = false

        let billingDate = NSAttributeDescription()
        billingDate.name = "billingDate"
        billingDate.attributeType = .dateAttributeType
        billingDate.isOptional = false

        let categoryRaw = NSAttributeDescription()
        categoryRaw.name = "categoryRaw"
        categoryRaw.attributeType = .stringAttributeType
        categoryRaw.isOptional = false

        subscription.properties = [id, name, price, billingDate, categoryRaw]
        model.entities = [subscription]

        return model
    }
}
