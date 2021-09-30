//
//  MovieViewModel.swift
//  MovieFinder
//
//  Created by Oleksiy Petlyuk on 24.09.2021.
//

import Foundation

class MovieViewModel {

  let movie: Movie
  let title: String
  let imageURL: URL?

  init(movie: Movie) {
    self.movie = movie
    self.title = movie.title
    self.imageURL = movie.imageURL
  }

  func configure(_ cell: MovieTableViewCell) {
    cell.titleLabel.text = title
  }
}
