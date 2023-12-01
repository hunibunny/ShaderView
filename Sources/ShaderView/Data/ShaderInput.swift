//
//  File.swift
//  
//
//  Created by Pirita Minkkinen on 8/25/23.
//


import SwiftUI


/// `ShaderInput` - A class to hold shader inputs.
///
/// - Note: This structure is not thread-safe. It should be used and modified
///   from the same thread, preferably the main thread if it interacts with UI components.
///   Avoid accessing or modifying it from multiple threads concurrently.
///
/// Provides a `time` property that can be used to pass time-related data to shaders.
/// Conforms to `ShaderInputProtocol` and provides a static method to create a default instance.
public class ShaderInput: ShaderInputProtocol{
    ///Used to track time for shader
    public var time: Float = 0.0

    public required init() {
        self.time = 0.0
    }
}
