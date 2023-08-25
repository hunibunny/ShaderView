//
//  MetalConfigurable+Default.swift
//  
//
//  Created by Pirita Minkkinen on 8/22/23.
//

import MetalKit



//lays the default methods of an element which can use metal on it, thus laying out how metal is displayed on mtkView

extension MetalConfigurable where Self: MTKView {
    mutating func defaultInit() {
        guard let device = MTLCreateSystemDefaultDevice() else {
            fatalError("Metal is not supported on this device")
        }

        self.device = device
        self.commandQueue = device.makeCommandQueue()
       
        //default
        func commonInit() {
            guard let device = MTLCreateSystemDefaultDevice() else {
                fatalError("Metal is not supported on this device")
            }

            self.device = device
            self.commandQueue = device.makeCommandQueue()

                
            let library = device.makeDefaultLibrary()!
            let vertexFunction = library.makeFunction(name: vertexShaderName) // metal vertex shader
            let fragmentFunction = library.makeFunction(name: fragmentShaderName) // name of metal fragment function
            let pipelineDescriptor = MTLRenderPipelineDescriptor()
            pipelineDescriptor.vertexFunction = vertexFunction
            pipelineDescriptor.fragmentFunction = fragmentFunction
            pipelineDescriptor.colorAttachments[0].pixelFormat = .bgra8Unorm
            do {
                renderPipelineState = try device.makeRenderPipelineState(descriptor: pipelineDescriptor)
            } catch let error {
                fatalError("Failed to create pipeline state, error: \(error)")
            }
            createOutputTexture()
        }

        //default
        func createOutputTexture() {
            let descriptor = MTLTextureDescriptor()
            descriptor.width = viewWidth
            descriptor.height = viewHeight
            descriptor.pixelFormat = .rgba32Float
            descriptor.usage = [.shaderWrite, .shaderRead]

            outputTexture = device.makeTexture(descriptor: descriptor)
        }
        
        func draw(_ rect: CGRect) {
            render()
        }
        
        
        //default square vertices
        let vertices: [Float] = [
            -1.0, -1.0, 0.0, 1.0, // Bottom left corner
             1.0, -1.0, 0.0, 1.0, // Bottom right corner
            -1.0,  1.0, 0.0, 1.0, // Top left corner
             1.0,  1.0, 0.0, 1.0, // Top right corner
        ]
        
        //default render
        func render() {
            guard let drawable = currentDrawable else {
                print("No drawable")
                return
            }

            
            let commandBuffer = commandQueue.makeCommandBuffer()!
            let renderPassDescriptor = self.currentRenderPassDescriptor!
            renderPassDescriptor.colorAttachments[0].texture = drawable.texture
            let renderEncoder = commandBuffer.makeRenderCommandEncoder(descriptor: renderPassDescriptor)!
            renderEncoder.setRenderPipelineState(renderPipelineState)
            
            if startTime == nil {
                startTime = Date()
            } else {
                elapsedTime = Float(Date().timeIntervalSince(startTime!))
            }
        
            //var input = ShaderInput(iTime: elapsedTime, iResolution: SIMD3<Float>(Float(viewWidth), Float(viewHeight), 0))

            var input = ShaderInput(iTime: elapsedTime, iResolution: SIMD3<Float>(Float(drawableSize.width), Float(drawableSize.height), 0))
            let buffer = device.makeBuffer(bytes: &input, length: MemoryLayout<ShaderInput>.size, options: [])
           

            renderEncoder.setFragmentBuffer(buffer, offset: 0, index: 0)
            //passes data to shader
            

            let dataSize = vertices.count * MemoryLayout.size(ofValue: vertices[0])
            let vertexBuffer = device.makeBuffer(bytes: vertices, length: dataSize, options: [])

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
    

       
}

import simd

struct ShaderInput {
    var iTime: Float
    var iResolution: vector_float3
}
//what gets passed to shader
