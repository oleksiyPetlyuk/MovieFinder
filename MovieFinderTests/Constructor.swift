//
//  Constructor.swift
//  MovieFinderTests
//
//  Created by Oleksiy Petlyuk on 28.09.2021.
//

import Foundation
@testable import MovieFinder

class Constructor {
  
  class func getMovieFinderClientWithInvalidApiKeys() -> MovieFinderClient {
    let client = MovieFinderClient(
      baseURL: URL(string: "https://imdb8.p.rapidapi.com/title/find")!,
      session: URLSession.shared,
      responseQueue: nil
    )
    
    client.apiKeys = ("invalidHost", "invalidKey")
    
    return client
  }
  
  class func getMovieFinderClientWithMockedSession() throws -> MovieFinderClient {
    return MovieFinderClient(baseURL: MockSession.mockURL, session: try MockSession(), responseQueue: nil)
  }
}
