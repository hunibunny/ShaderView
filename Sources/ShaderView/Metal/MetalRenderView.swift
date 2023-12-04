//
//  MetalRenderView.swift
//A view for rendering graphics using Metal's shader and rendering capabilities.
//
//  Created by Pirita Minkkinen on 8/22/23.
//

import MetalKit


/// `MetalRenderView` is a subclass of `MTKView` and conforms to `MTKViewDelegate`.
/// It is designed to integrate Metal's rendering capabilities into a SwiftUI environment.
///
/// - Note: This class is intended for use as part of the package and may not be suitable for standalone use.
///         It relies on other components in the package for full functionality.
public class MetalRenderView: MTKView, MTKViewDelegate {
    private var vertexShaderName: String = "" //think of making these let
    private var fragmentShaderName: String = ""
    private var vertexBuffer: MTLBuffer?
    private var shaderInput: Any
    var renderPipelineState: MTLRenderPipelineState?
    var startTime: Date = Date()  //consider defining later for more accurate start time rather than creation  time
    var elapsedTime: Float = 0.0

    /// Initializes a `MetalRenderView` with specified shaders and input.
       /// - Parameters:
       ///   - fragmentShaderName: The name of the fragment shader to use.
       ///   - vertexShaderName: The name of the vertex shader to use.
       ///   - shaderInput: The input data for the shader.
    init(fragmentShaderName: String, vertexShaderName: String, shaderInput: Any) {
        self.fragmentShaderName = fragmentShaderName
        self.vertexShaderName = vertexShaderName
        self.shaderInput = shaderInput
        super.init(frame: .zero, device: DeviceManager.shared.device)

        print(self.shaderInput.self)
        setupMetal()
    }
 
    /// Required initializer for decoding. Not intended for direct use.
    required init(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
        /*
        self.shaderInput = ShaderInput() as! Input
        super.init(coder: coder)
        self.delegate = self
        self.isPaused = false
        self.enableSetNeedsDisplay = false
        setupMetal()*/
    }
    
    /// Sets up the Metal environment, including the render pipeline state.
    private func setupMetal() {
        // TODO: if adding real time compilation for users these errors might get triggered
        guard let device = DeviceManager.shared.device else {
            ShaderViewLogger.error("Metal is not supported on this device")
            fatalError("Metal is not supported on this device")
        }
        
        // Same for this
        guard
            let vertexFunction = ShaderLibrary.shared.retrieveShader(forKey: vertexShaderName),
            let fragmentFunction = ShaderLibrary.shared.retrieveShader(forKey: fragmentShaderName)
        else {
            ShaderViewLogger.error("Metal is not supported on this device")
            fatalError("Failed to retrieve shaders")
        }
        
        // Set up the render pipeline, currently same for every shader but maybe consider making it changeable
        setupRenderPipeline(device: device, vertexFunction: vertexFunction, fragmentFunction: fragmentFunction)
    }
    
    
    /// Configures the render pipeline with the specified vertex and fragment shaders.
    private func setupRenderPipeline(device: MTLDevice, vertexFunction: MTLFunction, fragmentFunction: MTLFunction){
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

    
    /// Renders content for each frame.
    /// - Parameter view: The `MTKView` responsible for displaying the content.
    public func draw(in view: MTKView) {
        self.render()
    }

    
    /// Responds to changes in the view's drawable size.
    public func mtkView(_ view: MTKView, drawableSizeWillChange size: CGSize) {
        
    }
    
    /// Overrides `drawableSize` to trigger a redraw correctly on both macOS and iOS.
    public override var drawableSize: CGSize {
        didSet {
        #if os(macOS)
            needsDisplay = true
        #else
            setNeedsDisplay()
        #endif
            
        }
    }

    /// Executes the rendering process for the current frame.
    private func render() {
        guard let drawable = currentDrawable,
              let commandBuffer = DeviceManager.shared.commandQueue?.makeCommandBuffer(),
              let renderPipelineState = self.renderPipelineState else {
            ShaderViewLogger.error("Failed to get necessary Metal objects for rendering")
            return
        }
        
        let currentTime = Date()
        self.elapsedTime = Float(currentTime.timeIntervalSince(startTime))
        

        // Update shader inputs time
        if var timeUpdating = shaderInput as? ShaderInputProtocol {
            timeUpdating.time = elapsedTime
            // If shaderInput is a class instance, this updates the original shaderInput's time.
            // If shaderInput is a struct, this only updates timeUpdating's time.
        }
        else{
            print(shaderInput.self)
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
        
        
        

        var viewport = Viewport(size: vector_float2(Float(self.drawableSize.width), Float(self.drawableSize.height)))
        
       
        
        let viewportBuffer = device?.makeBuffer(bytes: &viewport, length: MemoryLayout<Viewport>.size, options: [])
    
        
        //first buffer viewportbuffer second other stuff like variables
        renderEncoder.setVertexBuffer(viewportBuffer, offset: 0, index: 0)  // Use the next available index
        renderEncoder.setRenderPipelineState(renderPipelineState)
        
        
        //TODO: decide on the size, possibly make smaller
        let bufferSize = 3 * 1024 // 4KB in bytes should be more than enough for any 2d shader use, consider reducing
        let buffer = device?.makeBuffer(bytes: &shaderInput, length:  bufferSize, options: [])
        renderEncoder.setFragmentBuffer(viewportBuffer, offset: 0, index: 0)
        renderEncoder.setFragmentBuffer(buffer, offset: 0, index: 1)
        
        renderEncoder.drawPrimitives(type: .triangleStrip, vertexStart: 0, vertexCount: 4)
        renderEncoder.endEncoding()
        
        commandBuffer.present(drawable)
        commandBuffer.commit()
    }
    
    
}


