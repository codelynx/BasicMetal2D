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

#if os(OSX)
extension NSImage {

	// somehow OSX does not provide CGImage property
	var CGImage: CGImageRef? {
		if let data = self.TIFFRepresentation,
		   let imageSource = CGImageSourceCreateWithData(data, nil) {
			if CGImageSourceGetCount(imageSource) > 0 {
				return CGImageSourceCreateImageAtIndex(imageSource, 0, nil)
			}
		}
		return nil
	}

}
#endif

