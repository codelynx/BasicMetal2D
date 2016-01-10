//
//  Renderer.swift
//  Metal2D
//
//  Created by Kaz Yoshikawa on 12/22/15.
//
//

import Foundation
import MetalKit

#if os(OSX)
typealias XColor = NSColor
typealias XImage = NSImage
#elseif os(iOS)
typealias XColor = UIColor
typealias XImage = UIImage
#endif


//
//	protocol Renderer
//

protocol Renderer {

	var device: MTLDevice { get }

	var renderPipelineState: MTLRenderPipelineState { get }

}

//
//	extension Renderer
//

extension Renderer {

	var library: MTLLibrary {
		return self.device.newDefaultLibrary()!
	}

}
