//
//  PodcastsTableViewCell.swift
//  TuneBrowse
//
//  Created by Calin Drule on 24.06.2022.
//

import UIKit
import Combine

class PodcastsTableViewCell: UITableViewCell, ReusableView {

    @IBOutlet weak var iconImageView: UIImageView!
    
    @IBOutlet weak var artistNameLabel: UILabel!
    
    @IBOutlet weak var trackNameLabel: UILabel!
    
    var viewModel: PodcastCellViewModelable!

    func bind(to viewModel: PodcastCellViewModelable) {
        cancelImageLoading()
        artistNameLabel.text = viewModel.artistName
        trackNameLabel.text = viewModel.trackName
        
        subscriber = viewModel.poster.sink { [unowned self] image in self.showImage(image: image) }
    }
    
    override func prepareForReuse() {
        super.prepareForReuse()
        cancelImageLoading()
    }
    
    // MARK: - ReusableView
    
    static var reuseIdentifier: String {
        return "PodcastCellReuseIdentifier"
    }
    
    // MARK: - Private
    
    private var subscriber: AnyCancellable?
    
    private func cancelImageLoading() {
        iconImageView.image = nil
        subscriber?.cancel()
    }
    
    private func showImage(image: UIImage?) {
        cancelImageLoading()
        
        UIView.transition(with: self.iconImageView,
            duration: 0.3,
            options: [.curveEaseOut, .transitionCrossDissolve],
            animations: {
                self.iconImageView?.image = image
            })
    }
}
