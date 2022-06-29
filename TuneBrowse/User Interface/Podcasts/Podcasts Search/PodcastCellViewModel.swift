//
//  PodcastCellViewModel.swift
//  TuneBrowse
//
//  Created by Calin Drule on 24.06.2022.
//

import Foundation
import UIKit.UIImage
import Combine

protocol PodcastCellViewModelable {
    var podcast: Podcast { get }
    var trackId: Int { get }
    var artistName: String { get }
    var trackName: String { get }
    var poster: AnyPublisher<UIImage?, Never> { get }
}

class PodcastCellViewModel: PodcastCellViewModelable {
    
    init(podcast: Podcast, poster: AnyPublisher<UIImage?, Never>) {
        self.podcast = podcast
        self.poster = poster
    }
    
    // MARK: - PodcastCellViewModelable
    
    var podcast: Podcast
    
    var trackId: Int {
        podcast.trackId
    }
    
    var artistName: String {
        podcast.artistName
    }
    
    var trackName: String {
        podcast.trackName
    }
    
    var poster: AnyPublisher<UIImage?, Never>
    
    // MARK: - Private
    
    private var subscriptions: Set<AnyCancellable> = []
}

extension PodcastCellViewModel: Hashable {
    static func == (lhs: PodcastCellViewModel, rhs: PodcastCellViewModel) -> Bool {
        return lhs.trackId == rhs.trackId
    }

    func hash(into hasher: inout Hasher) {
        hasher.combine(artistName + trackName)
    }
}
