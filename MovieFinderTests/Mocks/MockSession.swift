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
  static let mockURL = "mockURL"

  private let data: Data

  init(with data: Data) {
    self.data = data
  }

  func dataTask(with request: URLRequest,
                completionHandler: @escaping (Data?, URLResponse?, Error?) -> Void) -> URLSessionDataTaskProtocol {
    let url = URL(string: Self.mockURL)!

    completionHandler(data, HTTPURLResponse(url: url, statusCode: 200, httpVersion: nil, headerFields: nil), nil)

    return MockDataTask()
  }
}
