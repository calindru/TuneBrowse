//
//  iTunesAPI.swift
//  TuneBrowse
//
//  Created by Calin Drule on 24.06.2022.
//

import Foundation
import Combine

enum PodcastsError: Error {
    case statusCode
    case decoding
    case invalidURL
    case other(Error)
    
    static func translate(_ error: Error) -> PodcastsError {
        (error as? PodcastsError) ?? .other(error)
    }
}

class ITunesAPI {
    func searchPodcasts(phrase: String) -> AnyPublisher<PodcastsResults, PodcastsError> {
        let term = phrase.hostEncoded()
        let url = URL(string: "https://itunes.apple.com/search?term=\(term)&entity=podcast")!

        let config = URLSessionConfiguration.default
        config.requestCachePolicy = .reloadIgnoringLocalCacheData
        config.urlCache = nil
        let session = URLSession(configuration: config)

        let urlRequest = URLRequest(url: url)

        return session.dataTaskPublisher(for: urlRequest)
          .tryMap { response -> Data in
            guard
              let httpURLResponse = response.response as? HTTPURLResponse,
              httpURLResponse.statusCode == 200
              else {
                throw PodcastsError.statusCode
            }
              
            return response.data
          }
          .decode(type: PodcastsResults.self, decoder: JSONDecoder())
          .mapError { PodcastsError.translate($0) }
          .eraseToAnyPublisher()
    }
}
