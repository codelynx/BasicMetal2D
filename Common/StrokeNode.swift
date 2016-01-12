//
//  StrokeNode.swift
//  Metal2D
//
//  Created by Kaz Yoshikawa on 1/11/16.
//
//

import Foundation
import MetalKit
import GLKit


//
//	StrokeNode
//

class StrokeNode: Node {
	
	var texture: MTLTexture
	var vertices: [StrokeVertex]
	private var _vertexBuffer: VertexBuffer<StrokeVertex>?

	init(texture: MTLTexture, vertices: [StrokeVertex]) {
		self.texture = DeviceManager.sharedManager.textureNamed("Particle")!
		self.vertices = vertices
		super.init(transform: GLKMatrix4Identity)
	}
	
	var vertexBuffer: VertexBuffer<StrokeVertex>? {
		if _vertexBuffer == nil {
			_vertexBuffer = DeviceManager.strokeRenderer.vertexBufferWithVertices(self.vertices, capacity: 4096)
		}
		return _vertexBuffer
	}
	
	override func render(context: RenderContext) {
		if let vertexBuffer = self.vertexBuffer {
			let renderer = DeviceManager.strokeRenderer
			renderer.renderStroke(context, texture: texture, vertexBuffer: vertexBuffer)
		}
	}
	
	func append(vertices: [StrokeVertex]) {
		self.vertexBuffer?.append(vertices)
		self.vertices += vertices
	}
}
