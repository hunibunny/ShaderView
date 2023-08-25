//
//  MetalSwiftUIView.swift
//  
//
//  Created by Pirita Minkkinen on 8/22/23.
//

//alternative name metalview wrapper


import SwiftUI

public struct MetalSwiftUIView: View {
    let fragmentShaderName: String
    var shouldScaleByDimensions: Bool = true


    public init(fragmentShaderName: String, shouldScaleByDimensions: Bool = false) {
        self.fragmentShaderName = fragmentShaderName
        self.shouldScaleByDimensions = shouldScaleByDimensions
    }
    //Then you'd need to pass this setting down to the appropriate rendering layer, in this case, the MetalConfigurable+Default.swift instance that does the rendering. You could make this an instance variable of the class/protocol and set it appropriately when the view is created/updated.
    
    public var body: some View {
        GeometryReader { geometry in
            #if os(macOS)
                MetalNSViewRepresentable(viewSize: geometry.size, fragmentShaderName: fragmentShaderName, shouldScaleByDimensions: shouldScaleByDimensions)
            #else
                MetalUIViewRepresentable(viewSize: geometry.size, fragmentShaderName: fragmentShaderName, shouldScaleByDimensions: shouldScaleByDimensions)
            #endif
        }
    }
}
