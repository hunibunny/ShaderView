//
//  MetalConfigurable.swift
//  
//
//  Created by Pirita Minkkinen on 8/22/23.
//

import Metal

//This is the main class that deals with Metal-specific logic. It extends the MTKView (a Metal-compatible view) and configures it with the required settings for rendering with Metal.
protocol MetalConfigurable {


    var commandQueue: MTLCommandQueue! { get set }
    var renderPipelineState: MTLRenderPipelineState! { get set }
    var outputTexture: MTLTexture! { get set }
    var startTime: Date? { get set }
    var elapsedTime: Float { get set }
    var vertexShaderName: String! {get set}
    var fragmentShaderName: String! {get set}
    var viewWidth: Int! {get set}
    var viewHeight: Int! {get set}
    var shouldScaleByDimensions: Bool! {get set}
    //func commonInit()

}