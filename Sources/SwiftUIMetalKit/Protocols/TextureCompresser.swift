//
//  TextureCompresser.swift
//  
//
//  Created by Pirita Minkkinen on 9/13/23.
//

import Foundation
import MetalKit

protocol TextureCompresser {
    func compress(texture: MTLTexture) -> MTLTexture
}

extension TextureCompresser {
    func compress(texture: MTLTexture) -> MTLTexture {
        // Implement a default compression mechanism here.
        // You might want to support various compression techniques/formats
        // based on the platform or user needs.
    }
}

/*
 By providing this protocol:

 Users can implement their own custom compression techniques if needed.
 Users who don't need a custom approach can leverage the default mechanism you provide.
 The package becomes more flexible and robust.
 When implementing texture compression, consider:

 The platform you're targeting (iOS, macOS, etc.) as not all texture compression formats are supported everywhere.
 The type of content in the texture. Different content might benefit from different compression techniques.
 Ensuring quality isn't overly degraded due to compression, especially for crucial assets.
 Including such functionality will undoubtedly enhance the usability and efficiency of your package.
 */
