import Charts
import CoreData
import SwiftUI

struct ContentView: View {
    @Environment(\.managedObjectContext) private var viewContext
    @EnvironmentObject private var purchaseManager: PurchaseManager
    @StateObject private var viewModel = SubscriptionViewModel()
    @State private var isPresentingAdd = false
    @State private var showingLimitAlert = false

    @FetchRequest(
        sortDescriptors: [NSSortDescriptor(keyPath: \SubscriptionEntity.billingDate, ascending: true)],
        animation: .default
    )
    private var subscriptions: FetchedResults<SubscriptionEntity>

    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(spacing: 16) {
                    spendingHeader
                    analyticsCard
                    subscriptionsSection
                }
                .padding()
            }
            .background(Color(.systemGroupedBackground))
            .navigationTitle("SubTrack")
            .toolbar {
                ToolbarItem(placement: .topBarTrailing) {
                    Button {
                        isPresentingAdd = true
                    } label: {
                        Label("Add", systemImage: "plus")
                    }
                }
            }
            .sheet(isPresented: $isPresentingAdd) {
                AddSubscriptionView(viewModel: viewModel) {
                    let created = viewModel.addSubscription(
                        context: viewContext,
                        purchaseManager: purchaseManager,
                        currentCount: subscriptions.count
                    )
                    if !created {
                        showingLimitAlert = true
                    }
                    return created
                }
            }
            .task {
                await NotificationManager.shared.requestAuthorization()
            }
            .alert("Upgrade required", isPresented: $showingLimitAlert) {
                Button("Unlock Unlimited") {
                    Task { await purchaseManager.purchaseUnlimited() }
                }
                Button("Cancel", role: .cancel) {}
            } message: {
                Text("The free plan supports up to 5 subscriptions. Upgrade to unlock unlimited tracking and full analytics.")
            }
        }
    }

    private var spendingHeader: some View {
        VStack(alignment: .leading, spacing: 8) {
            Text("Monthly spending")
                .font(.headline)
                .foregroundStyle(.secondary)

            Text(viewModel.totalMonthlySpending(for: Array(subscriptions)), format: .currency(code: Locale.current.currency?.identifier ?? "USD"))
                .font(.system(size: 36, weight: .bold, design: .rounded))
        }
        .frame(maxWidth: .infinity, alignment: .leading)
        .padding()
        .background(.thinMaterial)
        .clipShape(RoundedRectangle(cornerRadius: 20, style: .continuous))
    }

    private var analyticsCard: some View {
        VStack(alignment: .leading, spacing: 12) {
            HStack {
                Text("Spending analytics")
                    .font(.headline)
                Spacer()
                if !purchaseManager.hasUnlimitedAccess {
                    Text("PRO")
                        .font(.caption.bold())
                        .padding(.horizontal, 8)
                        .padding(.vertical, 4)
                        .background(Color.blue.opacity(0.15))
                        .clipShape(Capsule())
                }
            }

            if purchaseManager.hasUnlimitedAccess {
                SpendingChartView(data: viewModel.categoryTotals(for: Array(subscriptions)))
                    .frame(height: 220)
            } else {
                VStack(alignment: .leading, spacing: 8) {
                    Text("Unlock visual spending analytics with SubTrack Unlimited.")
                    Button("Upgrade with In-App Purchase") {
                        Task { await purchaseManager.purchaseUnlimited() }
                    }
                    .buttonStyle(.borderedProminent)
                }
                .font(.subheadline)
                .foregroundStyle(.secondary)
            }
        }
        .frame(maxWidth: .infinity, alignment: .leading)
        .padding()
        .background(Color(.secondarySystemGroupedBackground))
        .clipShape(RoundedRectangle(cornerRadius: 20, style: .continuous))
    }

    private var subscriptionsSection: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("Subscriptions")
                .font(.headline)

            ForEach(subscriptions) { subscription in
                SubscriptionCardView(subscription: subscription) {
                    viewModel.delete(subscription, context: viewContext)
                }
            }

            if subscriptions.isEmpty {
                ContentUnavailableView("No subscriptions yet", systemImage: "tray", description: Text("Tap + to add your first recurring payment."))
                    .padding(.vertical, 24)
            }
        }
    }
}
