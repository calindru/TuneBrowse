//
//  iTunesAPI.swift
//  TuneBrowse
//
//  Created by Calin Drule on 24.06.2022.
//

import Foundation

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
