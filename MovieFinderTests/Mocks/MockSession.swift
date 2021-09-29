//
//  MockSession.swift
//  MovieFinderTests
//
//  Created by Oleksiy Petlyuk on 29.09.2021.
//

import Foundation
import XCTest
@testable import MovieFinder

class MockSession: URLSessionProtocol {
  static let mockURL = URL(string: "mockURL")!
  
  let data: Data
  
  init() throws {
    let testBundle = Bundle(for: MovieFinderTests.self)
    let url = try XCTUnwrap(testBundle.url(forResource: "movies", withExtension: "json"))
    
    data = try .init(contentsOf: url)
  }
  
  func dataTask(with request: URLRequest, completionHandler: @escaping (Data?, URLResponse?, Error?) -> Void) -> URLSessionDataTaskProtocol {
    completionHandler(data, HTTPURLResponse(url: Self.mockURL, statusCode: 200, httpVersion: nil, headerFields: nil), nil)
    
    return MockDataTask()
  }
}
