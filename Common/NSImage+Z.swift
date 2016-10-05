//
//  NSImage+Z.swift
//  Metal2D
//
//  Created by Kaz Yoshikawa on 1/11/16.
//
//

import Foundation
import MetalKit
import CoreGraphics
import ImageIO

#if os(macOS)
extension NSImage {

	// somehow OSX does not provide CGImage property
	var cgImage: CGImage? {
		if let data = self.tiffRepresentation,
		   let imageSource = CGImageSourceCreateWithData(data as CFData, nil) {
			if CGImageSourceGetCount(imageSource) > 0 {
				return CGImageSourceCreateImageAtIndex(imageSource, 0, nil)
			}
		}
		return nil
	}

}
#endif

