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

    // swiftlint:disable line_length
    let viewController = storyboard.instantiateViewController(withIdentifier: "MoviesViewController") as? MoviesViewController
    // swiftlint:enable line_length
    XCTAssertNotNil(viewController, "Could not create Movies view controller")
  }

  func test_MovieFinderClientReturnsMovies() throws {
    let expectation = expectation(description: "MovieFinderClient returns 10 decoded movies")

    let bundle = Bundle(for: MovieFinderTests.self)
    let dataUrl = try XCTUnwrap(bundle.url(forResource: "movies", withExtension: "json"))
    let data = try Data(contentsOf: dataUrl)

    let session = MockSession(with: data)
    let httpClient = URLSessionHTTPClient(session: session)

    let sut = MovieFinderClient(baseURL: MockSession.mockURL,
                                httpClient: httpClient,
                                secrets: Secrets(),
                                responseQueue: nil)

    sut.getMovies(title: "Harry Potter") { result in
      switch result {
      case .failure(let error):
        XCTFail(String(describing: error))
      case .success(let movies):
        XCTAssertEqual(movies.count, 10)
        expectation.fulfill()
      }
    }

    waitForExpectations(timeout: 0)
  }

  func test_MovieFinderClientReturnsEmptyResultsWhenNothingWasFound() throws {
    let expectation = expectation(description: "MovieFinderClient returns empty results when nothing was found")

    let bundle = Bundle(for: MovieFinderTests.self)
    let dataUrl = try XCTUnwrap(bundle.url(forResource: "movies_not_found", withExtension: "json"))
    let data = try Data(contentsOf: dataUrl)

    let session = MockSession(with: data)
    let httpClient = URLSessionHTTPClient(session: session)

    let sut = MovieFinderClient(baseURL: MockSession.mockURL,
                                httpClient: httpClient,
                                secrets: Secrets(),
                                responseQueue: nil)

    sut.getMovies(title: "Not known movie") { result in
      switch result {
      case .failure(let error):
        XCTFail(String(describing: error))
      case .success(let movies):
        XCTAssertEqual(movies.count, 0)
        expectation.fulfill()
      }
    }

    waitForExpectations(timeout: 0)
  }
}
