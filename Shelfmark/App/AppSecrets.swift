//
//  AppSecrets.swift
//  Shelfmark
//
//  Created by Fernando Buenrostro on 12/03/26.
//

import Foundation

enum AppSecrets {
    static var booksAPIKey: String {
        guard let key = Bundle.main.object(forInfoDictionaryKey: "BooksAPIKey") as? String,
              !key.isEmpty else {
            fatalError("""
            🚨 Missing BooksAPIKey
            
            No se encontró la API Key en el Info.plist. 
            Asegúrate de haber creado el archivo Secrets.xcconfig y de haberlo
            vinculado correctamente en la configuración del proyecto.
            """)
        }
        return key
    }
}


