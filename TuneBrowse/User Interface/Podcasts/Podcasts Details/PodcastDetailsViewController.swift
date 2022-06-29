//
//  PodcastDetailsViewController.swift
//  TuneBrowse
//
//  Created by Calin Drule on 24.06.2022.
//

import UIKit
import Combine

class PodcastDetailsViewController: UIViewController {

    @IBOutlet weak var iconImageView: UIImageView!
    
    @IBOutlet weak var titleDescriptionLabel: UILabel!
    
    @IBOutlet weak var titleValueLabel: UILabel!
    
    @IBOutlet weak var artistDescriptionLabel: UILabel!
    
    @IBOutlet weak var artistValueLabel: UILabel!
    
    @IBOutlet weak var releaseDateDescriptionLabel: UILabel!
    
    @IBOutlet weak var releaseDateValueLabel: UILabel!
    
    var viewModel: PodcastDetailsViewModelable!
    
    override func viewDidLoad() {
        super.viewDidLoad()

        loadViewModel()
    }
    

    // MARK: - Private
    
    private var subscriber: AnyCancellable?
    
    private func loadViewModel() {
        titleValueLabel.text = viewModel.trackName
        artistValueLabel.text = viewModel.artistName
        releaseDateValueLabel.text = viewModel.releaseDate
        
        subscriber = viewModel.poster.sink { [unowned self] image in self.showImage(image: image) }
    }
    
    private func showImage(image: UIImage?) {
        UIView.transition(with: self.iconImageView,
            duration: 0.3,
            options: [.curveEaseOut, .transitionCrossDissolve],
            animations: {
                self.iconImageView?.image = image
            })
    }
}
