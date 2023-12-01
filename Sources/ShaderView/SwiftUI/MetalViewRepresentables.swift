//
//  MetalViewRepresentables.swift
//
//
//  Created by Pirita Minkkinen on 8/22/23.
//

import SwiftUI
import os.log

#if os(macOS)
@available(macOS 11.0, *)  //TODO: consider this requirement
public struct MetalNSViewRepresentable<Input: ShaderInputProtocol>: NSViewRepresentable {
    public typealias NSViewType = MetalElement
    
    let drawableSize: CGSize
    let fragmentShaderName: String
    let vertexShaderName: String
    let shaderInput: Input
    
    
    public init(drawableSize: CGSize, fragmentShaderName: String, vertexShaderName: String, shaderInput: Input) {
        self.drawableSize = drawableSize
        self.fragmentShaderName = fragmentShaderName
        self.vertexShaderName = vertexShaderName
        self.shaderInput = shaderInput
        
    }
    
    public func makeNSView(context: Context) -> NSViewType<Input> {
        let metalElement = MetalElement(fragmentShaderName: fragmentShaderName, vertexShaderName: vertexShaderName, shaderInput: shaderInput)
        //os_log("Drawable size - width: %f, height: %f", log: OSLog.default, type: .info, drawableSize.width, drawableSize.height)
        metalElement.delegate = metalElement
        metalElement.drawableSize = drawableSize
        return metalElement
    }
    
    public func updateNSView(_ nsView: MetalElement<Input>, context: Context) {
        // Update the size of the MetalElement with the latest viewSize
        nsView.frame.size = drawableSize
        nsView.drawableSize = drawableSize
        nsView.needsDisplay = true
    }
    
}
#else
public struct MetalUIViewRepresentable<Input: ShaderInputProtocol>: UIViewRepresentable {
    let drawableSize: CGSize
    let fragmentShaderName: String
    let vertexShaderName: String
    public typealias UIViewType = MetalElement
    let shaderInput: Input
    
    public init(drawableSize: CGSize, fragmentShaderName: String,  vertexShaderName: String,  shaderInput: Input) {
        self.drawableSize = drawableSize
        self.fragmentShaderName = fragmentShaderName
        self.vertexShaderName = vertexShaderName
        self.shaderInput = shaderInput
    }
    
    public func makeUIView(context: Context) -> UIViewType<Input> {
        let metalElement = MetalElement(fragmentShaderName: fragmentShaderName, vertexShaderName: vertexShaderName, shaderInput: shaderInput)
        //os_log("Drawable size - width: %f, height: %f", log: OSLog.default, type: .info, drawableSize.width, drawableSize.height)
        metalElement.delegate = metalElement
        metalElement.drawableSize = drawableSize
        return metalElement
    }
    
    public func updateUIView(_ uiView: MetalElement<Input>, context: Context) {
        uiView.frame.size = drawableSize
        uiView.drawableSize = drawableSize
        uiView.setNeedsDisplay() // This will trigger a redraw
    }
    
}
#endif
