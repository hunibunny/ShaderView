//
//  File.swift
//  A class for managing shader inputs for ShaderViews.
//
//  Created by Pirita Minkkinen on 8/25/23.
//


import SwiftUI
import Combine


/// `ShaderInput` is a default class implementing `ShaderInputProtocol` for managing data passed to shaders.
/// Properties:
/// - `time`: Tracks time for shaders.
/// - `onChange`: An optional closure that can be set to react to changes in the shader input's properties. Currently not used.
///
/// - Note: This class does not support thread-safe modifications. Synchronize access if used across multiple threads.

open class ShaderInput: ShaderInputProtocol {
    /// - Note: The `time` property is automatically managed by the package, incrementing each frame to facilitate time-based shader effects. Users do not need to manually track or update 'time' unless custom time behaviors are desired.
    public var time: Float = 0.0
    public var onChange: (() -> Void)?

    /// Initializes a new `ShaderInput` instance with the specified time.
    /// - Parameter time: The initial time value.
    public required init(time: Float){
        self.time = time;
    }
    
    /// Updates the properties of this instance based on another `ShaderInputProtocol` instance.
    /// For `ShaderInput`, this method currently has no implementation as time updates are not required.
    open func updateProperties(from input: any ShaderInputProtocol) {
        //no need for time updates for this specific class
    }
    
    /// Prepares and returns a `Data` object that contains the shader input data formatted for Metal.
    /// This method is crucial for bridging Swift data structures to Metal's lower-level data handling.
    open func metalData() -> Data {
        var metalInput = MetalShaderInput(time: self.time)
        return Data(bytes: &metalInput, count: MemoryLayout<MetalShaderInput>.size)
    }

}

/// Struct representing the data structure required by Metal shaders.
/// This struct is used by `ShaderInput` to format its data into a form that Metal can use efficiently.
///
/// Contains:
/// - `time`: A `Float` representing time or frame count, corresponding to the `time` property in `ShaderInput`.
struct MetalShaderInput {
    var time: Float
}
