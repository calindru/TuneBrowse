//
//  PodcastsUseCaseTests.swift
//  TuneBrowseTests
//
//  Created by Calin Drule on 29.06.2022.
//

import XCTest
import Combine
@testable import TuneBrowse

class PodcastsUseCaseTests: XCTestCase {

    private let networkLoader = NetworkLoaderMock()
    private var useCase: PodcastsUseCase!
    private var subscriptions: [AnyCancellable] = []

    override func setUp() {
        useCase = PodcastsUseCase(networkLoader: networkLoader)
    }

    func test_searchPodcastsSucceeds() {
        // Given
        var result: Result<PodcastsResults, Error>!
        let expectation = expectation(description: "podcasts")
        let podcasts = PodcastsResults.loadFromFile("PodcastsResults.json", decoder: iTunesDecoder)
        networkLoader.responses["/search"] = podcasts

        // When
        useCase.searchPodcasts(with: "myheritage").sink { value in
            result = value
            expectation.fulfill()
        }.store(in: &subscriptions)

        // Then
        waitForExpectations(timeout: 1.0, handler: nil)
        guard case .success = result! else {
            XCTFail()
            return
        }
    }

    func test_searchMoviesFails_onNetworkError() {
        // Given
        var result: Result<PodcastsResults, Error>!
        let expectation = expectation(description: "podcasts")
        networkLoader.responses["/search"] = NetworkError.invalidResponse

        // When
        useCase.searchPodcasts(with: "myheritage").sink { value in
            result = value
            expectation.fulfill()
        }.store(in: &subscriptions)

        // Then
        waitForExpectations(timeout: 1.0, handler: nil)
        guard case .failure = result! else {
            XCTFail()
            return
        }
    }

    func test_loadsImageFromNetwork() {
        // Given
        let podcasts = PodcastsResults.loadFromFile("PodcastsResults.json", decoder: iTunesDecoder)
        let podcast = podcasts.results.last!
        var result: UIImage?
        let expectation = expectation(description: "loadImage")

        // When
        useCase.loadImage(for: podcast).sink { value in
            result = value
            expectation.fulfill()
        }.store(in: &subscriptions)

        // Then
        self.waitForExpectations(timeout: 1.0, handler: nil)
        XCTAssertNotNil(result)
    }

}
