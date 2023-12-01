//
//  File.swift
//  
//
//  Created by Pirita Minkkinen on 8/25/23.
//


import SwiftUI

public struct ShaderInput: ShaderInputProtocol{
    public var time: Float = 0.0
    
    public static func createDefault() -> ShaderInput {
            return ShaderInput()
    }
}
