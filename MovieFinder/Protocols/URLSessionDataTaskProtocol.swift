//
//  URLSessionDataTaskProtocol.swift
//  MovieFinder
//
//  Created by Oleksiy Petlyuk on 29.09.2021.
//

import Foundation

protocol URLSessionDataTaskProtocol {
  func resume()
}

extension URLSessionDataTask: URLSessionDataTaskProtocol {}
