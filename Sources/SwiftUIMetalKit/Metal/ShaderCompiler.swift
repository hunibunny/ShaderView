//
//  ShaderCompiler.swift
//  
//
//  Created by Pirita Minkkinen on 10/8/23.
//

import Foundation
import Metal

// Manages the compilation of shader source code into usable shaders.
class ShaderCompiler {
    //static let shared = ShaderCompiler(device: DeviceManager.shared.device)

    
    let device: MTLDevice
    
    init(device: MTLDevice?) {
        guard let validDevice = device else {
            fatalError("Metal is not supported on this device.")
        }
        self.device = validDevice
        
    }
    
    func compileShaderSource(_ source: String, key: String, completion: @escaping (MTLFunction?) -> ()) {
            DispatchQueue.global().async {
                guard let device = MTLCreateSystemDefaultDevice(),
                      let library = try? device.makeLibrary(source: source, options: nil),
                      let shaderFunction = library.makeFunction(name: key) else {
                    completion(nil)
                    return
                }
                completion(shaderFunction)
            }
        }
}


