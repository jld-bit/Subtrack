import SwiftUI

struct AddSubscriptionView: View {
    @ObservedObject var viewModel: SubscriptionViewModel
    var onSave: () -> Bool

    @Environment(\.dismiss) private var dismiss

    var body: some View {
        NavigationStack {
            Form {
                Section("Subscription") {
                    TextField("Name", text: $viewModel.name)
                    TextField("Price", text: $viewModel.price)
                        .keyboardType(.decimalPad)
                    DatePicker("Billing date", selection: $viewModel.billingDate, displayedComponents: .date)

                    Picker("Category", selection: $viewModel.category) {
                        ForEach(SubscriptionCategory.allCases) { category in
                            Label(category.title, systemImage: category.iconName)
                                .tag(category)
                        }
                    }
                }
            }
            .navigationTitle("Add Subscription")
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Cancel") { dismiss() }
                }
                ToolbarItem(placement: .confirmationAction) {
                    Button("Save") {
                        if onSave() {
                            dismiss()
                        }
                    }
                }
            }
        }
    }
}
