//
//  URLSessionProtocol.swift
//  MovieFinder
//
//  Created by Oleksiy Petlyuk on 29.09.2021.
//

import Foundation

protocol URLSessionProtocol {
  func dataTask(with request: URLRequest, completionHandler: @escaping (Data?, URLResponse?, Error?) -> Void) -> URLSessionDataTaskProtocol
}

extension URLSession: URLSessionProtocol {
  func dataTask(with request: URLRequest, completionHandler: @escaping (Data?, URLResponse?, Error?) -> Void) -> URLSessionDataTaskProtocol {
    let task = dataTask(with: request, completionHandler: completionHandler) as URLSessionDataTask
    
    return task as URLSessionDataTaskProtocol
  }
}
