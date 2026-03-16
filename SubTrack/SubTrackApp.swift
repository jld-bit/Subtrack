import SwiftUI

@main
struct SubTrackApp: App {
    let persistenceController = PersistenceController.shared
    @StateObject private var purchaseManager = PurchaseManager()

    var body: some Scene {
        WindowGroup {
            ContentView()
                .environment(\.managedObjectContext, persistenceController.container.viewContext)
                .environmentObject(purchaseManager)
        }
    }
}
