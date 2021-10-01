//
//  MovieFinderClient.swift
//  MovieFinder
//
//  Created by Oleksiy Petlyuk on 24.09.2021.
//

import Foundation

protocol MovieFinderService {
  typealias Handler = (Result<[Movie], Error>) -> Void

  func getMovies(title: String, completion: @escaping Handler)
}

class MovieFinderClient {
  let baseURL: String
  let httpClient: HTTPClientProtocol
  let secrets: Secrets
  let responseQueue: DispatchQueue?

  static let shared = MovieFinderClient(baseURL: "https://imdb8.p.rapidapi.com/title/find",
                                        httpClient: URLSessionHTTPClient(session: URLSession.shared),
                                        secrets: Secrets(),
                                        responseQueue: .main)

  init(baseURL: String, httpClient: HTTPClientProtocol, secrets: Secrets, responseQueue: DispatchQueue?) {
    self.baseURL = baseURL
    self.httpClient = httpClient
    self.secrets = secrets
    self.responseQueue = responseQueue
  }
}

extension MovieFinderClient: MovieFinderService {
  func getMovies(title: String, completion: @escaping Handler) {
    let headers = [
      "x-rapidapi-host": secrets.apiHost,
      "x-rapidapi-key": secrets.apiKey
    ]

    httpClient.get(baseURL, query: ["q": title], headers: headers) { [weak self] result in
      guard let self = self else { return }

      switch result {
      case .failure(let error):
        self.dispatchResult(result: .failure(error), completion: completion)
      case .success(let data):
        do {
          let serverResponse = try JSONDecoder().decode(ServerResponse.self, from: data)

          self.dispatchResult(result: .success(serverResponse.results), completion: completion)
        } catch {
          self.dispatchResult(result: .failure(error), completion: completion)
        }
      }
    }
  }

  private func dispatchResult<T: Decodable, U: Error>(result: Result<T, U>,
                                                      completion: @escaping (Result<T, U>) -> Void) {
    guard let responseQueue = responseQueue else {
      completion(result)

      return
    }

    responseQueue.async {
      completion(result)
    }
  }
}
