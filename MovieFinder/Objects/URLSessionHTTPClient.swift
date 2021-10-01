//
//  HTTPClient.swift
//  MovieFinder
//
//  Created by Oleksiy Petlyuk on 30.09.2021.
//

import Foundation

class URLSessionHTTPClient: HTTPClientProtocol {

  private let session: URLSessionProtocol

  init(session: URLSessionProtocol) {
    self.session = session
  }

  // MARK: - Public Methods
  func get(_ url: String,
           query: [String: String]? = nil,
           headers: [String: String]? = nil,
           completion: @escaping Handler) {
    do {
      let request = try buildRequest(.GET, url, query: query, body: nil, headers: headers)

      makeRequest(request) { result in
        switch result {
        case .failure(let error):
          completion(.failure(error))
        case .success(let data):
          completion(.success(data))
        }
      }
    } catch {
      completion(.failure(error))
    }
  }

  // MARK: - Private Methods
  private func buildRequest(_ method: HTTPMethod,
                            _ url: String,
                            query: [String: String]? = nil,
                            body: Data? = nil,
                            headers: [String: String]? = nil) throws -> URLRequest {

    guard var urlComponents = URLComponents(string: url) else {
      throw NetworkServiceError.invalidUrlRequest
    }

    if query != nil && method == .GET {
      var queryItems: [URLQueryItem] = []

      query!.forEach { queryItems.append(.init(name: $0.key, value: $0.value)) }

      urlComponents.queryItems = queryItems
    }

    guard let finalUrl = urlComponents.url else {
      throw NetworkServiceError.invalidUrlRequest
    }

    var request = URLRequest(url: finalUrl)

    request.httpMethod = method.rawValue

    if body != nil && method != .GET {
      request.httpBody = body!
    }

    if headers != nil {
      headers!.forEach { request.addValue($0.value, forHTTPHeaderField: $0.key) }
    }

    return request
  }

  private func makeRequest(_ request: URLRequest,
                           completion: @escaping (Result<Data, DownloaderError>) -> Void = { _ in }) {
    let task = session.dataTask(with: request) { data, response, error in
      guard let httpResponse = response as? HTTPURLResponse else {
        if let error = error as? URLError {
          completion(.failure(.noResponseError(error: error)))
        } else {
          completion(.failure(.unknownError))
        }

        return
      }

      if 400 <= httpResponse.statusCode && httpResponse.statusCode < 500 {
        completion(.failure(.clientError))
      } else if 500 <= httpResponse.statusCode && httpResponse.statusCode < 600 {
        completion(.failure(.serverError))
      } else if let data = data, !data.isEmpty {
        completion(.success(data))
      } else {
        completion(.failure(.noData))
      }
    }

    task.resume()
  }
}
