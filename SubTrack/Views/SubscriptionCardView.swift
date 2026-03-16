import SwiftUI

struct SubscriptionCardView: View {
    let subscription: SubscriptionEntity
    let onDelete: () -> Void

    var body: some View {
        HStack(spacing: 12) {
            Image(systemName: subscription.category.iconName)
                .font(.title3)
                .frame(width: 36, height: 36)
                .background(Color.blue.opacity(0.15))
                .clipShape(RoundedRectangle(cornerRadius: 10, style: .continuous))

            VStack(alignment: .leading, spacing: 4) {
                Text(subscription.name)
                    .font(.headline)
                Text("Renews \(subscription.nextRenewalDate, format: .dateTime.month().day().year())")
                    .font(.subheadline)
                    .foregroundStyle(.secondary)
            }

            Spacer()

            VStack(alignment: .trailing, spacing: 6) {
                Text(subscription.price, format: .currency(code: Locale.current.currency?.identifier ?? "USD"))
                    .font(.headline)
                Button(role: .destructive, action: onDelete) {
                    Image(systemName: "trash")
                }
                .buttonStyle(.borderless)
            }
        }
        .padding()
        .background(Color(.secondarySystemBackground))
        .clipShape(RoundedRectangle(cornerRadius: 16, style: .continuous))
    }
}
