//
//  Decodable+Utils.swift
//  TuneBrowseTests
//
//  Created by Calin Drule on 29.06.2022.
//

import Foundation

extension Decodable {
    static func loadFromFile(_ filename: String, decoder: JSONDecoder) -> Self {
        do {
            let path = Bundle(for: ITunesAPITests.self).path(forResource: filename, ofType: nil)!
            let data = try Data(contentsOf: URL(fileURLWithPath: path))

            return try decoder.decode(Self.self, from: data)
        } catch {
            fatalError("Error: \(error)")
        }
    }
}
