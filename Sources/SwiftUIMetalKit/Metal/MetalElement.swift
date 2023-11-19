//
//  MetalElement.swift
//  
//
//  Created by Pirita Minkkinen on 8/22/23.
//

import MetalKit


//TODO: add time management so shaders can track time

public class MetalElement: MTKView, MTKViewDelegate {
    var vertexShaderName: String = ""
    var fragmentShaderName: String = ""
    var vertexBuffer: MTLBuffer?
    var shouldScaleByDimensions: Bool = true
    var shaderInput: ShaderInput
    var commandQueue: MTLCommandQueue!
    var renderPipelineState: MTLRenderPipelineState?
    var startTime: Date = Date()  //consider defining later for more accurate start time rather than creation  time
    var elapsedTime: Float = 0.0

    
    init(fragmentShaderName: String, vertexShaderName: String, shaderInput: ShaderInput?) {
        self.fragmentShaderName = fragmentShaderName
        self.vertexShaderName = vertexShaderName
        self.shaderInput = shaderInput ?? ShaderInput()
        super.init(frame: .zero, device: DeviceManager.shared.device)

        setupMetal()
    }
 
    
    required init(coder: NSCoder) {
        self.shaderInput = ShaderInput()
        super.init(coder: coder)
        self.delegate = self
        self.isPaused = false
        self.enableSetNeedsDisplay = false
        setupMetal()
    }
    
    
    private func setupMetal() {
        // TODO: if adding real time compilation for users these errors might get triggered :)
        guard let device = DeviceManager.shared.device else {
            Logger.error("Metal is not supported on this device")
            fatalError("Metal is not supported on this device")
        }
        
        // Same for this
        guard
            let vertexFunction = ShaderLibrary.shared.retrieveShader(forKey: vertexShaderName),
            let fragmentFunction = ShaderLibrary.shared.retrieveShader(forKey: fragmentShaderName)
        else {
            Logger.error("Metal is not supported on this device")
            fatalError("Failed to retrieve shaders")
        }
        
        // Set up the render pipeline
        let pipelineDescriptor = MTLRenderPipelineDescriptor()
        pipelineDescriptor.vertexFunction = vertexFunction
        pipelineDescriptor.fragmentFunction = fragmentFunction
        pipelineDescriptor.colorAttachments[0].pixelFormat = .bgra8Unorm
        pipelineDescriptor.colorAttachments[0].isBlendingEnabled = false
        
        do {
            self.renderPipelineState = try device.makeRenderPipelineState(descriptor: pipelineDescriptor)
        } catch let error {
            fatalError("Failed to create pipeline state, error: \(error)")
        }
    }

    
    public func draw(in view: MTKView) {
        self.render()
    }

    //TODO: add needed stuff here if any
    public func mtkView(_ view: MTKView, drawableSizeWillChange size: CGSize) {
        
    }
    
    public override var drawableSize: CGSize {
        didSet {
        #if os(macOS)
            needsDisplay = true
        #else
            setNeedsDisplay()
        #endif
            
        }
    }


    func render() {
        guard let drawable = currentDrawable,
              let commandBuffer = DeviceManager.shared.commandQueue?.makeCommandBuffer(),
              let renderPipelineState = self.renderPipelineState else {
            Logger.error("Failed to get necessary Metal objects for rendering")
            return
        }
        
    
        
        let currentTime = Date()
        self.elapsedTime = Float(currentTime.timeIntervalSince(startTime))
        

        // Update shader input
        shaderInput.time = elapsedTime
        
        
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
        
        
        

        var viewport = Viewport(size: vector_float2(Float(self.drawableSize.width), Float(self.drawableSize.height)))
        
        //TODO: consider adding debug message for size or other stuff
        
        let viewportBuffer = device?.makeBuffer(bytes: &viewport, length: MemoryLayout<Viewport>.size, options: [])
    
        
        //first buffer viewportbuffer second other stuff like variables
        renderEncoder.setVertexBuffer(viewportBuffer, offset: 0, index: 0)  // Use the next available index
        renderEncoder.setRenderPipelineState(renderPipelineState)
        
        
        //TODO: decide on the size, possibly make smaller
        let bufferSize = 4 * 1024 // 4KB in bytes should be more than enough for any 2d shader use, consider reducing
        let buffer = device?.makeBuffer(bytes: &shaderInput, length:  bufferSize, options: [])
        renderEncoder.setFragmentBuffer(viewportBuffer, offset: 0, index: 0)
        renderEncoder.setFragmentBuffer(buffer, offset: 0, index: 1)
        
        renderEncoder.drawPrimitives(type: .triangleStrip, vertexStart: 0, vertexCount: 4)
        renderEncoder.endEncoding()
        
        commandBuffer.present(drawable)
        commandBuffer.commit()
    }
    
    
}


