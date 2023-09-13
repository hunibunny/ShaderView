//
//  MetalConfigurable.swift
//  
//
//  Created by Pirita Minkkinen on 8/22/23.
//


//make this public :)
import Metal

//This is the main class that deals with Metal-specific logic. It extends the MTKView (a Metal-compatible view) and configures it with the required settings for rendering with Metal.
internal protocol MetalConfigurable {
    var commandQueue: MTLCommandQueue! { get set }
    var renderPipelineState: MTLRenderPipelineState! { get set }
    var outputTexture: MTLTexture! { get set }
    //var startTime: Date? { get set }  //not necessary
    //var elapsedTime: Float { get set }  //not necessary
    var vertexShaderName: String! {get set}
    var fragmentShaderName: String! {get set}
    var viewWidth: Int! {get set}
    var viewHeight: Int! {get set}
    var shouldScaleByDimensions: Bool! {get set}
    //func commonInit() or defaultinit?
    var shaderInput: ShaderInput? {get set}
}

//

    
