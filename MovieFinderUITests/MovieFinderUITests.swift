//
//  MovieFinderUITests.swift
//  MovieFinderUITests
//
//  Created by Oleksiy Petlyuk on 23.09.2021.
//

import XCTest

class MovieFinderUITests: XCTestCase {

  var app: XCUIApplication!

  override func setUpWithError() throws {
    app = .init()
    app.launch()

    continueAfterFailure = false
  }

  func test_findMovies() throws {
    let searchField = app.navigationBars["Movies"].searchFields.firstMatch
    let activityIndicator = app.activityIndicators.firstMatch
    let searchText = "Harry Potter and the Sorcerer's Stone"

    XCTAssertFalse(activityIndicator.exists)

    searchField.tap()
    searchField.typeText(searchText)

    app.buttons["Search"].tap()

    XCTAssert(activityIndicator.exists)

    expectation(for: NSPredicate(format: "exists == 0"), evaluatedWith: activityIndicator)

    waitForExpectations(timeout: 10)

    let firstCell = app.staticTexts["Movie.Title"].firstMatch
    XCTAssertEqual(firstCell.label, searchText)
  }
}
