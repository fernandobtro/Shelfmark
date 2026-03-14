//
//  RecognizeTextInImageUseCase.swift
//  Shelfmark
//
//  Created by Fernando Buenrostro on 14/03/26.
//

import Foundation
import CoreGraphics

protocol RecognizeTextInImageUseCaseProtocol {
    /// Reconocer texto en una imagen (p. ej. para extraer una cita).
    /// - Parameter image: Imagen en formato CGImage (obtener desde UIImage.cgImage).
    /// - Returns: Texto reconocido, línea por línea separado por "\n".
    func execute(image: CGImage) async throws -> String
}
