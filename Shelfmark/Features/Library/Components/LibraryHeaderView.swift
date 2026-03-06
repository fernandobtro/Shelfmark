//
//  LibraryHeaderView.swift
//  Shelfmark
//
//  Created by Fernando Buenrostro on 05/03/26.
//

import Foundation
import SwiftUI

// MARK: - Instrucciones (completa en orden)
// 1. Recibe el ViewModel: @ObservedObject var viewModel: LibraryViewModel (o un Binding<FilterOption> + closure (FilterOption) -> Void). Con el ViewModel puedes leer viewModel.filterOption y llamar viewModel.selectFilter(_:).
// 2. Muestra tres botones o segmentos: "Todos", "Leyendo", "Favoritos" (usa FilterOption.displayName si lo definiste). Al pulsar, llama viewModel.selectFilter(.all), .reading, .favorites.
// 3. Marca visualmente el seleccionado (p. ej. .buttonStyle(.borderedProminent) para el actual y .bordered para los demás, o Picker con segmentos). No hace falta inyectar nada; solo el ViewModel.

struct LibraryHeaderView: View {
    @ObservedObject var viewModel: LibraryViewModel
    
    var body: some View {
        HStack(spacing: 8) {
            filterButton(.all)
            filterButton(.reading)
            filterButton(.favorites)
        }
        .padding(.horizontal)
    }
}

// MARK: - Helper views

private extension LibraryHeaderView {
    func filterButton(_ option: FilterOption) -> some View {
        let isSelected = viewModel.filterOption == option

        return Button(option.displayName) {
            viewModel.selectFilter(option)
        }
        .font(.subheadline.weight(.semibold))
        .foregroundColor(isSelected ? Color.white : Color.primary)
        .padding(.vertical, 8)
        .frame(maxWidth: .infinity)
        .background(
            RoundedRectangle(cornerRadius: 10)
                .fill(isSelected ? Color.theme.textPrimary : Color.clear)
        )
        .overlay(
            RoundedRectangle(cornerRadius: 10)
                .stroke(Color.theme.textPrimary.opacity(0.3), lineWidth: 1)
        )
        .buttonStyle(PlainButtonStyle())
    }
}
