//
//  StyleUtils.swift
//  SwiftLauncher
//
//  Created by Kaleb Rosborough on 2022-12-24.
//

import SwiftUI

extension View {
    func cornerRadius(_ radius: CGFloat, corners: UIRectCorner) -> some View {
        clipShape(RoundedCorner(radius: radius, corners: corners))
    }
}
