//
//  HarvestEntityCreationUITests.swift
//  HarvestUITests
//
//  Created by Letanyan Arumugam on 2018/07/02.
//  Copyright © 2018 University of Pretoria. All rights reserved.
//

// swiftlint:disable line_length

// IMPORTANT run HarvestEntityAuthUITests first

import XCTest

class HarvestEntityCreationUITests: XCTestCase {
        
  override func setUp() {
    super.setUp()
  
    // Put setup code here. This method is called before the invocation of each test method in the class.
  
    // In UI tests it is usually best to stop immediately when a failure occurs.
    continueAfterFailure = false
    // UI tests must launch the application that they test. Doing this in setup will make sure it happens for each test method.
    XCUIApplication().launch()

    // In UI tests it’s important to set the initial state - such as interface orientation - required for your tests before they run. The setUp method is a good place to do this.
  }
  
  override func tearDown() {
    // Put teardown code here. This method is called after the invocation of each test method in the class.
    super.tearDown()
  }
  
  func test1FarmACreation() {
    XCUIDevice.shared.orientation = .portrait
    
    let app = XCUIApplication()
    app.tabBars.buttons["Infomation"].tap()
    XCUIDevice.shared.orientation = .faceUp
    XCUIDevice.shared.orientation = .portrait
    app.collectionViews.cells.otherElements.containing(.image, identifier: "Farms").element.tap()
    app.navigationBars["Farms"].buttons["New"].tap()
    
    let tablesQuery2 = app.tables
    let tablesQuery = tablesQuery2
    tablesQuery/*@START_MENU_TOKEN@*/.textFields["Name of the farm"]/*[[".cells.textFields[\"Name of the farm\"]",".textFields[\"Name of the farm\"]"],[[[-1,1],[-1,0]]],[0]]@END_MENU_TOKEN@*/.tap()
    
    let aKey = app/*@START_MENU_TOKEN@*/.keys["A"]/*[[".keyboards.keys[\"A\"]",".keys[\"A\"]"],[[[-1,1],[-1,0]]],[0]]@END_MENU_TOKEN@*/
    aKey.tap()
    tablesQuery/*@START_MENU_TOKEN@*/.textFields["Name of the company"]/*[[".cells.textFields[\"Name of the company\"]",".textFields[\"Name of the company\"]"],[[[-1,1],[-1,0]]],[0]]@END_MENU_TOKEN@*/.tap()
    aKey.tap()
    
    let app2 = app
    app2/*@START_MENU_TOKEN@*/.keys["d"]/*[[".keyboards.keys[\"d\"]",".keys[\"d\"]"],[[[-1,1],[-1,0]]],[0]]@END_MENU_TOKEN@*/.tap()
    app2/*@START_MENU_TOKEN@*/.keys["a"]/*[[".keyboards.keys[\"a\"]",".keys[\"a\"]"],[[[-1,1],[-1,0]]],[0]]@END_MENU_TOKEN@*/.tap()
    app2/*@START_MENU_TOKEN@*/.keys["m"]/*[[".keyboards.keys[\"m\"]",".keys[\"m\"]"],[[[-1,1],[-1,0]]],[0]]@END_MENU_TOKEN@*/.tap()
    
    let sKey = app2/*@START_MENU_TOKEN@*/.keys["s"]/*[[".keyboards.keys[\"s\"]",".keys[\"s\"]"],[[[-1,1],[-1,0]]],[0]]@END_MENU_TOKEN@*/
    sKey.tap()
    tablesQuery/*@START_MENU_TOKEN@*/.staticTexts["Farm Email"]/*[[".cells.staticTexts[\"Farm Email\"]",".staticTexts[\"Farm Email\"]"],[[[-1,1],[-1,0]]],[0]]@END_MENU_TOKEN@*/.tap()
    tablesQuery2.children(matching: .other)["LOCATION"].children(matching: .other)["LOCATION"].tap()
    app.navigationBars["Harvest.EntityView"].buttons["Save"].tap()
    
    XCTAssertFalse(app.navigationBars["Harvest.EntityView"].buttons["Save"].isEnabled)
  }
  
  func test2OrchardCreation() {
    let app = XCUIApplication()
    app.tabBars.buttons["Infomation"].tap()
    app.collectionViews.cells.otherElements.containing(.image, identifier: "Orchards").element.tap()
    app.navigationBars["Orchards"].buttons["New"].tap()
    
    app.tables/*@START_MENU_TOKEN@*/.textFields["Name of the orchard"]/*[[".cells.textFields[\"Name of the orchard\"]",".textFields[\"Name of the orchard\"]"],[[[-1,1],[-1,0]]],[0]]@END_MENU_TOKEN@*/.tap()
    
    let oKey = app/*@START_MENU_TOKEN@*/.keys["O"]/*[[".keyboards.keys[\"O\"]",".keys[\"O\"]"],[[[-1,1],[-1,0]]],[0]]@END_MENU_TOKEN@*/
    oKey.tap()
    app.navigationBars["Harvest.EntityView"].buttons["Save"].tap()
    
    XCTAssertFalse(app.navigationBars["Harvest.EntityView"].buttons["Save"].isEnabled)
  }
  
  func test3WorkerCreation() {
    XCUIDevice.shared.orientation = .portrait
    XCUIDevice.shared.orientation = .faceUp
    
    let app = XCUIApplication()
    app.tabBars.buttons["Infomation"].tap()
    app.collectionViews.cells.otherElements.containing(.image, identifier: "Workers").element.tap()
    app.navigationBars["Workers"].buttons["New"].tap()
    
    let tablesQuery2 = app.tables
    let tablesQuery = tablesQuery2
    tablesQuery/*@START_MENU_TOKEN@*/.textFields["John"]/*[[".cells.textFields[\"John\"]",".textFields[\"John\"]"],[[[-1,1],[-1,0]]],[0]]@END_MENU_TOKEN@*/.tap()
    
    let app2 = app
    app2/*@START_MENU_TOKEN@*/.keys["A"]/*[[".keyboards.keys[\"A\"]",".keys[\"A\"]"],[[[-1,1],[-1,0]]],[0]]@END_MENU_TOKEN@*/.tap()
    app2/*@START_MENU_TOKEN@*/.keys["d"]/*[[".keyboards.keys[\"d\"]",".keys[\"d\"]"],[[[-1,1],[-1,0]]],[0]]@END_MENU_TOKEN@*/.tap()
    
    let aKey = app2/*@START_MENU_TOKEN@*/.keys["a"]/*[[".keyboards.keys[\"a\"]",".keys[\"a\"]"],[[[-1,1],[-1,0]]],[0]]@END_MENU_TOKEN@*/
    aKey.tap()
    
    let mKey = app2/*@START_MENU_TOKEN@*/.keys["m"]/*[[".keyboards.keys[\"m\"]",".keys[\"m\"]"],[[[-1,1],[-1,0]]],[0]]@END_MENU_TOKEN@*/
    mKey.tap()
    tablesQuery/*@START_MENU_TOKEN@*/.textFields["Appleseed"]/*[[".cells.textFields[\"Appleseed\"]",".textFields[\"Appleseed\"]"],[[[-1,1],[-1,0]]],[0]]@END_MENU_TOKEN@*/.tap()
    app2/*@START_MENU_TOKEN@*/.keys["B"]/*[[".keyboards.keys[\"B\"]",".keys[\"B\"]"],[[[-1,1],[-1,0]]],[0]]@END_MENU_TOKEN@*/.tap()
    aKey.tap()
    app2/*@START_MENU_TOKEN@*/.keys["n"]/*[[".keyboards.keys[\"n\"]",".keys[\"n\"]"],[[[-1,1],[-1,0]]],[0]]@END_MENU_TOKEN@*/.tap()
    aKey.tap()
    app.navigationBars["Harvest.EntityView"].buttons["Save"].tap()
    
    XCTAssertFalse(app.navigationBars["Harvest.EntityView"].buttons["Save"].isEnabled)
  }
}
