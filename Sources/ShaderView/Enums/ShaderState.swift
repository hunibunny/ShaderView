//
//  ShaderState.swift
//  
//
//  Created by Pirita Minkkinen on 10/25/23.
//

import Foundation
import Metal

enum ShaderState: Equatable {
    static func == (lhs: ShaderState, rhs: ShaderState) -> Bool {
        switch (lhs, rhs) {
        case (.compiling, .compiling), (.error, .error):
            return true
        case (.compiled(let lhsFunction), .compiled(let rhsFunction)):
            //This should do since the name should be unique anyways
            return lhsFunction.name == rhsFunction.name
        default:
            return false
        }
    }

    case compiling
    case compiled(MTLFunction)
    case error
}


