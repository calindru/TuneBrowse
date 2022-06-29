//
//  PodcastsUseCase.swift
//  TuneBrowse
//
//  Created by Calin Drule on 27.06.2022.
//

import UIKit
import Combine

protocol PodcastsUseCaseable {
    // Runs podcasts search with a query string
    func searchPodcasts(with phrase: String) -> AnyPublisher<Result<PodcastsResults, Error>, Never>

    // Loads image for the given podcast
    func loadImage(for podcast: Podcast) -> AnyPublisher<UIImage?, Never>
}

final class PodcastsUseCase {
    private let networkLoader: NetworkLoadable
    
    init(networkLoader: NetworkLoadable) {
        self.networkLoader = networkLoader
    }
}

extension PodcastsUseCase: PodcastsUseCaseable {
    func searchPodcasts(with phrase: String) -> AnyPublisher<Result<PodcastsResults, Error>, Never> {
        return networkLoader
            .load(Resource<PodcastsResults>.podcasts(phrase: phrase))
            .map { .success($0) }
            .catch { error -> AnyPublisher<Result<PodcastsResults, Error>, Never> in .just(.failure(error)) }
            .subscribe(on: Scheduler.background)
            .receive(on: Scheduler.main)
            .eraseToAnyPublisher()
    }
    
    func loadImage(for podcast: Podcast) -> AnyPublisher<UIImage?, Never> {
        let urlString = podcast.iconURL
        return UIImage.download(from: urlString)
            .replaceError(with: nil)
            .eraseToAnyPublisher()
    }
}
