//
//  MovieFinderTests.swift
//  MovieFinderTests
//
//  Created by Oleksiy Petlyuk on 23.09.2021.
//

import XCTest
@testable import MovieFinder

final class MovieFinderTests: XCTestCase {
  
  var expectation: XCTestExpectation!
  let timeout: TimeInterval = 3
  
  func test_MoviesListScreen() {
    let storyboard = UIStoryboard(name: "Main", bundle: nil)
    XCTAssertNotNil(storyboard, "Could not create storyboard for Movies List screen")
    
    let viewController = storyboard.instantiateViewController(withIdentifier: "MoviesViewController") as? MoviesViewController
    XCTAssertNotNil(viewController, "Could not create Movies view controller")
  }
  
  func test_invalidApiKeys_throwsClientError() throws {
    let expectation = expectation(description: "Movie service throws a client error when invalid api keys provided")
    
    let client = Constructor.getMovieFinderClientWithInvalidApiKeys()
    
    _ = try client.getMovies(title: "Hulk") { movies, error in
      XCTAssertNil(movies)
      
      switch error as? NetworkError {
      case .clientError:
        expectation.fulfill()
      default:
        XCTFail("Thrown error is not NetworkError.clientError")
      }
    }
    
    waitForExpectations(timeout: timeout)
  }
  
  func test_decodeMovies() {
    let expectation = expectation(description: "JSONDecoder successfully decodes movies from HTTP response")
    let apiKeys = (host: "imdb8.p.rapidapi.com", key: "c2c68d7704mshcde4a8424a2e81ap19db6ajsn042508dbd217")
    
    guard var urlComponents = URLComponents(string: "https://imdb8.p.rapidapi.com/title/find") else {
      XCTFail("Cannot create URLComponents")
      
      return
    }
    
    var queryItems: [URLQueryItem] = []
    
    ["q": "Harry Potter"].forEach { queryItems.append(.init(name: $0.key, value: $0.value)) }
    
    urlComponents.queryItems = queryItems
    
    guard let url = urlComponents.url else {
      XCTFail("Cannot get url from URLComponents")
      
      return
    }
    
    var request = URLRequest(url: url)
    request.httpMethod = "GET"
    request.allHTTPHeaderFields = [
      "x-rapidapi-host": apiKeys.host,
      "x-rapidapi-key": apiKeys.key,
    ]
    
    URLSession.shared.dataTask(with: request) { data, response, error in
      defer { expectation.fulfill() }
      
      XCTAssertNil(error)
      do {
        let response = try XCTUnwrap(response as? HTTPURLResponse)
        XCTAssertEqual(response.statusCode, 200)
        
        let data = try XCTUnwrap(data)
        XCTAssertNoThrow(try JSONDecoder().decode(ServerResponse.self, from: data))
      } catch {}
    }
    .resume()
    
    waitForExpectations(timeout: timeout)
  }
  
  func test_MovieFinderClientReturnsMovies() throws {
    let expectation = expectation(description: "MovieFinderClient returns 10 decoded movies")
    let client = try Constructor.getMovieFinderClientWithMockedSession()
    
    _ = try client.getMovies(title: "Harry Potter") { movies, error in
      defer { expectation.fulfill() }
      
      XCTAssertEqual(movies?.count, 10)
      XCTAssertNil(error)
    }
    
    waitForExpectations(timeout: 0)
  }
}
