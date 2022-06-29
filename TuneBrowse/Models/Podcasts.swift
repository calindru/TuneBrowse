//
//  Podcast.swift
//  TuneBrowse
//
//  Created by Calin Drule on 24.06.2022.
//

import Foundation

struct Podcast: Decodable {
    var trackId: Int
    var artistName: String
    var trackName: String
    var iconURL: String
    var releaseDate: Date
    
    private enum CodingKeys: String, CodingKey {
        case trackId
        case artistName
        case trackName
        case iconURL = "artworkUrl100"
        case releaseDate
    }
}
