//
//  MetalSwiftUIView.swift
//  
//
//  Created by Pirita Minkkinen on 8/22/23.
//

//alternative name metalview wrapper

import SwiftUI


public struct MetalSwiftUIView: View {
    #if os(macOS)
    public var body: some View {
        MetalNSViewRepresentable()
    }
    #else
    public var body: some View {
        MetalUIViewRepresentable()
    }
    #endif
}
