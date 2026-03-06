//
//  LibraryGridView.swift
//  Shelfmark
//
//  Created by Fernando Buenrostro on 05/03/26.
//

import Foundation
import SwiftUI

// MARK: - Instrucciones (completa en orden)
// 1. Propiedades:
//    - Deja `let sections: [LibrarySection]` como entrada principal.
//    - Opcional: añade un callback `let onDelete: (UUID) -> Void` si quieres soportar borrar libros desde el grid.
//
// 2. Columnas del grid:
//    - Declara arriba de `body` algo como:
//         private let columns = [
//             GridItem(.flexible(minimum: 120, maximum: 160), spacing: 16)
//         ]
//      para tener 2–3 columnas según el ancho, parecido al mock.
//
// 3. Implementa el body paso a paso:
//    - Si `sections.isEmpty`, muestra un `ContentUnavailableView` o un `EmptyView()` (esto se verá cuando no haya libros o el filtro no devuelva nada).
//    - Si NO está vacío:
//         ScrollView {
//             LazyVGrid(columns: columns, alignment: .leading, spacing: 24) {
//                 ForEach(sections) { section in
//                     // Si quieres mostrar el título de sección (cuando agrupes por autor/editorial),
//                     // puedes poner aquí un Text(section.categoryName) con font .headline.
//                     ForEach(section.books) { book in
//                         // Envuelve la celda en NavigationLink(value: book.id) en la vista padre,
//                         // aquí solo usa la tarjeta:
//                         LibraryCellView(book: book)
//                     }
//                 },
//             }
//             .padding(.horizontal)
//         }
//
// 4. Borrado (opcional, solo si añades onDelete):
//    - En lugar de `ForEach(section.books)` simple, podrías usar:
//         ForEach(section.books) { book in
//             LibraryCellView(book: book)
//                 .contextMenu { Button(\"Eliminar\", role: .destructive) { onDelete(book.id) } }
//         }
//      y en `LibraryView` pasarías `onDelete` que llame a `viewModel.delete(bookId:)`.

struct LibraryGridView: View {
    let sections: [LibrarySection]
    let onDelete: (UUID) -> Void
    
    private let columns = [GridItem(.flexible(minimum: 120, maximum: 160),spacing: 16)]

    var body: some View {
        if sections.isEmpty {
            EmptyView()
        } else {
            ScrollView {
                LazyVGrid(columns: columns, alignment: .leading, spacing: 24) {
                    ForEach(sections) { section in
                        // Si hay más de una sección (cuando agrupas), puedes mostrar el título
                        if sections.count > 1 {
                            Text(section.categoryName)
                                .font(.headline)
                                .padding(.horizontal)
                        }

                        ForEach(section.books, id: \.id) { book in
                            LibraryCellView(book: book)
                                .contextMenu {
                                    Button("Eliminar", role: .destructive) {
                                        onDelete(book.id)
                                    }
                                }
                        }
                    }
                }
                .padding(.horizontal)
            }
        }
    }
}
