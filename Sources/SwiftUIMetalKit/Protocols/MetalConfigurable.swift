//
//  MetalConfigurable.swift
//  
//
//  Created by Pirita Minkkinen on 8/22/23.
//

import Metal

protocol MetalConfigurable {
    var commandQueue: MTLCommandQueue! { get set }
    var renderPipelineState: MTLRenderPipelineState! { get set }
    var outputTexture: MTLTexture! { get set }
    var startTime: Date? { get set }
    var elapsedTime: Float { get set }

    func commonInit()
}
