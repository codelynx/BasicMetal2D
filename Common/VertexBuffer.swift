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

class VertexBuffer<T> {
	let device: MTLDevice
	var buffer: MTLBuffer
	var count: Int
	var capacity: Int

	init(_ device: MTLDevice, _ verticies: [T], _ capacity: Int? = nil) {
		self.device = device
		self.count = verticies.count
		self.capacity = capacity ?? verticies.count
		let length = sizeof(T) * self.capacity
		self.buffer = device.newBufferWithBytes(verticies, length: length, options: .CPUCacheModeDefaultCache)
		assert(self.count <= self.capacity)
		/*
		let vertexArray = UnsafeMutablePointer<T>(self.buffer.contents())
		for index in 0 ..< verticies.count {
			let vertex1 = vertexArray[index]
			let vertex2 = verticies[index]
		}
		*/
	}

	func append(verticies: [T]) {
		if self.count + verticies.count < self.capacity {
			let vertexArray = UnsafeMutablePointer<T>(self.buffer.contents())
			for index in 0 ..< verticies.count {
				vertexArray[self.count + index] = verticies[index]
			}
			self.count += verticies.count
		}
		else { fatalError("buffer overflow - to do: extend buffer")
		}
	}

}
