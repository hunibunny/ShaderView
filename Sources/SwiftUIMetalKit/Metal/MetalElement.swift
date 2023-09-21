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
//should the name be smht else
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
        
        //metalinit starts from here
        guard let device = MTLCreateSystemDefaultDevice() else {
            fatalError("Metal is not supported on this device")
        }
      
        
        let library = device.makeDefaultLibrary()!
        let vertexFunction = library.makeFunction(name: vertexShaderName) // metal vertex shader
        let fragmentFunction = library.makeFunction(name: fragmentShaderName) // name of metal fragment function
        let pipelineDescriptor = MTLRenderPipelineDescriptor()
        pipelineDescriptor.vertexFunction = vertexFunction
        pipelineDescriptor.fragmentFunction = fragmentFunction
        pipelineDescriptor.colorAttachments[0].pixelFormat = .bgra8Unorm
        do {
            self.renderPipelineState = try device.makeRenderPipelineState(descriptor: pipelineDescriptor)
        } catch let error {
            fatalError("Failed to create pipeline state, error: \(error)")
        }
        self.createOutputTexture()
    
    }
    required init(coder: NSCoder) {
        super.init(coder: coder)
        
        //fatalError("init(coder:) has not been implemented")
    }
    func createOutputTexture() {
        let descriptor = MTLTextureDescriptor()
        descriptor.width = viewWidth
        descriptor.height = viewHeight
        descriptor.pixelFormat = .rgba32Float
        descriptor.usage = [.shaderWrite, .shaderRead]
            
        outputTexture = device?.makeTexture(descriptor: descriptor)
    }
    
    func render() {
        guard let drawable = currentDrawable else {
        print("No drawable")
        return
        }
            //setting up stuff for scaling
            let aspectRatio = Float(drawableSize.width) / Float(drawableSize.height)
            var shaderWidth: Float = 1.0
            var shaderHeight: Float = 1.0
            
            if shouldScaleByDimensions {
                if aspectRatio > 1 { // landscape or square
                    shaderHeight /= aspectRatio
                } else { // portrait
                    shaderWidth *= aspectRatio
                }
            }
            
            let iResolution = SIMD3<Float>(shaderWidth, shaderHeight, 0)//currently not in use :)
            
            let commandBuffer = commandQueue.makeCommandBuffer()!
            let renderPassDescriptor = self.currentRenderPassDescriptor!
            renderPassDescriptor.colorAttachments[0].texture = drawable.texture
            let renderEncoder = commandBuffer.makeRenderCommandEncoder(descriptor: renderPassDescriptor)!
            renderEncoder.setRenderPipelineState(renderPipelineState!)
            
          
            
            let buffer = device?.makeBuffer(bytes: &shaderInput, length: MemoryLayout<ShaderInput>.size, options: [])
           

            renderEncoder.setFragmentBuffer(buffer, offset: 0, index: 0)
            //passes data to shader
            

            let dataSize = vertices.count * MemoryLayout.size(ofValue: vertices[0])
            let vertexBuffer = device?.makeBuffer(bytes: vertices, length: dataSize, options: [])

            renderEncoder.setVertexBuffer(vertexBuffer, offset: 0, index: 0)

            // Draw first triangle (bottom-left to top-right)
            renderEncoder.drawPrimitives(type: .triangle, vertexStart: 0, vertexCount: 3)

            // Draw second triangle (top-right to bottom-left)
            renderEncoder.drawPrimitives(type: .triangle, vertexStart: 1, vertexCount: 3)

            renderEncoder.endEncoding()

            commandBuffer.present(drawable)
            commandBuffer.commit()
        
    }
}
//#endif
