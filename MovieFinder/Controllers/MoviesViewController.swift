//
//  MoviesViewController.swift
//  MovieFinder
//
//  Created by Oleksiy Petlyuk on 24.09.2021.
//

import UIKit

class MoviesViewController: UIViewController {
  
  @IBOutlet weak var tableView: UITableView!
  
  lazy var searchBar = UISearchBar()
  
  lazy var activityIndicator = UIActivityIndicatorView(style: .medium)
  
  var networkClient: MovieFinderService = MovieFinderClient.shared
  
  var imageClient: ImageService = ImageClient.shared
  
  var viewModels: [MovieViewModel] = []
  
  var dataTask: URLSessionDataTask?
  
  override func viewDidLoad() {
    super.viewDidLoad()
    
    tableView.delegate = self
    tableView.dataSource = self
    
    setupSearchBar()
    setupActivityIndicator()
  }
  
  private func setupSearchBar() {
    searchBar.searchBarStyle = .default
    searchBar.placeholder = "Search..."
    searchBar.sizeToFit()
    searchBar.isTranslucent = false
    searchBar.backgroundImage = UIImage()
    searchBar.delegate = self
    navigationItem.titleView = searchBar
  }
  
  private func setupActivityIndicator() {
    activityIndicator.center = view.center
    view.addSubview(activityIndicator)
  }
  
  private func showAlert(message: String = "Something went wrong") {
    let alert = UIAlertController(title: "Error", message: message, preferredStyle: .alert)
    
    alert.addAction(UIAlertAction(title: "Close", style: .default, handler: nil))
    
    self.present(alert, animated: true, completion: nil)
  }
  
  func getData(for title: String) {
    guard dataTask == nil else { return }
    
    do {
      activityIndicator.startAnimating()
      
      dataTask = try networkClient.getMovies(title: title) { movies, error in
        guard error == nil else {
          self.activityIndicator.stopAnimating()
          
          self.showAlert(message: String(describing: error!))
          
          return
        }
        
        self.dataTask = nil
        self.viewModels = movies?.map { MovieViewModel(movie: $0) } ?? []
        self.tableView.reloadData()
        self.activityIndicator.stopAnimating()
      }
    } catch {
      activityIndicator.stopAnimating()
      showAlert(message: String(describing: error))
    }
  }
}

// MARK: - UITableViewDataSource
extension MoviesViewController: UITableViewDataSource {
  
  func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
    return viewModels.count
  }
  
  func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
    return movieCell(tableView, indexPath)
  }
  
  private func movieCell(_ tableView: UITableView, _ indexPath: IndexPath) -> UITableViewCell {
    let cell = tableView.dequeueReusableCell(withIdentifier: MovieTableViewCell.identifier) as! MovieTableViewCell
    
    guard viewModels.indices.contains(indexPath.row) else { return cell }
    
    let viewModel = viewModels[indexPath.row]
    viewModel.configure(cell)
    
    if let imageURL = viewModel.imageURL {
      imageClient.setImage(on: cell.movieImageView, fromUrl: imageURL, withPlaceholder: UIImage(named: "imagePlaceholder"))
    }
    
    return cell
  }
}

// MARK: - UITableViewDelegate
extension MoviesViewController: UITableViewDelegate {
  
  func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
    tableView.deselectRow(at: indexPath, animated: true)
  }
}

// MARK: - UISearchBarDelegate
extension MoviesViewController: UISearchBarDelegate {
  
  func searchBarSearchButtonClicked(_ searchBar: UISearchBar) {
    guard let text = searchBar.text else { return }
    
    let searchText = text.trimmingCharacters(in: .whitespacesAndNewlines).lowercased()
    
    if searchText.count >= 3 {
      getData(for: searchText)
    }
  }
}
