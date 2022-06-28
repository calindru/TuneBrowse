//
//  PodcastsSearchViewModel.swift
//  TuneBrowse
//
//  Created by Calin Drule on 25.06.2022.
//

import Foundation
import Combine
import UIKit

struct PodcastsViewModelInput {
    // called when a screen becomes visible
    let appear: AnyPublisher<Void, Never>
    
    // triggered when a search query is updated
    let search: AnyPublisher<String, Never>
    
    // called when a user selected an item from the list
    let selection: AnyPublisher<Int, Never>
}

typealias PodcastsViewModelOuput = AnyPublisher<PodcastsSearchState, Never>

enum PodcastsSearchState {
    case idle
    case loading
    case success([PodcastCellViewModel])
    case noResults
    case failure(Error)
}

extension PodcastsSearchState: Equatable {
    static func == (lhs: PodcastsSearchState, rhs: PodcastsSearchState) -> Bool {
        switch (lhs, rhs) {
        case (.idle, .idle): return true
        case (.loading, .loading): return true
        case (.success(_), .success(_)): return true
        case (.noResults, .noResults): return true
        case (.failure, .failure): return true
        default: return false
        }
    }
}

protocol PodcastsSearchViewModelable {
    func transform(input: PodcastsViewModelInput) -> PodcastsViewModelOuput
}

class PodcastsSearchViewModel: PodcastsSearchViewModelable {

    init(useCase: PodcastsUseCaseable) {
        self.useCase = useCase
    }
    
    // MARK: - PodcastsSearchViewModelable
    
    func transform(input: PodcastsViewModelInput) -> PodcastsViewModelOuput {
        subscriptions.forEach { $0.cancel() }
        subscriptions.removeAll()
        
        input.selection
            .sink(receiveValue: { [unowned self] podcastIndex in
//                self.navigator?.showDetails(forMovie: movieId)
            })
            .store(in: &subscriptions)

        let searchInput = input.search
            .debounce(for: .milliseconds(300), scheduler: Scheduler.main)
            .removeDuplicates()
        let podcasts = searchInput
            .filter({ !$0.isEmpty })
            .flatMapLatest({ [unowned self] query in self.useCase.searchPodcasts(with: query) })
            .map({ result -> PodcastsSearchState in
                switch result {
                case .success(let podcasts) where podcasts.results.isEmpty:
                    return .noResults
                case .success(let podcasts):
                    return .success(self.viewModels(from: podcasts.results))
                case .failure(let error):
                    return .failure(error)
                }
            })
            .eraseToAnyPublisher()

        let initialState: PodcastsViewModelOuput = .just(.idle)
        let emptySearchString: PodcastsViewModelOuput = searchInput.filter({ $0.isEmpty }).map({ _ in .idle }).eraseToAnyPublisher()
        let idle: PodcastsViewModelOuput = Publishers.Merge(initialState, emptySearchString).eraseToAnyPublisher()

        return Publishers.Merge(idle, podcasts).removeDuplicates().eraseToAnyPublisher()
    }
    
    
    // MARK: - Private
    
    private let useCase: PodcastsUseCaseable
    private var subscriptions: Set<AnyCancellable> = []
    
    private func viewModels(from podcasts: [Podcast]) -> [PodcastCellViewModel] {
        let poster: (Podcast) -> AnyPublisher<UIImage?, Never> = { [unowned self] podcast in
            self.useCase.loadImage(for: podcast)
                .subscribe(on: Scheduler.background)
                .receive(on: Scheduler.main)
                .eraseToAnyPublisher()
        }
        return podcasts.map { PodcastCellViewModel(podcast: $0, poster: poster($0)) }
    }
}
