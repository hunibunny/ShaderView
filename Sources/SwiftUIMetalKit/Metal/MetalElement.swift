//
//  MetalElement.swift
//  
//
//  Created by Pirita Minkkinen on 8/22/23.
//

import MetalKit
/*
//default MTKView containig MetalElement, shape of square from -1 to 1 on both x and y
#if os(macOS)
public class MetalElement: MTKView, MetalElementProtocol {
    var shaderInput: ShaderInput?
    var viewWidth: Int!
    var viewHeight: Int!
    var commandQueue: MTLCommandQueue!
    var renderPipelineState: MTLRenderPipelineState!
    var outputTexture: MTLTexture!
    var startTime: Date?
    var elapsedTime: Float = 0.0
    var fragmentShaderName: String!
    var vertexShaderName: String!
    var shouldScaleByDimensions: Bool!
    
    public init(fragmentShaderName: String, shouldScaleByDimensions: Bool = true) {
        self.shouldScaleByDimensions = shouldScaleByDimensions
        self.fragmentShaderName = fragmentShaderName
        super.init(frame: .zero, device: nil)
        defaultInit()
    }
    required init(coder: NSCoder) {
        super.init(coder: coder)
        defaultInit()
        //fatalError("init(coder:) has not been implemented")
    }
   
}

*/
public class MetalElement: MTKView, MetalElementProtocol {
    var shouldScaleByDimensions: Bool!
    var shaderInput: ShaderInput?
    var viewWidth: Int!
    var viewHeight: Int!
    var commandQueue: MTLCommandQueue!
    var renderPipelineState: MTLRenderPipelineState?
    var outputTexture: MTLTexture?
    var startTime: Date?
    var elapsedTime: Float = 0.0
    var fragmentShaderName: String!
    var vertexShaderName: String!
    
    public init(fragmentShaderName: String, vertexShaderName: String, shouldScaleByDimensions: Bool = true) {
        self.shouldScaleByDimensions = shouldScaleByDimensions
        self.fragmentShaderName = fragmentShaderName
        self.vertexShaderName = vertexShaderName
        self.viewWidth = 100;
        self.viewHeight = 100;
        super.init(frame: .zero, device: MTLCreateSystemDefaultDevice())//device probably sholdsnt be nil here, that makes no sense :)
        self.commandQueue = device?.makeCommandQueue()//standard practice to call here according to chat gpt
        assert(self.commandQueue != nil, "Failed to create a command queue. Ensure device is properly initialized and available.")
        commonInit()
    }
    required init(coder: NSCoder) {
        super.init(coder: coder)
        commonInit()
        //fatalError("init(coder:) has not been implemented")
    }
    func commonInit(){
        defaultInit()
    }
}
//#endif
