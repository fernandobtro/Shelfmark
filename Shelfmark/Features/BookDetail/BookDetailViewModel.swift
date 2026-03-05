//
//  BookDetailViewModel.swift
//  Shelfmark
//
//  Created by Fernando Buenrostro on 05/03/26.
//

import Combine
import Foundation

// MARK: - Estado de la pantalla (igual que en Library: un solo estado posible a la vez)

enum BookDetailState: Equatable {
    case idle
    case loading
    case loaded(Book)
    case error(String)
}

final class BookDetailViewModel: ObservableObject {
    /*
     Tus requisitos (y dónde se resuelven):
     1. "Recuperar la lista de libros desde SwiftData"
        → En detalle no usamos la lista; recuperamos UN libro por id.
        → Eso se hace en loadDetail(): llamamos al use case, que por debajo usa el repositorio (SwiftData).
        → Ver comentario [RECUPERAR] en loadDetail().

     2. "Mandar estos datos a la view para que los muestre"
        → Los datos se exponen en el estado: state = .loaded(book).
        → La view hace switch viewModel.state y en .loaded(let book) muestra título, autores, etc.
        → Ver comentario [MANDAR A LA VIEW] en loadDetail().

     3. "Recibir el UUID del libro para poder saber cual mostrar"
        → El UUID se recibe en el init y se guarda en bookId.
        → Ver comentario [RECIBIR UUID] en el init.
     */

    @Published var state: BookDetailState = .idle

    // [RECIBIR UUID] El id del libro que esta pantalla debe mostrar. Lo usa loadDetail() para pedirlo al use case.
    private let bookId: UUID
    private let fetchBookDetailUseCase: FetchBookDetailUseCaseProtocol

    init(bookId: UUID, fetchBookDetailUseCase: FetchBookDetailUseCaseProtocol) {
        self.bookId = bookId
        self.fetchBookDetailUseCase = fetchBookDetailUseCase
    }

    /// [RECUPERAR] Aquí se recupera el libro: el use case (que por debajo usa el repositorio → SwiftData) devuelve el Book con ese id.
    /// [MANDAR A LA VIEW] Al poner state = .loaded(book), la view recibe los datos y los muestra en el switch sobre state.
    func loadDetail() async {
        state = .loading
        do {
            let book = try await fetchBookDetailUseCase.execute(bookId: bookId)
            await MainActor.run {
                if let book = book {
                    state = .loaded(book)
                } else {
                    state = .error("No se encontró el libro.")
                }
            }
        } catch {
            await MainActor.run {
                state = .error(error.localizedDescription)
            }
        }
    }
}
