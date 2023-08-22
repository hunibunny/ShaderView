//
// MetalElementTests.swift
//  
//
//  Created by Pirita Minkkinen on 8/22/23.
//

import XCTest
@testable import SwiftUIMetalKit

final class MetalElementTests: XCTestCase {
    
    func testInitialization() {
        let metalElement = MetalElement(frame: .zero)
        metalElement.commonInit()

        XCTAssertNotNil(metalElement.commandQueue, "Command queue should not be nil after initialization.")
        // Add more assertions as needed for other properties
    }

    // Add more test methods as needed
}
