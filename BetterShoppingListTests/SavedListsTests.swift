//
//  SavedListsTest.swift
//  BetterShoppingListTests
//
//  Created by Xavi Aracil on 4/4/22.
//

import XCTest
import CoreData
@testable import BetterShoppingList

class SavedListsTests: XCTestCase {

    var context: NSManagedObjectContext!
    var shoppingAssistant: ShoppingAssistant!

    override func setUpWithError() throws {
        // Put setup code here. This method is called before the invocation of each test method in the class.
        let container = PersistenceController(inMemory: true, withTestData: false).container
        context = container.viewContext
        try loadFixture(into: context)
        let persistenceAdapter = CoreDataPersistenceAdapter(viewContext: context,
                                                            coordinator: container.persistentStoreCoordinator)
        shoppingAssistant = ShoppingAssistant(persistenceAdapter: persistenceAdapter)
    }

    override func tearDownWithError() throws {
        // Put teardown code here. This method is called after the invocation of each test method in the class.
        try destroyFixture(from: context)
    }

    func testEmpty() throws {
        // given initial state

        // when asking for saved lists
        let lists = try context.fetch(shoppingAssistant.savedListsFetchRequest)

        // then we get an empty list
        XCTAssertNotNil(lists)
        XCTAssertTrue(lists.isEmpty)
    }

    func testGivenListsFetchReturnOnlyCompletedLists() throws {
        // given some lists
        _ = mockList(name: "Current List", current: true, context: context)
        let list2 = mockList(name: "Another List", current: false, context: context)
        try context.save()

        // when asking for saved lists
        let lists = try context.fetch(shoppingAssistant.savedListsFetchRequest)

        // then we get a list
        XCTAssertNotNil(lists)
        // with the completed lists only
        XCTAssertEqual(1, lists.count)
        XCTAssertEqual(list2.name, lists.first?.name)
        XCTAssertEqual(list2.isCurrent, lists.first?.isCurrent)
    }

}
