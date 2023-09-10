//
//  File.swift
//  
//
//  Created by Pirita Minkkinen on 9/10/23.
//

import Foundation

import XCTest

@testable import SwiftUIMetalKit



class MockMetalObject: MetalConfigurable {
    var commandQueue: MTLCommandQueue!
    
    var renderPipelineState: MTLRenderPipelineState!
    
    var outputTexture: MTLTexture!
    
    var startTime: Date?
    
    var elapsedTime: Float = 0.0
    
    var vertexShaderName: String!
    
    var fragmentShaderName: String!
    
    var viewWidth: Int!
    
    var viewHeight: Int!
    
    var shouldScaleByDimensions: Bool!
    
    
    var wasDefaultInitCalled = false
    var wasCommonInitCalled = false
    var wasCreateOutputTextureCalled = false
    var wasDrawCalled = false
    var wasRenderCalled = false

    func defaultInit() {
        wasDefaultInitCalled = true
    }

    func commonInit() {
        wasCommonInitCalled = true
    }

    func createOutputTexture() {
        wasCreateOutputTextureCalled = true
    }

    func draw(_ rect: CGRect) {
        wasDrawCalled = true
    }

    func render() {
        wasRenderCalled = true
    }
}


class MetalConfigurableTests: XCTestCase {
    
    func testFunctionCalls() {
        let mockMetalObject = MockMetalObject()
        
        // You need to call these methods to check if they were invoked.
        //mockMetalObject.defaultInit()
        //mockMetalObject.commonInit()
        //mockMetalObject.createOutputTexture()
        //mockMetalObject.draw(CGRect.zero)
        //mockMetalObject.render()
        
        // Now add assertions to verify they were indeed called
        XCTAssertTrue(mockMetalObject.wasDefaultInitCalled, "defaultInit() was not called.")
        XCTAssertTrue(mockMetalObject.wasCommonInitCalled, "commonInit() was not called.")
        XCTAssertTrue(mockMetalObject.wasCreateOutputTextureCalled, "createOutputTexture() was not called.")
        XCTAssertTrue(mockMetalObject.wasDrawCalled, "draw(_:) was not called.")
        XCTAssertTrue(mockMetalObject.wasRenderCalled, "render() was not called.")
    }
    
}
