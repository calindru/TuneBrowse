//
//  RequestError.swift
//  TuneBrowse
//
//  Created by Calin Drule on 24.06.2022.
//

import Foundation

enum RequestError: Error {
    case statusCode
    case decoding
    case invalidURL
    case other(Error)
    
    static func translate(_ error: Error) -> RequestError {
        (error as? RequestError) ?? .other(error)
    }
}

