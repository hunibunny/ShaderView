    //
    //  File.swift
    //
    //
    //  Created by Pirita Minkkinen on 11/19/23.
    //

    import Foundation
    import XCTest
    @testable import ShaderView

    class MetalSwiftUIViewTests: XCTestCase {

       let shaderView = ShaderView()
        let customShaderInput = ShaderInput()
        
        func testShaderViewInit() {
            XCTAssertNotNil(shaderView, "ShaderView should be able to initialize.")
        }
     

    }
