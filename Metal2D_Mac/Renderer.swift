//
//  Renderer.swift
//  Metal2D
//
//  Created by Kaz Yoshikawa on 12/22/15.
//
//

import Foundation
import MetalKit

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
