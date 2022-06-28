//
//  UIImage+Combine.swift
//  TuneBrowse
//
//  Created by Calin Drule on 24.06.2022.
//

import Foundation
import UIKit
import Combine

enum ImageError: Error {
    case statusCode
    case decoding
    case invalidURL
    case invalidImage
    case other(Error)
    
    static func translate(_ error: Error) -> ImageError {
        (error as? ImageError) ?? .other(error)
    }
}

extension UIImage {
    static func download(from url: String) -> AnyPublisher<UIImage?, ImageError> {
        guard let url = URL(string: url) else {
            return Fail(error: ImageError.invalidURL)
                .eraseToAnyPublisher()
        }
        
        return URLSession.shared.dataTaskPublisher(for: url)
            .tryMap { response -> Data in
                guard
                    let httpURLResponse = response.response as? HTTPURLResponse,
                    httpURLResponse.statusCode == 200
                else {
                    throw ImageError.statusCode
                }
                
                return response.data
            }
            .tryMap { data in
                guard let image = UIImage(data: data) else {
                    throw ImageError.invalidImage
                }
                return image
            }
            .mapError { ImageError.translate($0) }
            .eraseToAnyPublisher()
    }
}
