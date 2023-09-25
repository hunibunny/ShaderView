//
//  MetalConfigurable+Default.swift
//  
//
//  Created by Pirita Minkkinen on 8/22/23.
//

import MetalKit



//lays the default methods of an element which can use metal on it, thus laying out how metal is displayed on mtkView

//provide a way to send new data to shader after launch
//these extension finctions wont ever be used becayse they only work if owner extends mtkview :)
/*
extension MetalConfigurable{
    var vertices: [Float] {
        get { return [//is this the standard layout of vertices for displaying metal :)
            -1.0, -1.0, 0.0, 1.0, // Bottom left corner
            1.0, -1.0, 0.0, 1.0, // Bottom right corner
            -1.0,  1.0, 0.0, 1.0, // Top left corner
            1.0,  1.0, 0.0, 1.0, // Top right corner
            ]
        }
        
    }
}
*/
/*
 extension Identifiable {
     var id: Int {
         get { return identifiableComponent.id }
         set { identifiableComponent.id = newValue }
     }
     var name: String {
         get { return identifiableComponent.name }
         set { identifiableComponent.name = newValue }
     }
 }
 */
/*
 
extension MetalConfigurable where Self: MTKView {
    mutating func defaultInit() {
        //fix this weird layout if functions to something more readable and usdable
        guard let device = MTLCreateSystemDefaultDevice() else {
            fatalError("Metal is not supported on this device")
        }
    
        //self.device = device probably unnecessary
        //self.commandQueue = device.makeCommandQueue() //remove this if will keep the other one in the definiotn of self
        
        //default
        //shoyld this be a function on its own or not?
        guard let device = MTLCreateSystemDefaultDevice() else {
            fatalError("Metal is not supported on this device")
        }
        //self.device = device
        //self.commandQueue = device.makeCommandQueue()
        
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

    mutating func createOutputTexture() {
        let descriptor = MTLTextureDescriptor()
        descriptor.width = viewWidth
        descriptor.height = viewHeight
        descriptor.pixelFormat = .rgba32Float
        descriptor.usage = [.shaderWrite, .shaderRead]
            
        outputTexture = device?.makeTexture(descriptor: descriptor)
    }
    

    //default render
    mutating func render() {
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
        
        let iResolution = SIMD3<Float>(shaderWidth, shaderHeight, 0)
        
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
    
    var vertices: [Float] {
        return [
            -1.0, -1.0, 0.0, 1.0, // Bottom left corner
             1.0, -1.0, 0.0, 1.0, // Bottom right corner
             -1.0,  1.0, 0.0, 1.0, // Top left corner
             1.0,  1.0, 0.0, 1.0, // Top right corner
        ]
    }
}
*/
/*
if startTime == nil {
    startTime = Date()
} else {
    elapsedTime = Float(Date().timeIntervalSince(startTime!))
}

*/



//var input = ShaderInput(iTime: elapsedTime, iResolution: SIMD3<Float>(Float(viewWidth), Float(viewHeight), 0))
//var input = ShaderInput(iTime: elapsedTime, iResolution: iResolution)

//most recent one var input = ShaderInput(iTime: elapsedTime, iResolution: SIMD3<Float>(Float(drawableSize.width), Float(drawableSize.height), 0))


//what gets passed to shader
/*
 possible a way to add default output of a texture without a need for metal, but generated by gpt so might not work lol :)
 extension MetalConfigurable {
     var defaultDevice: MTLDevice? {
         return MTLCreateSystemDefaultDevice()
     }

     var outputTexture: MTLTexture? {
         guard let device = defaultDevice else { return nil }

         let textureDescriptor = MTLTextureDescriptor.texture2DDescriptor(pixelFormat: .bgra8Unorm,
                                                                           width: viewWidth,
                                                                           height: viewHeight,
                                                                           mipmapped: false)
         
         return device.makeTexture(descriptor: textureDescriptor)
     }
 }

 */
