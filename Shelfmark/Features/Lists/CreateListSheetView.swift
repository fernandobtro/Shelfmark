//
//  CreateListSheetView.swift
//  Shelfmark
//
//  Sheet para crear una nueva lista; se presenta desde RootView al pulsar + en la pestaña Listas.
//

import SwiftUI
import Observation

struct CreateListSheetView: View {
    @Bindable var viewModel: ListsViewModel
    var onDismiss: () -> Void

    var body: some View {
        NavigationStack {
            Form {
                TextField("Nombre de la lista", text: $viewModel.newListName)
            }
            .navigationTitle("Nueva lista")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Cancelar") {
                        viewModel.newListName = ""
                        onDismiss()
                    }
                }
                ToolbarItem(placement: .confirmationAction) {
                    Button("Crear") {
                        Task {
                            await viewModel.createList()
                            onDismiss()
                        }
                    }
                    .disabled(viewModel.newListName.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty)
                }
            }
        }
    }
}
