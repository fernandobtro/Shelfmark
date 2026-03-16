import SwiftUI

struct AddBookOptionsSheetView: View {
    let onScanISBN: () -> Void
    let onAddManually: () -> Void
    let onDismiss: () -> Void

    @Environment(\.dismiss) private var dismiss

    var body: some View {
        NavigationStack {
            VStack(spacing: 24) {
                VStack(spacing: 8) {
                    Text("Añadir libro")
                        .font(.title2.weight(.semibold))
                        .frame(maxWidth: .infinity, alignment: .center)

                    Text("Elige cómo quieres añadir un libro a tu biblioteca.")
                        .font(.subheadline)
                        .foregroundStyle(.secondary)
                        .frame(maxWidth: .infinity, alignment: .center)
                }
                .padding(.horizontal)

                VStack(spacing: 0) {
                    optionRow(
                        systemImage: "barcode.viewfinder",
                        title: "Escanear ISBN",
                        subtitle: "Usa la cámara para leer el código de barras",
                        action: handleScanISBN
                    )

                    Divider()

                    optionRow(
                        systemImage: "square.and.pencil",
                        title: "Añadir manualmente",
                        subtitle: "Introduce los datos del libro a mano",
                        action: handleAddManually
                    )
                }
                .background(
                    RoundedRectangle(cornerRadius: 14, style: .continuous)
                        .fill(Color.theme.secondaryBackground)
                )
                .padding(.horizontal)

                Spacer()
            }
            .padding(.top, 24)
            .background(Color.theme.mainBackground.ignoresSafeArea())
        }
    }

    private func optionRow(
        systemImage: String,
        title: String,
        subtitle: String,
        action: @escaping () -> Void
    ) -> some View {
        Button(action: action) {
            HStack(spacing: 12) {
                Image(systemName: systemImage)
                    .font(.system(size: 20))
                    .frame(width: 28, height: 28)
                    .foregroundStyle(.primaryGreen)

                VStack(alignment: .leading, spacing: 2) {
                    Text(title)
                        .font(.body.weight(.medium))
                        .foregroundStyle(Color.theme.textPrimary)
                    Text(subtitle)
                        .font(.caption)
                        .foregroundStyle(.secondary)
                }

                Spacer()
            }
            .padding(.horizontal, 16)
            .padding(.vertical, 12)
        }
        .buttonStyle(.plain)
    }

    private func handleScanISBN() {
        onScanISBN()
        handleDismiss()
    }

    private func handleAddManually() {
        onAddManually()
        handleDismiss()
    }

    private func handleDismiss() {
        onDismiss()
        dismiss()
    }
}

#Preview {
    AddBookOptionsSheetView(
        onScanISBN: {},
        onAddManually: {},
        onDismiss: {}
    )
}

