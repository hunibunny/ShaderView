//
//  File.swift
//  
//
//  Created by Pirita Minkkinen on 8/25/23.
//


import SwiftUI
//import simd

public struct ShaderInput {
    var iTime: Float
    var iResolution: SIMD3<Float>
    
    init(iTime: Float, viewWidth: Int, viewHeight: Int) {
        self.iTime = iTime
        self.iResolution = SIMD3<Float>(Float(viewWidth), Float(viewHeight), 0)
    }

    init(iTime: Float, drawableSize: CGSize) {
        self.iTime = iTime
        self.iResolution = SIMD3<Float>(Float(drawableSize.width), Float(drawableSize.height), 0)
    }
    
    init(iTime: Float, iResolution: SIMD3<Float>) {
        self.iTime = iTime
        self.iResolution = iResolution
    }
}
