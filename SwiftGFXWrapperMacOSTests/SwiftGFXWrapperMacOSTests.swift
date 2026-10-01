@testable import SwiftGFXWrapperMacOS
import XCTest

class SwiftGFXWrapperMacOSTests: XCTestCase {
    func testOwnedSnapshotAndInvalidation() {
        let matrix = GFXMatrix(rows: 2, cols: 3)
        let initial = matrix.rgbaFrame() as NSData
        XCTAssertEqual(Array(initial as Data), Array(repeating: [UInt8(0), 0, 0, 255], count: 6).flatMap { $0 })
        XCTAssertTrue(initial === (matrix.rgbaFrame() as NSData))

        matrix.drawPixel(1, y: 0, color: 0xF800)
        let changed = matrix.rgbaFrame() as NSData
        XCTAssertFalse(initial === changed)
        XCTAssertEqual(Array(changed as Data)[4 ..< 8], [255, 0, 0, 255])
        XCTAssertEqual(Array(initial as Data)[4 ..< 8], [0, 0, 0, 255])

        let revision = matrix.frameRevision()
        matrix.drawPixel(1, y: 0, color: 0xF800)
        XCTAssertEqual(matrix.frameRevision(), revision)
        XCTAssertTrue(changed === (matrix.rgbaFrame() as NSData))

        matrix.setRotation(1)
        XCTAssertEqual(matrix.width(), 2)
        XCTAssertEqual(matrix.height(), 3)
        XCTAssertNotEqual(matrix.frameRevision(), revision)
        XCTAssertEqual(matrix.getPixel(0, y: 1), 0xF800)
        XCTAssertEqual(Array(matrix.rgbaFrame() as Data)[8 ..< 12], [255, 0, 0, 255])
    }

    func testCallbacksCanBeEnabledAndCleared() {
        let matrix = GFXMatrix(rows: 2, cols: 3)
        var writes = [(Int, Int, Int)]()
        matrix.setDrawCallback { writes.append(($0, $1, $2)) }
        matrix.drawPixel(1, y: 1, color: 0x07E0)
        matrix.drawPixel(1, y: 1, color: 0x07E0)
        XCTAssertEqual(writes.count, 1)
        XCTAssertEqual(writes[0].0, 1)
        XCTAssertEqual(writes[0].1, 1)
        XCTAssertEqual(writes[0].2, 0x07E0)
        matrix.setDrawCallback(nil)
        matrix.fillScreen(0x001F)
        XCTAssertEqual(writes.count, 1)
        XCTAssertEqual(matrix.getPixel(1, y: 1), 0x001F)
        matrix.setDrawCallback { writes.append(($0, $1, $2)) }
        matrix.fillScreen(0)
        XCTAssertEqual(writes.count, 7)
    }
}
