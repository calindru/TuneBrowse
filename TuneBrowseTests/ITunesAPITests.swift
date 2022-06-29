//
//  ITunesAPITests.swift
//  TuneBrowseTests
//
//  Created by Calin Drule on 29.06.2022.
//

import XCTest
import Combine
@testable import TuneBrowse

class ITunesAPITests: XCTestCase {

    private lazy var session: URLSession = {
        let config = URLSessionConfiguration.ephemeral
        config.protocolClasses = [URLProtocolMock.self]
        return URLSession(configuration: config)
    }()
    private lazy var networkLoader = NetworkLoader(session: session)
    private let resource = Resource<PodcastsResults>.podcasts(phrase: "myheritage")
    private lazy var podcastsJSONData: Data = {
        let url = Bundle(for: ITunesAPITests.self).url(forResource: "PodcastsResults", withExtension: "json")
        guard let resourceUrl = url, let data = try? Data(contentsOf: resourceUrl) else {
            XCTFail("Failed to read json file!")
            return Data()
        }
        return data
    }()
    private var subscriptions: [AnyCancellable] = []

    override class func setUp() {
        URLProtocol.registerClass(URLProtocolMock.self)
    }

    func test_loadFinishedSuccessfully() {
        // Given
        var result: Result<PodcastsResults, Error>?
        let expectation = self.expectation(description: "networkServiceExpectation")
        URLProtocolMock.requestHandler = { request in
            let response = HTTPURLResponse(url: self.resource.url, statusCode: 200, httpVersion: nil, headerFields: nil)!
            return (response, self.podcastsJSONData)
        }

        // When
        networkLoader.load(resource)
            .map({ podcasts -> Result<PodcastsResults, Error> in Result.success(podcasts)})
            .catch({ error -> AnyPublisher<Result<PodcastsResults, Error>, Never> in .just(.failure(error)) })
            .sink(receiveValue: { value in
                result = value
                expectation.fulfill()
        }).store(in: &subscriptions)

        // Then
        self.waitForExpectations(timeout: 1.0, handler: nil)
        guard case .success(let podcasts) = result else {
            XCTFail()
            return
        }
        XCTAssertEqual(podcasts.results.count, 9)
    }

    func test_loadFailedWithInternalError() {
        // Given
        var result: Result<PodcastsResults, Error>?
        let expectation = self.expectation(description: "networkServiceExpectation")
        URLProtocolMock.requestHandler = { request in
            let response = HTTPURLResponse(url: self.resource.url, statusCode: 500, httpVersion: nil, headerFields: nil)!
            return (response, Data())
        }

        // When
        networkLoader.load(resource)
            .map({ podcasts -> Result<PodcastsResults, Error> in Result.success(podcasts)})
            .catch({ error -> AnyPublisher<Result<PodcastsResults, Error>, Never> in .just(.failure(error)) })
            .sink(receiveValue: { value in
                result = value
                expectation.fulfill()
            }).store(in: &subscriptions)

        // Then
        self.waitForExpectations(timeout: 1.0, handler: nil)
        guard case .failure(let error) = result,
            let networkError = error as? NetworkError,
            case NetworkError.dataLoadingError(500, _) = networkError else {
            XCTFail()
            return
        }
    }

    func test_loadFailedWithJsonParsingError() {
        // Given
        var result: Result<PodcastsResults, Error>?
        let expectation = self.expectation(description: "networkServiceExpectation")
        URLProtocolMock.requestHandler = { request in
            let response = HTTPURLResponse(url: self.resource.url, statusCode: 200, httpVersion: nil, headerFields: nil)!
            return (response, Data())
        }

        // When
        networkLoader.load(resource)
            .map({ podcasts -> Result<PodcastsResults, Error> in Result.success(podcasts)})
            .catch({ error -> AnyPublisher<Result<PodcastsResults, Error>, Never> in .just(.failure(error)) })
            .sink(receiveValue: { value in
                result = value
                expectation.fulfill()
            }).store(in: &subscriptions)

        // Then
        self.waitForExpectations(timeout: 1.0, handler: nil)
                    
        guard case .failure(let error) = result, error is DecodingError else {
            XCTFail()
            return
        }
    }

}
