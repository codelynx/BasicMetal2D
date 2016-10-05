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
	let commandEncoder: MTLRenderCommandEncoder
	let transform: GLKMatrix4
	var device: MTLDevice { return commandEncoder.device }
}


func * (l: RenderContext, r: GLKMatrix4) -> RenderContext {
	return RenderContext(commandEncoder: l.commandEncoder, transform: l.transform * r)
}
