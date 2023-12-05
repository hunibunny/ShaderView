//
//  ShaderInputProtocol.swift
//  Defines a protocol for shader inputs in Metal-based rendering.
//
//  Created by Pirita Minkkinen on 9/26/23.
//

import Foundation


/// `ShaderInputProtocol` outlines the requirements for any type that is used as an input for shaders in `ShaderView`.
/// It ensures that all shader input types have a time property and an initializer.
///
/// - Properties:
///   - time: A `Float` used to pass time-related data to shaders.
public protocol ShaderInputProtocol {
    associatedtype ShaderInputType: ShaderInputProtocol
    var time: Float {get set}
    init()
    init(time: Float)
    func copy() -> ShaderInputType
}

