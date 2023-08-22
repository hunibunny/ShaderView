//
//  MetalElement.swift
//  
//
//  Created by Pirita Minkkinen on 8/22/23.
//

import MetalKit


#if os(macOS)
class MetalElement: MTKView, MetalElementProtocol {
    func commonInit() {
        
    }
    
    var commandQueue: MTLCommandQueue!
    
    var renderPipelineState: MTLRenderPipelineState!
    
    var outputTexture: MTLTexture!
    
    var startTime: Date?
    
    var elapsedTime: Float = 0.0
    
   
}
#else
class MetalElement: MTKView, MetalElementProtocol {
    // Your default implementation for iOS.
    func commonInit() {
        defaultInit()
    }
}
#endif
