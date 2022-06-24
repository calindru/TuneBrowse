//
//  String+Utils.swift
//  TuneBrowse
//
//  Created by Calin Drule on 24.06.2022.
//

import Foundation

extension String {
    func hostEncoded() -> String {
        addingPercentEncoding(withAllowedCharacters: .urlHostAllowed) ?? ""
    }
}
