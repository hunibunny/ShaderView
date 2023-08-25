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
        commonInit()
    }
    required init(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    func commonInit() {
    
    }
}

#else
public class MetalElement: MTKView, MetalElementProtocol {
    var viewWidth: Int!
    var viewHeight: Int!
    var commandQueue: MTLCommandQueue!
    var renderPipelineState: MTLRenderPipelineState!
    var outputTexture: MTLTexture!
    var startTime: Date?
    var elapsedTime: Float = 0.0
    var fragmentShaderName: String!
    var vertexShaderName: String!
    
    public init(fragmentShaderName: String, shouldScaleByDimensions: Bool = true) {
        self.shouldScaleByDimensions = shouldScaleByDimensions
        self.fragmentShaderName = fragmentShaderName
        super.init(frame: .zero, device: nil)
        commonInit()
    }
    required init(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    func commonInit() {
        defaultInit()
    }
}
#endif
