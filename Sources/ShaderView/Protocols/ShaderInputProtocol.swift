//
//  ShaderInputable.swift
//  Defines a protocol for shader inputs fir ShaderViews.
//
//  Created by Pirita Minkkinen on 9/26/23.
//

import Foundation
import Combine

/// Protocol `ShaderInputable` defines requirements for classes that provide input data to Metal shaders.
/// Required Implementations:
/// - `metalData()`: Converts the instance's properties into a `Data` object formatted for Metal shaders.
/// - `updateProperties(from:)`: Updates the instance's properties, should be done without creating new class instance for best performance.
///
/// Properties:
/// - `time`: A `Float` indicating the current time, managed automatically by the package. Can leave as is if only default behavior wanted.
/// - `onChange`: An optional closure triggered when the shader input's properties change, enabling reactive updates. 
///
public protocol ShaderInputable: AnyObject, ObservableObject{
    init(time: Float)
    
    /// - Note: The `time` property is automatically managed by the package, incrementing each frame to facilitate time-based shader effects. Users do not need to manually track or update 'time' unless custom time behaviors are desired.
    var time: Float {get set}
    
    var onChange: (() -> Void)? { get set }
    func updateProperties(from input: any ShaderInputable)
    func metalData() -> Data
}

