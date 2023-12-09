//
//  File.swift
//  A class for managing shader inputs in Metal-based rendering.
//
//  Created by Pirita Minkkinen on 8/25/23.
//


import SwiftUI
import Combine


/// `ShaderInput` is a concrete implementation of `ShaderInputProtocol` used for managing shader inputs.
///
/// This class simplifies passing uniform data to Metal shaders, particularly for animations and real-time rendering effects.
/// It holds a `time` variable, a common requirement for shaders that produce time-varying visual effects.
///
/// - Note: Instances of `ShaderInput` are not thread-safe. Modify them on the same thread where they are used, preferably the main thread for UI-related operations.
///
/// - Important: Ensure `ShaderInput` instances are not accessed concurrently from multiple threads to avoid data races.
open class ShaderInput: ShaderInputProtocol {
    public typealias ShaderInputType = ShaderInput
    /// A `Float` that tracks time for shader, typically used for animations or time-based shader effects.
    public var time: Float = 0.0
    public var onChange: (() -> Void)?

    public required init() {
        self.time = 0.0
    }
    
    public required init(time: Float){
        self.time = time;
    }
    
    /// Creates and returns a copy of the current instance.
    /// Useful for creating distinct instances with the same initial state.
    open func copy() -> ShaderInputType {
        return ShaderInput(time: self.time)
    }
    
    open func updateProperties(from input: any ShaderInputProtocol) {
        //no need for time updates for this specific class
    }
    
    /// Prepares and returns a `Data` object that contains the shader input data formatted for Metal.
    /// This method is crucial for bridging Swift data structures to Metal's lower-level data handling.
    open func metalData() -> Data {
        var metalInput = MetalShaderInput(time: self.time)
        return Data(bytes: &metalInput, count: MemoryLayout<MetalShaderInput>.size)
    }
    
    public func objectWillChangePublisher() -> AnyPublisher<Void, Never> {
            objectWillChange
                .map { _ in () } // Convert to Void
                .eraseToAnyPublisher()
        }
}

/// A struct that mirrors the layout of a Metal shader's input structure.
/// This struct is used within `ShaderInput.metalData()` to format Swift data into a form compatible with Metal.
struct MetalShaderInput {
    var time: Float
}
