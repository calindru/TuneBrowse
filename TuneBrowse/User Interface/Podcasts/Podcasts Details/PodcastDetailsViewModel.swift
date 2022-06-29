//
//  PodcastDetailsViewModel.swift
//  TuneBrowse
//
//  Created by Calin Drule on 28.06.2022.
//

import Foundation
import UIKit.UIImage
import Combine

protocol PodcastDetailsViewModelable {
    var artistName: String { get }
    var trackName: String { get }
    var releaseDate: String { get }
    var poster: AnyPublisher<UIImage?, Never> { get }
}

class PodcastDetailsViewModel: PodcastDetailsViewModelable {
    
    init(podcast: Podcast, poster: AnyPublisher<UIImage?, Never>) {
        self.podcast = podcast
        self.poster = poster
    }
    
    // MARK: - PodcastDetailsViewModelable
    
    var artistName: String {
        podcast.artistName
    }
    
    var trackName: String {
        podcast.trackName
    }
    
    var releaseDate: String {
        dateFormatter.string(from: podcast.releaseDate)
    }
    
    var poster: AnyPublisher<UIImage?, Never>
    
    // MARK: - Private
    
    private var podcast: Podcast
    
    private let dateFormatter: DateFormatter = {
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "dd M yyyy"
        
        return dateFormatter
    }()
}
