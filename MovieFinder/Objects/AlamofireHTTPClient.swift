//
//  AlamofireHTTPClient.swift
//  MovieFinder
//
//  Created by Oleksiy Petlyuk on 01.10.2021.
//

import Foundation
import Alamofire

class AlamofireHTTPClient: HTTPClientProtocol {
  func get(_ url: String, query: [String: String]?, headers: [String: String]?, completion: @escaping Handler) {
    let httpHeaders = HTTPHeaders(headers ?? [:])

    AF.request(url, method: .get, parameters: query, headers: httpHeaders)
      .validate(statusCode: 200..<300)
      .validate(contentType: ["application/json"])
      .responseData { response in
        switch response.result {
        case .failure(let error):
          completion(.failure(error))
        case .success(let data):
          completion(.success(data))
        }
      }
  }
}
