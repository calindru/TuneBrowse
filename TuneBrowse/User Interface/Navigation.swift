//
//  Navigation.swift
//  TuneBrowse
//
//  Created by Calin Drule on 28.06.2022.
//

import Foundation

protocol PodcastsSearchNavigable: AnyObject {
    /// Presents the podcast details screen
    func showDetails(forPodcast podcast: Podcast)
}
