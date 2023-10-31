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
    //@StateObject private var viewModel = ShaderViewModel()

    public typealias NSViewType = MetalElement
    
    let viewSize: CGSize
    let fragmentShaderName: String
    let vertexShaderName: String

    
    
    public init(viewSize: CGSize, fragmentShaderName: String, vertexShaderName: String) {
        self.viewSize = viewSize
        self.fragmentShaderName = fragmentShaderName
        self.vertexShaderName = vertexShaderName
      
    }

    //will not work untill this one /mobile one gets called automatically or manually, need to decide which one iwant to do :)
    public func makeNSView(context: Context) -> NSViewType {
        let metalElement = MetalElement(fragmentShaderName: fragmentShaderName, vertexShaderName: vertexShaderName, viewSize: viewSize)
        metalElement.delegate = metalElement
        
    

       // metalElement.viewWidth = Int(viewSize.width) //this is dumb isnt it?
       // metalElement.viewHeight = Int(viewSize.height)
        //metalElement.commonInit() idk if this is needed or not :)
        return metalElement
    }

    public func updateNSView(_ nsView: MetalElement, context: Context) {
         // Update the size of the MetalElement with the latest viewSize
         nsView.frame.size = viewSize
         nsView.needsDisplay = true // This will request a redraw
     }
 
}
#else
public struct MetalUIViewRepresentable: UIViewRepresentable {
    let viewSize: CGSize
    let fragmentShaderName: String
    let vertexShaderName: String
    public typealias UIViewType = MetalElement
    
    public init(viewSize: CGSize, fragmentShaderName: String,  vertexShaderName: String) {
        self.viewSize = viewSize
        self.fragmentShaderName = fragmentShaderName
        self.vertexShaderName = vertexShaderName
    }

    public func makeUIView(context: Context) -> UIViewType {
        let metalElement = MetalElement(fragmentShaderName: fragmentShaderName, vertexShaderName: vertexShaderName, viewSize: viewSize)
        metalElement.delegate = metalElement
        assert(pipelineDescriptor.colorAttachments[0].pixelFormat == metalElement.colorPixelFormat, "Pixel formats do not match!")
      //  metalElement.viewWidth = Int(viewSize.width)
       // metalElement.viewHeight = Int(viewSize.height)
       // metalElement.shouldScaleByDimensions = shouldScaleByDimensions
        //metalElement.commonInit()
        return metalElement
    }

    public func updateUIView(_ uiView: MetalElement, context: Context) {
        // Update the size of the MetalElement with the latest viewSize
        uiView.frame.size = viewSize
        uiView.setNeedsDisplay() // This will trigger a redraw
    }
 
}
#endif
