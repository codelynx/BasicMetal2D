//
//  VertexBuffer.swift
//  Metal2D
//
//  Created by Kaz Yoshikawa on 1/11/16.
//
//

import Foundation
import MetalKit
import GLKit

//
//	VertexBuffer
//

class VertexBuffer {
	let buffer: MTLBuffer
	let count: Int
	
	init(_ buffer: MTLBuffer, _ count: Int) {
		self.buffer = buffer
		self.count = count
	}
}
