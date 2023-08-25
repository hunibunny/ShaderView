//
//  MetalViewRepresentables.swift
//  
//
//  Created by Pirita Minkkinen on 8/22/23.
//

import SwiftUI

#if os(macOS)
public struct MetalNSViewRepresentable: NSViewRepresentable {

    public typealias NSViewType = MetalElement
    
    let viewSize: CGSize
    let fragmentShaderName: String
    let shouldScaleByDimensions: Bool
    
    public init(viewSize: CGSize, fragmentShaderName: String, shouldScaleByDimensions: Bool) {
        self.viewSize = viewSize
        self.fragmentShaderName = fragmentShaderName
        self.shouldScaleByDimensions = shouldScaleByDimensions
    }

    public func makeNSView(context: Context) -> NSViewType {
        let metalElement = MetalElement(fragmentShaderName: fragmentShaderName, shouldScaleByDimensions: shouldScaleByDimensions)
        metalElement.viewWidth = Int(viewSize.width)
        metalElement.viewHeight = Int(viewSize.height)
        metalElement.commonInit()
        return metalElement
    }

    public func updateNSView(_ nsView: NSViewType, context: Context) {
        // Update the MetalElement view with any required data or state
        // For this example, we're leaving it empty as there might be no updates necessary.
    }
 
}
#else
public struct MetalUIViewRepresentable: UIViewRepresentable {
    let viewSize: CGSize
    let fragmentShaderName: String
    let shouldScaleByDimensions: Bool
    public typealias NSViewType = MetalElement
    
    public init(viewSize: CGSize, fragmentShaderName: String, shouldScaleByDimensions: Bool) {
        self.viewSize = viewSize
        self.fragmentShaderName = fragmentShaderName
        self.shouldScaleByDimensions = shouldScaleByDimensions
    }

    public func makeUIView(context: Context) -> NSViewType {
        let metalElement = MetalElement(fragmentShaderName: fragmentShaderName)
        metalElement.viewWidth = Int(viewSize.width)
        metalElement.viewHeight = Int(viewSize.height)
        metalElement.shouldScaleByDimensions = shouldScaleByDimensions
        metalElement.commonInit()
        return metalElement
    }
    
  //updateuiveiw missing, idk if it will be needed or not
    
}

#endif
