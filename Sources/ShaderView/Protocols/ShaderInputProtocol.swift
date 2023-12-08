//
//  ShaderInputProtocol.swift
//  Defines a protocol for shader inputs in Metal-based rendering.
//
//  Created by Pirita Minkkinen on 9/26/23.
//

import Foundation
import Combine

/// `ShaderInputProtocol` outlines the requirements for class types used as inputs in Metal shaders.
/// It establishes a standardized interface for shader inputs, ensuring consistency and ease of use within the rendering pipeline.
///
/// This protocol is designed to be conformed by class types only, as it relies on reference semantics for managing shared shader input states.
/// Conforming classes are expected to provide time-based data to shaders, which is essential for creating dynamic and animated visual effects.
///
/// Conforming classes must implement the `metalData()` method to provide their data in a format compatible with Metal. Additionally, they must provide
/// a mechanism to create a copy of themselves, which is crucial for scenarios where distinct instances with shared initial states are needed.
///
/// - Properties:
///   - time: A `Float` representing time, typically used for animations or time-sensitive calculations in shaders.
/// - Methods:
///   - metalData(): Returns a `Data` object containing the conforming type's properties formatted for use in Metal shaders.
///   - copy(): Creates and returns a copy of the instance, preserving the current state.
public protocol ShaderInputProtocol: AnyObject, ObservableObject{
    associatedtype ShaderInputType: ShaderInputProtocol
    init()
    init(time: Float)
    var time: Float {get set}
    func copy() -> ShaderInputType
    func updateProperties(from input: any ShaderInputProtocol)
    func metalData() -> Data
    func objectWillChangePublisher() -> AnyPublisher<Void, Never>
}

extension ShaderInputProtocol {
    // Provide a default implementation
    public func objectWillChangePublisher() -> AnyPublisher<Void, Never> {
        self.objectWillChange
            .map { _ in () } // Convert to Void
            .eraseToAnyPublisher()
    }
}
