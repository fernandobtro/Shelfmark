import SwiftUI

struct FixedListRowView: View {
    let systemImage: String
    let title: String
    let subtitle: String

    var body: some View {
        HStack(spacing: 12) {
            ZStack {
                RoundedRectangle(cornerRadius: 10, style: .continuous)
                    .fill(Color.theme.secondaryBackground)
                    .frame(width: 40, height: 40)

                Image(systemName: systemImage)
                    .font(.system(size: 18, weight: .semibold))
                    .foregroundStyle(.primaryGreen)
            }

            VStack(alignment: .leading, spacing: 2) {
                Text(title)
                    .font(.headline)
                    .foregroundStyle(Color.theme.textPrimary)
                Text(subtitle)
                    .font(.caption)
                    .foregroundStyle(.secondary)
            }

            Spacer()
        }
        .frame(maxWidth: .infinity, alignment: .leading)
        .contentShape(Rectangle())
    }
}

#Preview {
    List {
        Section("Fijas") {
            FixedListRowView(
                systemImage: "bookmark",
                title: "Por leer",
                subtitle: "Libros marcados como pendientes"
            )
        }
    }
    .listStyle(.insetGrouped)
}

