//
//  ShaderViewExtension.swift
//  
//
//  Created by Pirita Minkkinen on 12/1/23.
//

import Foundation


@available(macOS 11.0, *)
extension ShaderView where Input == ShaderInput {
    init() {
        self.init(shaderInput: ShaderInput())
    }
}

// Usage
//let defaultShaderView = ShaderView() // Uses DefaultShaderInputType
//let customShaderView = ShaderView<CustomShaderInput>() // Uses CustomShaderInput
