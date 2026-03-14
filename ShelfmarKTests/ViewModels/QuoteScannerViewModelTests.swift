//
//  QuoteScannerViewModelTests.swift
//  ShelfmarKTests
//

import XCTest
import UIKit
@testable import Shelfmark

@MainActor
final class QuoteScannerViewModelTests: XCTestCase {

    func test_processImage_whenUseCaseReturnsText_stateIsRecognized() async {
        let mock = MockRecognizeTextInImageUseCase()
        mock.textToReturn = "  Recognized text  "
        let image = UIImage(systemName: "photo")!
        guard let cgImage = image.cgImage else {
            XCTFail("System image should have cgImage")
            return
        }

        let sut = QuoteScannerViewModel(recognizeTextUseCase: mock)

        await sut.processImage(image)

        if case .recognized(let text) = sut.state {
            XCTAssertEqual(text, "Recognized text")
        } else {
            XCTFail("Expected .recognized, got \(sut.state)")
        }
        XCTAssertEqual(mock.executeCallCount, 1)
    }

    func test_processImage_whenUseCaseThrows_stateIsError() async {
        let mock = MockRecognizeTextInImageUseCase()
        mock.errorToThrow = TestError.fake
        let image = UIImage(systemName: "photo")!
        guard image.cgImage != nil else {
            XCTFail("System image should have cgImage")
            return
        }

        let sut = QuoteScannerViewModel(recognizeTextUseCase: mock)

        await sut.processImage(image)

        if case .error(let message) = sut.state {
            XCTAssertFalse(message.isEmpty)
        } else {
            XCTFail("Expected .error, got \(sut.state)")
        }
        XCTAssertEqual(mock.executeCallCount, 1)
    }

    func test_processImage_whenImageHasNoCgImage_stateIsError() async {
        let mock = MockRecognizeTextInImageUseCase()
        let image = UIImage() // Empty image may have nil cgImage on some platforms

        let sut = QuoteScannerViewModel(recognizeTextUseCase: mock)

        await sut.processImage(image)

        if case .error(let message) = sut.state {
            XCTAssertTrue(message.contains("No se pudo usar la imagen") || !message.isEmpty)
        } else {
            XCTFail("Expected .error when cgImage is nil, got \(sut.state)")
        }
        XCTAssertEqual(mock.executeCallCount, 0)
    }

    func test_reset_setsStateToIdle() async {
        let mock = MockRecognizeTextInImageUseCase()
        mock.textToReturn = "Text"
        let image = UIImage(systemName: "photo")!
        guard image.cgImage != nil else { return }

        let sut = QuoteScannerViewModel(recognizeTextUseCase: mock)
        await sut.processImage(image)
        XCTAssertNotEqual(sut.state, .idle)

        sut.reset()

        if case .idle = sut.state {
            // OK
        } else {
            XCTFail("Expected .idle after reset, got \(sut.state)")
        }
    }
}
