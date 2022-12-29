//
//  HeaderUtils.swift
//  Phoenix
//
//  Created by Kaleb Rosborough on 2022-12-25.
//

import SwiftUI

func getScrollOffset(_ geometry: GeometryProxy) -> CGFloat {
    geometry.frame(in: .global).minY
}

func getOffsetForHeaderImage(_ geometry: GeometryProxy) -> CGFloat {
    let offset = getScrollOffset(geometry)

    // Image was pulled down
    if offset > 0 {
        return -offset
    }

    return 0
}

func getHeightForHeaderImage(_ geometry: GeometryProxy) -> CGFloat {
    let offset = getScrollOffset(geometry)
    let imageHeight = geometry.size.height

    if offset > 0 {
        return imageHeight + offset
    }

    return imageHeight
}

func getBlurRadiusForImage(_ geometry: GeometryProxy) -> CGFloat {
    let offset = geometry.frame(in: .global).maxY

    let height = geometry.size.height
    let blur = (height - max(offset, 0)) / height // Values will range from 0 - 1

    return blur * 10 // Values will range from 0 - 10
}
