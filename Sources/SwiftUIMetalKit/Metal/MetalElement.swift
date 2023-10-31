//
//  MetalElement.swift
//  
//
//  Created by Pirita Minkkinen on 8/22/23.
//

import MetalKit




public class MetalElement: MTKView, MetalElementProtocol, MTKViewDelegate {
    var vertexShaderName: String?
    var fragmentShaderName: String = "Default name :D (maybe throw error here?)"
    var vertexBuffer: MTLBuffer?
    var shouldScaleByDimensions: Bool = true
    var shaderInput: ShaderInput?
    var commandQueue: MTLCommandQueue!
    var renderPipelineState: MTLRenderPipelineState?
    var outputTexture: MTLTexture?
    var startTime: Date?
    var elapsedTime: Float = 0.0
    var viewSize: CGSize
    var pp: MTLRenderPipelineDescriptor?
    /*
     let vertexDescriptor = MTLVertexDescriptor()
     vertexDescriptor.attributes[0].format = .float4
     vertexDescriptor.attributes[0].offset = 0
     vertexDescriptor.attributes[0].bufferIndex = 0
     // other configurations...
     
     */
    
    struct ViewportSize {
        var size: vector_float2
    }
    
    
    init(fragmentShaderName: String, vertexShaderName: String, viewSize: CGSize) {
        self.fragmentShaderName = fragmentShaderName
        self.vertexShaderName = vertexShaderName
        self.viewSize = viewSize
        guard let device = DeviceManager.shared.device else {
            fatalError("Metal is not supported on this device")
        }
        super.init(frame: .zero, device: device)
        //setupBuffers()
        
        
        print(vertexShaderName, fragmentShaderName)
        //assert(vertexShaderName == "defaultVertexShader")
        //assert(fragmentShaderName == "defaultFragmentShader")
        guard
            let vertexFunction = ShaderLibrary.shared.retrieveShader(forKey: vertexShaderName),
            let fragmentFunction = ShaderLibrary.shared.retrieveShader(forKey: fragmentShaderName)
        else {
            fatalError("Failed to retrieve shaders")
        }
        
        let pipelineDescriptor = MTLRenderPipelineDescriptor()
        pipelineDescriptor.vertexFunction = vertexFunction
        pipelineDescriptor.fragmentFunction = fragmentFunction
        pipelineDescriptor.colorAttachments[0].pixelFormat = .bgra8Unorm
        
        do {
            self.renderPipelineState = try device.makeRenderPipelineState(descriptor: pipelineDescriptor)
        } catch let error {
            fatalError("Failed to create pipeline state, error: \(error)")
            //think if this error message here is good
        }
        
        pp = pipelineDescriptor
        //self.createOutputTexture()
        
    }
    required init(coder: NSCoder) {
        self.viewSize = CGSize(width: 0, height: 0)  // temporary default value
        super.init(coder: coder)
        self.delegate = self
        self.drawableSize = viewSize
        self.isPaused = false         // ensure the MTKView updates
        self.enableSetNeedsDisplay = false   // we will control the rendering loop
        
        //self.drawableSize = viewSize
        //fatalError("init(coder:) has not been implemented")
    }
    
    public func draw(in view: MTKView) {
        self.render()
    }

    //TODO: add needed stuff here
    public func mtkView(_ view: MTKView, drawableSizeWillChange size: CGSize) {
        
    }
    
    
    /*
     func setupBuffers() {
     let dataSize = vertices.count * MemoryLayout.size(ofValue: vertices[0])
     vertexBuffer = DeviceManager.shared.device?.makeBuffer(bytes: vertices, length: dataSize, options: [])
     }*/
    
    func createOutputTexture() {
        //to be deleted
        let descriptor = MTLTextureDescriptor()
        descriptor.pixelFormat = .bgra8Unorm
        descriptor.usage = [.shaderWrite, .shaderRead]
        
        outputTexture = device?.makeTexture(descriptor: descriptor)
    }
    
    func render() {
        guard let drawable = currentDrawable,
              let commandBuffer = DeviceManager.shared.commandQueue?.makeCommandBuffer(),
              let renderPipelineState = self.renderPipelineState else {
            print("Failed to get necessary Metal objects.")
            return
        }
        
        let renderPassDescriptor = MTLRenderPassDescriptor()
        renderPassDescriptor.colorAttachments[0].texture = drawable.texture
        //renderPassDescriptor.colorAttachments[0].clearColor = MTLClearColor(red: 0, green: 0, blue: 0, alpha: 1)
        renderPassDescriptor.colorAttachments[0].clearColor = MTLClearColor(red: 0, green: 1, blue: 0, alpha: 1)  // red color

        renderPassDescriptor.colorAttachments[0].loadAction = .clear
        renderPassDescriptor.colorAttachments[0].storeAction = .store
        
        
        guard let renderEncoder = commandBuffer.makeRenderCommandEncoder(descriptor: renderPassDescriptor) else {
            print("Failed to create Render Command Encoder.")
            return
        }
        /*
        // Create or update viewport size
        var viewportSize = ViewportSize(size: vector_float2(Float(self.drawableSize.width), Float(self.drawableSize.height)))
        let viewportBuffer = device?.makeBuffer(bytes: &viewportSize, length: MemoryLayout<ViewportSize>.size, options: [])
        */
        // Create or update viewport size using drawableSize
        var viewportSize = ViewportSize(size: vector_float2(Float(self.drawableSize.width), Float(self.drawableSize.height)))
        let viewportBuffer = device?.makeBuffer(bytes: &viewportSize, length: MemoryLayout<ViewportSize>.size, options: [])
        
        renderEncoder.setVertexBuffer(vertexBuffer, offset: 0, index: 0)
        renderEncoder.setVertexBuffer(viewportBuffer, offset: 0, index: 1)  // Use the next available index
        renderEncoder.setRenderPipelineState(renderPipelineState)
        
        // Your existing fragment buffer setup
        let buffer = device?.makeBuffer(bytes: &shaderInput, length: MemoryLayout<ShaderInput>.size, options: [])
        renderEncoder.setFragmentBuffer(buffer, offset: 0, index: 0)
        
        renderEncoder.drawPrimitives(type: .triangleStrip, vertexStart: 0, vertexCount: 4)
        renderEncoder.endEncoding()
        
        commandBuffer.present(drawable)
        commandBuffer.commit()
    }
    
    
}


/*
 func render() {
 guard let drawable = currentDrawable else {
 print("No drawable")
 return
 }
 
 let renderPassDescriptor = MTLRenderPassDescriptor()
 renderPassDescriptor.colorAttachments[0].texture = drawable.texture
 renderPassDescriptor.colorAttachments[0].clearColor = MTLClearColor(red: 0, green: 0, blue: 0, alpha: 1)
 renderPassDescriptor.colorAttachments[0].loadAction = .clear
 renderPassDescriptor.colorAttachments[0].storeAction = .store
 
 let commandBuffer = DeviceManager.shared.commandQueue?.makeCommandBuffer()!
 
 let renderEncoder = commandBuffer!.makeRenderCommandEncoder(descriptor: renderPassDescriptor)!
 //! is not justified here imo!!!!
 renderEncoder.setVertexBuffer(vertexBuffer, offset: 0, index: 0)
 renderEncoder.setRenderPipelineState(renderPipelineState!)
 
 
 let buffer = device?.makeBuffer(bytes: &shaderInput, length: MemoryLayout<ShaderInput>.size, options: [])
 renderEncoder.setFragmentBuffer(buffer, offset: 0, index: 0)
 
 
 renderEncoder.drawPrimitives(type: .triangleStrip, vertexStart: 0, vertexCount: 4)
 
 renderEncoder.endEncoding()
 
 commandBuffer!.present(drawable)
 commandBuffer!.commit()
 
 }
 */


