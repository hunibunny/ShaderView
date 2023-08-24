//
//  MetalElement.swift
//  
//
//  Created by Pirita Minkkinen on 8/22/23.
//

import MetalKit

//default MTKView containig MetalElement, shape of square from -1 to 1 on both x and y
#if os(macOS)
public class MetalElement: MTKView, MetalElementProtocol {
    var viewWidth: Int!
    
    var viewHeight: Int!
    
    
    var vertexShaderName: String!
    
    var fragmentShaderName: String!
    
    func commonInit() {
    
    }
    
    var commandQueue: MTLCommandQueue!
    
    var renderPipelineState: MTLRenderPipelineState!
    
    var outputTexture: MTLTexture!
    
    var startTime: Date?
    
    var elapsedTime: Float = 0.0
    
    
}

#else
public class MetalElement: MTKView, MetalElementProtocol {
    // Your default implementation for iOS.
    func commonInit() {
        defaultInit()
    }
}
#endif
