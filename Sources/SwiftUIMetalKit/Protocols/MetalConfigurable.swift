//
//  MetalConfigurable.swift
//  
//
//  Created by Pirita Minkkinen on 8/22/23.
//


//make this public :)
import Metal

//This is the main class that deals with Metal-specific logic. It extends the MTKView (a Metal-compatible view) and configures it with the required settings for rendering with Metal.

//think about splitting this into 2 protocols like gtp recommended, idk if needed or will work tho
//thin if i really need both get and set or just i can have lazy ones instead of get and set
internal protocol ShaderConfigurable {
    var vertexShaderName: String? { get set }
    var fragmentShaderName: String { get set }
    var shaderInput: ShaderInput? { get set }
}

internal protocol RenderingConfigurable {
    var renderPipelineState: MTLRenderPipelineState? { get set }
    var vertices: [Float] { get }
    func render()
}

internal protocol TextureConfigurable {
    var outputTexture: MTLTexture? { get set }
    func createOutputTexture()
}

internal protocol ViewConfigurable {
    var commandQueue: MTLCommandQueue! { get set }
    var viewWidth: Int { get set }
    var viewHeight: Int { get set }
    var shouldScaleByDimensions: Bool { get set }
}

// If a class needs all of the functionalities:
internal typealias MetalConfigurable = ShaderConfigurable & RenderingConfigurable & TextureConfigurable & ViewConfigurable


//
//default square vertices
//func commonInit() or defaultinit?
//var startTime: Date? { get set }  //not necessary
//var elapsedTime: Float { get set }  //not necessary
