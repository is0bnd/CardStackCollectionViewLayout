import XCTest
@testable import CardStackCollectionViewLayout

final class CardStackCollectionViewLayoutTests: XCTestCase {
    
    func testExample() {
        let layout = CardStackCollectionViewLayout()
        let config = CardStackLayoutConfig()
        let state = CardStackLayoutState.collapsed
        assert(true, "They can initialize")
    }

    static var allTests = [
        ("testExample", testExample),
    ]
}
