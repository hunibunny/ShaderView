//
//  ShaderInputProtocol.swift
//  
//
//  Created by Pirita Minkkinen on 9/26/23.
//

import Foundation


///Anything conforming to this protocol can be passed to ShaderView
public protocol ShaderInputProtocol {
    var time: Float {get set}
    init()
    //static func createDefault() -> Self
}
