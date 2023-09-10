//
//  File.swift
//  
//
//  Created by Pirita Minkkinen on 9/10/23.
//

import Foundation
import simd

struct LightConfiguration {
    var position: float3?
    var direction: float3?
    var color: float3?
    var intensity: Float?
    var ambientIntensity: Float?
    var specularIntensity: Float?
    var attenuationFactors: float3?
    var spotlightAngles: float3?
    //Number of Lights:
}

protocol LightAwareShader: MetalConfigurable {
    var LightConfig: LightConfiguration {get set}
}

