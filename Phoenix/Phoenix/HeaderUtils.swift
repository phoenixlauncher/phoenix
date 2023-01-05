//
//  HeaderUtils.swift
//  Phoenix
//
//  Created by Kaleb Rosborough on 2022-12-25.
//

import SwiftUI

/// Returns the vertical scroll offset of the given geometry in global coordinates.
///
/// - Parameters:
///    - geometry: The geometry to retrieve the scroll offset for.
///
/// - Returns: The vertical scroll offset of the given geometry.
func getScrollOffset(_ geometry: GeometryProxy) -> CGFloat {
  geometry.frame(in: .global).minY
}

/// Returns the vertical offset for a header image based on the given geometry.
///
/// If the given geometry has a positive vertical scroll offset (i.e. it has been
/// pulled down), the returned offset will be the negative of the scroll offset.
/// Otherwise, the returned offset will be 0.
///
/// - Parameters:
///    - geometry: The geometry to use to calculate the offset.
///
/// - Returns: The vertical offset for a header image based on the given geometry.
func getOffsetForHeaderImage(_ geometry: GeometryProxy) -> CGFloat {
  let offset = getScrollOffset(geometry)

  // Image was pulled down
  if offset > 0 {
    return -offset
  }

  return 0
}

/// Returns the height for a header image based on the given geometry.
///
/// If the given geometry has a positive vertical scroll offset (i.e. it has been
/// pulled down), the returned height will be the height of the geometry plus the
/// scroll offset. Otherwise, the returned height will be the height of the
/// geometry.
///
/// - Parameters:
///    - geometry: The geometry to use to calculate the height.
///
/// - Returns: The height for a header image based on the given geometry.
func getHeightForHeaderImage(_ geometry: GeometryProxy) -> CGFloat {
  let offset = getScrollOffset(geometry)
  let imageHeight = geometry.size.height

  if offset > 0 {
    return imageHeight + offset
  }

  return imageHeight
}

/// Returns the blur radius for an image based on the given geometry.
///
/// The blur radius is calculated as a percentage of the image height, with values
/// ranging from 0 to 10. If the given geometry has a positive vertical scroll
/// offset (i.e. it has been pulled down), the blur radius will increase as the
/// offset increases. If the geometry has a negative or 0 offset, the blur radius
/// will be 0.
///
/// - Parameters:
///    - geometry: The geometry to use to calculate the blur radius.
///
/// - Returns: The blur radius for an image based on the given geometry.
func getBlurRadiusForImage(_ geometry: GeometryProxy) -> CGFloat {
  let offset = geometry.frame(in: .global).maxY

  let height = geometry.size.height
  let blur = (height - max(offset, 0)) / height  // Values will range from 0 - 1

  return blur * 10  // Values will range from 0 - 10
}

/// Loads an image from the file at the given file path.
///
/// If the file at the given file path does not exist or there is an error
/// reading from the file, a placeholder image is returned.
///
/// - Parameters:
/// - filePath: The file path of the image to load.
///
/// - Returns: The image at the given file path, or a placeholder image if the
/// file could not be loaded.
func loadImageFromFile(filePath: String) -> NSImage {
  do {
    if filePath != "" {
      let imageData = try Data(contentsOf: URL(string: filePath)!)
      return NSImage(data: imageData) ?? NSImage(imageLiteralResourceName: "PlaceholderImage")
    } else {
      return NSImage(imageLiteralResourceName: "PlaceholderImage")
    }
  } catch {
    print("Error loading image : \(error)")
  }
  return NSImage(imageLiteralResourceName: "PlaceholderImage")
}
