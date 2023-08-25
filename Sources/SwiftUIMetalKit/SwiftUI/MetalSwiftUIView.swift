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
    let shouldScaleByDimensions: Bool

    public init(fragmentShaderName: String, shouldScaleByDimensions: Bool = false) {
        self.fragmentShaderName = fragmentShaderName
        self.shouldScaleByDimensions = shouldScaleByDimensions
    }

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
