//
//  MovieFinderClient.swift
//  MovieFinder
//
//  Created by Oleksiy Petlyuk on 24.09.2021.
//

import Foundation

enum NetworkError: Error {
  case noData
  case clientError
  case serverError
  case noResponseError(error: URLError)
  case invalidRequestUrl
  case unknownError
}

protocol MovieFinderService {
  func getMovies(title: String, completion: @escaping ([Movie]?, Error?) -> Void) throws -> URLSessionDataTask
}

class MovieFinderClient {
  
  let baseURL: URL
  let session: URLSession
  let responseQueue: DispatchQueue?
  
  static let shared = MovieFinderClient(baseURL: URL(string: "https://imdb8.p.rapidapi.com/title/find")!, session: .shared, responseQueue: .main)
  
  init(baseURL: URL, session: URLSession, responseQueue: DispatchQueue?) {
    self.baseURL = baseURL
    self.session = session
    self.responseQueue = responseQueue
  }
}

extension MovieFinderClient: MovieFinderService {
  func getMovies(title: String, completion: @escaping ([Movie]?, Error?) -> Void) throws -> URLSessionDataTask {
    guard var urlComponents = URLComponents(url: baseURL, resolvingAgainstBaseURL: true) else {
      throw NetworkError.invalidRequestUrl
    }
    
    var queryItems: [URLQueryItem] = []
    
    ["q": title].forEach { queryItems.append(.init(name: $0.key, value: $0.value)) }
    
    urlComponents.queryItems = queryItems
    
    guard let url = urlComponents.url else {
      throw NetworkError.invalidRequestUrl
    }
    
    var request = URLRequest(url: url)
    request.httpMethod = "GET"
    request.allHTTPHeaderFields = [
      "x-rapidapi-host": "imdb8.p.rapidapi.com",
      "x-rapidapi-key": "c2c68d7704mshcde4a8424a2e81ap19db6ajsn042508dbd217"
    ]
    
    let task = session.dataTask(with: request) { [weak self] data, response, error in
      guard let self = self else { return }
      
      guard let httpResponse = response as? HTTPURLResponse else {
        if let error = error as? URLError {
          self.dispatchResult(error: NetworkError.noResponseError(error: error), completion: completion)
        } else {
          self.dispatchResult(error: NetworkError.unknownError, completion: completion)
        }
        
        return
      }
      
      if httpResponse.statusCode >= 400 && httpResponse.statusCode < 500 {
        self.dispatchResult(error: NetworkError.clientError, completion: completion)
      } else if httpResponse.statusCode >= 500 && httpResponse.statusCode < 600 {
        self.dispatchResult(error: NetworkError.serverError, completion: completion)
      } else if let data = data, !data.isEmpty {
        let decoder = JSONDecoder()
        do {
          let serverResponse = try decoder.decode(ServerResponse.self, from: data)
          
          self.dispatchResult(models: serverResponse.results, completion: completion)
        } catch {
          self.dispatchResult(error: error, completion: completion)
        }
      } else {
        self.dispatchResult(error: NetworkError.noData, completion: completion)
      }
    }
    
    task.resume()
    
    return task
  }
  
  private func dispatchResult<T, U: Error>(models: T? = nil, error: U? = nil, completion: @escaping (T?, U?) -> Void) {
    guard let responseQueue = responseQueue else {
      completion(models, error)
      
      return
    }
    
    responseQueue.async {
      completion(models, error)
    }
  }
}
