//
//  iTunesAPI.swift
//  TuneBrowse
//
//  Created by Calin Drule on 24.06.2022.
//

import Foundation
import Combine

class ITunesAPI {
    func searchPodcasts(phrase: String) -> AnyPublisher<PodcastsResults, RequestError> {
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
                throw RequestError.statusCode
            }
              
            return response.data
          }
          .decode(type: PodcastsResults.self, decoder: JSONDecoder())
          .mapError { RequestError.translate($0) }
          .eraseToAnyPublisher()
    }
}

extension Resource {

    static func podcasts(phrase: String) -> Resource<PodcastsResults> {
        let term = phrase.hostEncoded()
        let url = URL(string: "https://itunes.apple.com/search")!
        let parameters: [String : CustomStringConvertible] = [
            "term": term,
            "entity": "podcast"
            ]
        return Resource<PodcastsResults>(url: url, parameters: parameters)
    }
}
