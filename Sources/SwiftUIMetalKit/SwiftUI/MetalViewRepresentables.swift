//
//  MetalViewRepresentables.swift
//
//
//  Created by Pirita Minkkinen on 8/22/23.
//

import SwiftUI

#if os(macOS)
public struct MetalNSViewRepresentable: NSViewRepresentable {
    @ObservedObject var viewModel: ShaderViewModel

    public typealias NSViewType = MetalElement
    
    let viewSize: CGSize
    let fragmentShaderName: String
    let vertexShaderName: String
    let shouldScaleByDimensions: Bool
    
    
    
    public init(viewSize: CGSize, fragmentShaderName: String, vertexShaderName: String, shouldScaleByDimensions: Bool) {
        self.viewSize = viewSize
        self.fragmentShaderName = fragmentShaderName
        self.vertexShaderName = vertexShaderName
        self.shouldScaleByDimensions = shouldScaleByDimensions
    }

    //will not work untill this one /mobile one gets called automatically or manually, need to decide which one iwant to do :)
    public func makeNSView(context: Context) -> NSViewType {
        let metalElement = MetalElement(fragmentShaderName: fragmentShaderName, vertexShaderName: vertexShaderName, shouldScaleByDimensions: shouldScaleByDimensions)
        metalElement.viewWidth = Int(viewSize.width) //this is dumb isnt it?
        metalElement.viewHeight = Int(viewSize.height)
        //metalElement.commonInit() idk if this is needed or not :)
        return metalElement
    }

    public func updateNSView(_ nsView: NSViewType, context: Context) {
        // Update the MetalElement view with any required data or state
        // For this example, we're leaving it empty as there might be no updates necessary.
        /*
         if viewModel.shouldStart {
                     uiView.startShader()
                 } else if viewModel.shouldStop {
                     uiView.stopShader()
                 }
         */
    }
 
}
#else
public struct MetalUIViewRepresentable: UIViewRepresentable {
    let viewSize: CGSize
    let fragmentShaderName: String
    let shouldScaleByDimensions: Bool
    public typealias UIViewType = MetalElement
    
    public init(viewSize: CGSize, fragmentShaderName: String, shouldScaleByDimensions: Bool) {
        self.viewSize = viewSize
        self.fragmentShaderName = fragmentShaderName
        self.shouldScaleByDimensions = shouldScaleByDimensions
    }

    public func makeUIView(context: Context) -> UIViewType {
        let metalElement = MetalElement(fragmentShaderName: fragmentShaderName)
        metalElement.viewWidth = Int(viewSize.width)
        metalElement.viewHeight = Int(viewSize.height)
        metalElement.shouldScaleByDimensions = shouldScaleByDimensions
        metalElement.commonInit()
        return metalElement
    }
    
    
    func updateUIView(_ uiView: MTKView, context: Context) {
        if viewModel.isRunning {
            uiView.startShader()
        } else {
            uiView.stopShader()
        }
    }
  //updateuiveiw missing, idk if it will be needed or not
}
#endif
