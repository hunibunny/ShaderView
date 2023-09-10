//
//  TextureAwareShader.swift
//  
//
//  Created by Pirita Minkkinen on 9/10/23.
//

import Foundation
import Metal
import simd

struct TextureConfiguration{
    var baseTexture: MTLTexture //put some default texture here maybe?
    var normalMap: MTLTexture?
    var specularMap: MTLTexture?
    var ambientOcclusionMap: MTLTexture?
    var emissionMap: MTLTexture?
    var textureCoordinates: SIMD2<Float>?//Coordinates to sample the texture(s). Typically comes from vertex data.
    //var textureTransformMatrix: float4x4? //will most liklely result in a conflict with scaling with dimensions, at least result wise :)
}

protocol TextureAwareShader: MetalConfigurable {
    var textureConfig: TextureConfiguration {get set}
}
