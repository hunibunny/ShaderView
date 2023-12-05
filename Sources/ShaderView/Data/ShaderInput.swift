//
//  File.swift
//  A class for managing shader inputs in Metal-based rendering.
//
//  Created by Pirita Minkkinen on 8/25/23.
//


import SwiftUI


/// `ShaderInput`: A class designed to hold and manage inputs for shaders.
///
/// It provides a `time` property to pass time-related data to shaders, which is crucial for animations or time-based effects in rendering.
/// This class conforms to `ShaderInputProtocol` and is intended to be used with `MetalRenderView` for rendering operations.
///
/// - Note: `ShaderInput` is not thread-safe. It should be used and modified from the same thread to prevent data races,
///   preferably the main thread when interacting with UI components. Ensure it is not accessed or modified from multiple threads concurrently.
public class ShaderInput: ShaderInputProtocol {
    public typealias ShaderInputType = ShaderInput
    ///Used to track time for shader
    public var time: Float = 0.0

    public required init() {
        self.time = 0.0
    }
    
    public required init(time: Float){
        self.time = time;
    }
    
    public func copy() -> ShaderInputType {
            return ShaderInput(time: self.time)
    }
}
