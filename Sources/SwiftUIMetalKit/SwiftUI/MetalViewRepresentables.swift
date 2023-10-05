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
    @StateObject private var viewModel = ShaderViewModel()

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
       // metalElement.viewWidth = Int(viewSize.width) //this is dumb isnt it?
       // metalElement.viewHeight = Int(viewSize.height)
        //metalElement.commonInit() idk if this is needed or not :)
        return metalElement
    }

    public func updateNSView(_ nsView: NSViewType, context: Context) {
       //dont know if this will be needed :)
    
    }
 
}
#else
public struct MetalUIViewRepresentable: UIViewRepresentable {
    let viewSize: CGSize
    let fragmentShaderName: String
    let vertexShaderName: String
    let shouldScaleByDimensions: Bool
    public typealias UIViewType = MetalElement
    
    public init(viewSize: CGSize, fragmentShaderName: String,  vertexShaderName: String, shouldScaleByDimensions: Bool) {
        self.viewSize = viewSize
        self.fragmentShaderName = fragmentShaderName
        self.vertexShaderName = vertexShaderName
        self.shouldScaleByDimensions = shouldScaleByDimensions
    }

    public func makeUIView(context: Context) -> UIViewType {
        let metalElement = MetalElement(fragmentShaderName: fragmentShaderName, vertexShaderName: vertexShaderName, shouldScaleByDimensions: shouldScaleByDimensions)
      //  metalElement.viewWidth = Int(viewSize.width)
       // metalElement.viewHeight = Int(viewSize.height)
       // metalElement.shouldScaleByDimensions = shouldScaleByDimensions
        //metalElement.commonInit()
        return metalElement
    }

    public func updateUIView(_ uiView: MetalElement, context: Context) {
        /*
        if viewModel.isRunning {
            uiView.startShader()
        } else {
            uiView.stopShader()
        }*/
    }
 
}
#endif
