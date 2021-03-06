//
//  ImageNode.swift
//  Metal2D
//
//  Created by Kaz Yoshikawa on 1/11/16.
//
//

import Foundation
import MetalKit
import GLKit



//
//	ImageNode
//

class ImageNode: Node {

	var image: XImage
	var frame: Rect
	fileprivate var _vertexBuffer: VertexBuffer<ImageVertex>?
	fileprivate var _texture: MTLTexture?

	init(image: XImage, frame: Rect) {
		self.image = image
		self.frame = frame
		super.init(transform: GLKMatrix4Identity)
	}

	var texture: MTLTexture? {
		if _texture == nil {
			if let image = self.image.cgImage {
				let device = DeviceManager.device
				do { _texture = try device.textureLoader.newTexture(with: image, options: nil) }
				catch let error { print("\(error)") }
			}
		}
		return _texture
	}

	var vertexBuffer: VertexBuffer<ImageVertex>? {
		if _vertexBuffer == nil {
			let renderer = DeviceManager.imageRenderer
			_vertexBuffer = renderer.vertexBufferForRect(self.frame)
		}
		return _vertexBuffer
	}


	override func render(_ context: RenderContext) {
		let renderer = DeviceManager.imageRenderer
		if let texture = self.texture, let vertexBuffer = self.vertexBuffer {
			renderer.renderImage(context, texture: texture, vertexBuffer: vertexBuffer)
		}
	}
	
}

