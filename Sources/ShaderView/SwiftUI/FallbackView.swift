//
//  FallbackView.swift
//  
//
//  Created by Pirita Minkkinen on 11/8/23.
//

import Foundation
import SwiftUI

struct FallbackView: View {
    var body: some View {
        Rectangle()
            .fill(Color.gray)
            .overlay(
                Text("Metal not supported on this device or metal support could not be initialized")
                    .foregroundColor(.white)
            )
    }
}
