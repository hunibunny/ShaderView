//
//  MetalElement.swift
//  
//
//  Created by Pirita Minkkinen on 8/22/23.
//

import MetalKit


public class MetalElement: MTKView, MetalElementProtocol {
    var vertexShaderName: String?
    var fragmentShaderName: String = "Default name :D (maybe throw error here?)"
    var viewWidth: Int = 100
    var viewHeight: Int = 100
    var vertexBuffer: MTLBuffer?
    var shouldScaleByDimensions: Bool = true
    var shaderInput: ShaderInput?
    var commandQueue: MTLCommandQueue!
    var renderPipelineState: MTLRenderPipelineState?
    var outputTexture: MTLTexture?
    var startTime: Date?
    var elapsedTime: Float = 0.0

    /*
     let vertexDescriptor = MTLVertexDescriptor()
     vertexDescriptor.attributes[0].format = .float4
     vertexDescriptor.attributes[0].offset = 0
     vertexDescriptor.attributes[0].bufferIndex = 0
     // other configurations...

     */
    
    init(fragmentShaderName: String, vertexShaderName: String, shouldScaleByDimensions: Bool = true) {
        self.shouldScaleByDimensions = shouldScaleByDimensions
        self.fragmentShaderName = fragmentShaderName
        self.vertexShaderName = vertexShaderName
        self.viewWidth = 100;
        self.viewHeight = 100;
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
        self.createOutputTexture()
    
    }
    required init(coder: NSCoder) {
        super.init(coder: coder)
        //fatalError("init(coder:) has not been implemented")
    }
    
    /*
    func setupBuffers() {
        let dataSize = vertices.count * MemoryLayout.size(ofValue: vertices[0])
        vertexBuffer = DeviceManager.shared.device?.makeBuffer(bytes: vertices, length: dataSize, options: [])
    }*/
    
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
            
            //let iResolution = SIMD3<Float>(shaderWidth, shaderHeight, 0)//currently not in use :)
            // i wonder where i wanted to put this one :D
            //let commandBuffer = commandQueue.makeCommandBuffer()!
        
        
        let commandBuffer = DeviceManager.shared.commandQueue?.makeCommandBuffer()!
        let renderPassDescriptor = self.currentRenderPassDescriptor!
        renderPassDescriptor.colorAttachments[0].texture = drawable.texture
        let renderEncoder = commandBuffer!.makeRenderCommandEncoder(descriptor: renderPassDescriptor)!
        //! is not justified here imo!!!!
        renderEncoder.setVertexBuffer(vertexBuffer, offset: 0, index: 0)
        renderEncoder.setRenderPipelineState(renderPipelineState!)
        
        
        let buffer = device?.makeBuffer(bytes: &shaderInput, length: MemoryLayout<ShaderInput>.size, options: [])
        renderEncoder.setFragmentBuffer(buffer, offset: 0, index: 0)
            //passes data to shader
            

        //let dataSize = vertices.count * MemoryLayout.size(ofValue: vertices[0])
        //let vertexBuffer = device?.makeBuffer(bytes: vertices, length: dataSize, options: [])
        //renderEncoder.setVertexBuffer(vertexBuffer, offset: 0, index: 0)
        
            // Draw first triangle (bottom-left to top-right)
        //renderEncoder.drawPrimitives(type: .triangle, vertexStart: 0, vertexCount: 3)

            // Draw second triangle (top-right to bottom-left)
        //renderEncoder.drawPrimitives(type: .triangle, vertexStart: 1, vertexCount: 3)
        
        renderEncoder.drawPrimitives(type: .triangleStrip, vertexStart: 0, vertexCount: 4)

        renderEncoder.endEncoding()

        //!!!!!!
        commandBuffer!.present(drawable)
        commandBuffer!.commit()
        
    }
}


