//
//  RenderContext.swift
//  Metal2D
//
//  Created by Kaz Yoshikawa on 1/10/16.
//
//

import Foundation
import MetalKit
import GLKit


//
//	RenderContext
//

struct RenderContext {
	let device: Device
	let commandEncoder: MTLRenderCommandEncoder
	let transform: GLKMatrix4
}
