//
//  MetalSwiftUIView.swift
//  
//
//  Created by Pirita Minkkinen on 8/22/23.
//

//alternative name metalview wrapper

import SwiftUI


struct MetalSwiftUIView: View {
    #if os(macOS)
    var body: some View {
        MetalNSViewRepresentable()
    }
    #else
    var body: some View {
        MetalUIViewRepresentable()
    }
    #endif
}
