//
//  Renderable.swift
//  Metal2D
//
//  Created by Kaz Yoshikawa on 1/10/16.
//
//

import Foundation
import MetalKit
import GLKit

extension MTLDevice {
	var textureLoader: MTKTextureLoader {
		return MTKTextureLoader(device: self)
	}
}


//
//	Renderable
//

protocol Renderable {

	func render(context: RenderContext, transform: GLKMatrix4)

}

//
//	Node
//

class Node: Renderable {
	var subnodes: [Node]?
	var transform: GLKMatrix4

	init(transform: GLKMatrix4) {
		self.transform = transform
	}

	func render(context: RenderContext, transform: GLKMatrix4) {
	}

	func recursiveRender(context: RenderContext, transform: GLKMatrix4) {
		self.render(context, transform: transform * self.transform)
		if let subnodes = self.subnodes {
			for subnode in subnodes {
				subnode.recursiveRender(context, transform: transform * self.transform)
			}
		}
	}
}


//
//	ImageNode
//

class ImageNode : Node {

	var image: XImage
	var frame: Rect
	private var _vertexBuffer: VertexBuffer?
	private var _texture: MTLTexture?

	init(image: XImage, frame: Rect) {
		self.image = image
		self.frame = frame
		super.init(transform: GLKMatrix4Identity)
	}

	func textureWithDevice(device: MTLDevice) -> MTLTexture? {
		if _texture == nil {
			if let image = self.image.CGImage {
				do { _texture = try device.textureLoader.newTextureWithCGImage(image, options: nil) }
				catch let error { print("\(error)") }
			}
		}
		return _texture
	}
	
	func vertexBufferWithDevice(device: MTLDevice) -> VertexBuffer? {
		if _vertexBuffer == nil {
			let vertices = ImageRenderer.verticesForRect(self.frame)
			let buffer = device.newBufferWithBytes(vertices, length: sizeof(ImageRenderer.Vertex.self) * vertices.count, options: .OptionCPUCacheModeDefault)
			_vertexBuffer = VertexBuffer(buffer, vertices.count)
		}
		return _vertexBuffer
	}
	

	override func render(context: RenderContext, transform: GLKMatrix4) {
		let renderer = context.device.imageRenderer
		if let texture = self.textureWithDevice(context.device.device),
		   let vertexBuffer = self.vertexBufferWithDevice(context.device.device) {
			renderer.renderImage(context, texture: texture, vertexBuffer: vertexBuffer)
		}
	}
	
}

