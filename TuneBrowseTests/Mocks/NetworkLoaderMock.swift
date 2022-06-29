//
//  NetworkLoaderMock.swift
//  TuneBrowseTests
//
//  Created by Calin Drule on 29.06.2022.
//

import Foundation
import Combine

@testable import TuneBrowse

class NetworkLoaderMock: NetworkLoadable {

    var loadCallsCount = 0
    var loadCalled: Bool {
        return loadCallsCount > 0
    }
    var responses = [String:Any]()

    func load<T>(_ resource: Resource<T>) -> AnyPublisher<T, Error> {
        if let response = responses[resource.url.path] as? T {
            return .just(response)
        } else if let error = responses[resource.url.path] as? NetworkError {
            return .fail(error)
        } else {
            return .fail(NetworkError.invalidRequest)
        }
    }
}

