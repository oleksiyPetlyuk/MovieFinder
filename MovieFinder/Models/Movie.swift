//
//  Movie.swift
//  MovieFinder
//
//  Created by Oleksiy Petlyuk on 24.09.2021.
//

import Foundation

// MARK: - ServerResponse
struct ServerResponse: Decodable {
  let results: [Movie]

  enum CodingKeys: CodingKey {
    case results
  }

  init(from decoder: Decoder) throws {
    let container = try decoder.container(keyedBy: CodingKeys.self)

    if container.contains(.results) {
      let nullableMovies = try container.decode([OptionalObject<Movie>].self, forKey: .results)
      self.results = nullableMovies.compactMap { $0.value }
    } else {
      self.results = []
    }
  }
}

// MARK: - Movie
struct Movie {
  // swiftlint:disable identifier_name
  let id: String
  let title: String
  let imageURL: URL?

  enum CodingKeys: CodingKey {
    case id, title, image
  }
  // swiftlint:enable identifier_name

  enum ImageKeys: CodingKey {
    case url
  }
}

extension Movie: Decodable {
  init(from decoder: Decoder) throws {
    let container = try decoder.container(keyedBy: CodingKeys.self)
    id = try container.decode(String.self, forKey: .id)
    title = try container.decode(String.self, forKey: .title)

    if container.contains(.image) {
      let imageContainer = try container.nestedContainer(keyedBy: ImageKeys.self, forKey: .image)
      imageURL = try imageContainer.decode(URL.self, forKey: .url)
    } else {
      imageURL = nil
    }
  }
}
