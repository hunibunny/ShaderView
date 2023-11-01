//
//  MetalViewRepresentables.swift
//
//
//  Created by Pirita Minkkinen on 8/22/23.
//

import SwiftUI

#if os(macOS)
@available(macOS 11.0, *)
public struct MetalNSViewRepresentable: NSViewRepresentable {
    public typealias NSViewType = MetalElement
    
    let drawableSize: CGSize
    let fragmentShaderName: String
    let vertexShaderName: String

    
    
    public init(drawableSize: CGSize, fragmentShaderName: String, vertexShaderName: String) {
        self.drawableSize = drawableSize
        self.fragmentShaderName = fragmentShaderName
        self.vertexShaderName = vertexShaderName
      
    }

    public func makeNSView(context: Context) -> NSViewType {
        let metalElement = MetalElement(fragmentShaderName: fragmentShaderName, vertexShaderName: vertexShaderName)
        metalElement.delegate = metalElement
        metalElement.drawableSize = drawableSize
        return metalElement
    }

    public func updateNSView(_ nsView: MetalElement, context: Context) {
         // Update the size of the MetalElement with the latest viewSize
        nsView.frame.size = drawableSize
        nsView.drawableSize = drawableSize
        nsView.needsDisplay = true
     }
 
}
#else
public struct MetalUIViewRepresentable: UIViewRepresentable {
    let drawableSize: CGSize
    let fragmentShaderName: String
    let vertexShaderName: String
    public typealias UIViewType = MetalElement
    
    public init(drawableSize: CGSize, fragmentShaderName: String,  vertexShaderName: String) {
        self.drawableSize = drawableSize
        self.fragmentShaderName = fragmentShaderName
        self.vertexShaderName = vertexShaderName
    }

    public func makeUIView(context: Context) -> UIViewType {
        let metalElement = MetalElement(fragmentShaderName: fragmentShaderName, vertexShaderName: vertexShaderName)
        metalElement.delegate = metalElement
        metalElement.drawableSize = drawableSize
        return metalElement
    }

    public func updateUIView(_ uiView: MetalElement, context: Context) {
        uiView.frame.size = drawableSize
        uiView.drawableSize = drawableSize
        uiView.setNeedsDisplay() // This will trigger a redraw
    }
 
}
#endif
