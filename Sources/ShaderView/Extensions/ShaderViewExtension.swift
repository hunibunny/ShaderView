//
//  ShaderViewExtension.swift
//  Provides a convenience initializer for ShaderView with default ShaderInput.
//
//  Created by Pirita Minkkinen on 12/1/23.
//

import Foundation


/// Extension for `ShaderView` to provide a convenience initializer for the default shader input.
extension ShaderView where Input == ShaderInput {
    
    /// Initializes a `ShaderView` with a default instance of `ShaderInput`.
    /// This initializer simplifies the creation of a `ShaderView` when using the default shader input type.
    init() {
        self.init(shaderInput: ShaderInput())
    }
}

// Usage Examples:
// let defaultShaderView = ShaderView() // Initializes with DefaultShaderInput
// let customShaderView = ShaderView<CustomShaderInput>() // Initializes with CustomShaderInput
