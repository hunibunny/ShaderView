//
//  PlaceholderView.swift
//  
//
//  Created by Pirita Minkkinen on 10/25/23.
//

import Foundation
import SwiftUI

struct PlaceholderView: View {
    var body: some View {
        Rectangle()
            .fill(Color.gray)
            .overlay(
                Text("Loading Shader...")
                    .foregroundColor(.white)
            )
    }
}
