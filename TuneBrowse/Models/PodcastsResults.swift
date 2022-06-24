//
//  PodcastsResults.swift
//  TuneBrowse
//
//  Created by Calin Drule on 24.06.2022.
//

import Foundation

struct PodcastsResults: Decodable {
    var resultCount: Int
    
    var results: Podcasts
}
