//
//  MetalConfigurable.swift
//  
//
//  Created by Pirita Minkkinen on 8/22/23.
//


import Metal

//TODO: is this really necessary

internal protocol ShaderConfigurable {
    var vertexShaderName: String { get set }
    var fragmentShaderName: String { get set }
    var shaderInput: ShaderInput? { get set }
}

internal protocol RenderingConfigurable {
    var renderPipelineState: MTLRenderPipelineState? { get set }
    func render()
}

internal protocol ViewConfigurable {
    var commandQueue: MTLCommandQueue! { get set }
}

// If a class needs all of the functionalities:
internal typealias MetalConfigurable = ShaderConfigurable & RenderingConfigurable & ViewConfigurable


