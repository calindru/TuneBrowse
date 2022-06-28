//
//  ViewController.swift
//  TuneBrowse
//
//  Created by Calin Drule on 24.06.2022.
//

import UIKit
import Combine

class PodcastsSearchViewController: UIViewController, UISearchBarDelegate, UITableViewDelegate {

    @IBOutlet weak var searchBar: UISearchBar!
    
    @IBOutlet weak var podcastsTableView: UITableView!
    
    var viewModel: PodcastsSearchViewModelable!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        setupUI()
        bind(to: viewModel)
    }

    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        
        appear.send(())
    }
    
    // MARK: - UITableViewDelegate
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        selection.send(indexPath.row)
    }
    
    // MARK: - UISearchBarDelegate
    
    func searchBar(_ searchBar: UISearchBar, textDidChange searchText: String) {
        search.send(searchText)
    }

    func searchBarCancelButtonClicked(_ searchBar: UISearchBar) {
        search.send("")
    }
    
    // MARK: - Private
    
    private enum Constants {
        static let cellReuseIdentifier = "PodcastCellReuseIdentifier"
    }
    
    private func setupUI() {
        title = NSLocalizedString("Podcasts", comment: "Podcasts")
        
        podcastsTableView.tableFooterView = UIView()
        podcastsTableView.dataSource = dataSource
    }
    
    private var subscriptions: [AnyCancellable] = []
    
    private let appear = PassthroughSubject<Void, Never>()
    private let search = PassthroughSubject<String, Never>()
    private let selection = PassthroughSubject<Int, Never>()
    
    private lazy var dataSource = makeDataSource()
    
    private func bind(to viewModel: PodcastsSearchViewModelable) {
        subscriptions.forEach { $0.cancel() }
        subscriptions.removeAll()
        let input = PodcastsViewModelInput(appear: appear.eraseToAnyPublisher(),
                                           search: search.eraseToAnyPublisher(),
                                           selection: selection.eraseToAnyPublisher())

        let output = viewModel.transform(input: input)

        output.sink(receiveValue: {[unowned self] state in
            self.render(state)
        }).store(in: &subscriptions)
    }
    
    private enum Section: CaseIterable {
        case podcasts
    }
    
    private func makeDataSource() -> UITableViewDiffableDataSource<Section, PodcastCellViewModel> {
        return UITableViewDiffableDataSource(
            tableView: podcastsTableView,
            cellProvider: { tableView, indexPath, podcastViewModel in
                guard let cell = tableView.dequeueReusableCell(withClass: PodcastsTableViewCell.self) else {
                    assertionFailure("Failed to dequeue \(PodcastsTableViewCell.self)!")
                    return UITableViewCell()
                }
                
                cell.bind(to: podcastViewModel)
                return cell
            }
        )
    }
    
    private func render(_ state: PodcastsSearchState) {
        switch state {
        case .idle:
            break
        case .loading:
            break
        case .success(let podcasts):
            update(with: podcasts, animate: true)
        case .noResults:
            update(with: [], animate: true)
        case .failure(_):
            break
        }
    }
    
    private func update(with podcastsViewModels: [PodcastCellViewModel], animate: Bool = true) {
        DispatchQueue.main.async { [weak self] in
            var snapshot = NSDiffableDataSourceSnapshot<Section, PodcastCellViewModel>()
            snapshot.appendSections(Section.allCases)
            snapshot.appendItems(podcastsViewModels, toSection: .podcasts)
            self?.dataSource.apply(snapshot, animatingDifferences: animate)
        }
    }
}

