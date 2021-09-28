//
//  OptionalObject.swift
//  MovieFinder
//
//  Created by Oleksiy Petlyuk on 28.09.2021.
//

import Foundation

struct OptionalObject<T: Decodable>: Decodable {
  let value: T?
  
  init(from decoder: Decoder) throws {
    do {
      let container = try decoder.singleValueContainer()
      self.value = try container.decode(T.self)
    } catch {
      self.value = nil
    }
  }
}
