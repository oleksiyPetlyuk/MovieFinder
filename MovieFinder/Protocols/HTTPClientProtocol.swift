//
//  HTTPClientProtocol.swift
//  MovieFinder
//
//  Created by Oleksiy Petlyuk on 30.09.2021.
//

import Foundation

enum HTTPMethod: String {
  case GET
  case POST
  case PUT
  case PATCH
  case DELETE
}

enum NetworkServiceError: Error {
  case invalidUrlRequest
}

enum DownloaderError: Error {
  case noData
  case clientError
  case serverError
  case noResponseError(error: URLError)
  case unknownError
}

protocol HTTPClientProtocol {
  typealias Handler = (Result<Data, Error>) -> Void

  func get(_ url: String,
           query: [String: String]?,
           headers: [String: String]?,
           completion: @escaping Handler)
}
