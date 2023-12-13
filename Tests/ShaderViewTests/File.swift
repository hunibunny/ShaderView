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
        let customShaderInput = ShaderInput(time: 0.0)
        //let representable = MetalNSViewRepresentable(drawableSize: CGSize(width: 100, height: 100), shaderViewModel: shaderViewModel())
        //let metalRender = MetalRenderView<Input: ShaderInput()>(coder: NSCoder())
        
        func testShaderViewInit() {
            XCTAssertNotNil(shaderView, "ShaderView should be able to initialize.")
        }
     

    }
