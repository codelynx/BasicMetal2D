//
//  ImageRenderer.swift
//  Metal2D
//
//  Created by Kaz Yoshikawa on 12/22/15.
//
//

import Foundation
import Metal
import GLKit


//
//	ImageRenderer
//

class ImageRenderer: Renderer {

	struct Vertex {
		var x, y, z, w, u, v: Float
	}

	struct Uniforms {
		var modelViewProjectionMatrix: GLKMatrix4
	}


	let device: MTLDevice
	
	var colorSamplerState: MTLSamplerState!

	init(device: MTLDevice) {
		self.device = device
	}

	class func verticesForRect(rect: Rect) -> [Vertex] {
		let l = rect.minX
		let r = rect.maxX
		let t = rect.minY
		let b = rect.maxY
		return [
			Vertex(x: l, y: t, z: 0, w: 1, u: 0, v: 1),
			Vertex(x: l, y: b, z: 0, w: 1, u: 0, v: 0),
			Vertex(x: r, y: b, z: 0, w: 1, u: 1, v: 0),
			Vertex(x: l, y: t, z: 0, w: 1, u: 0, v: 1),
			Vertex(x: r, y: b, z: 0, w: 1, u: 1, v: 0),
			Vertex(x: r, y: t, z: 0, w: 1, u: 1, v: 1),
		]
	}

	class func verticesForRect(rect: CGRect) -> [Vertex] {
		let l = Float(CGRectGetMinX(rect))
		let r = Float(CGRectGetMaxX(rect))
		let t = Float(CGRectGetMinY(rect))
		let b = Float(CGRectGetMaxY(rect))
		return [
			Vertex(x: l, y: t, z: 0, w: 1, u: 0, v: 1),
			Vertex(x: l, y: b, z: 0, w: 1, u: 0, v: 0),
			Vertex(x: r, y: b, z: 0, w: 1, u: 1, v: 0),
			Vertex(x: l, y: t, z: 0, w: 1, u: 0, v: 1),
			Vertex(x: r, y: b, z: 0, w: 1, u: 1, v: 0),
			Vertex(x: r, y: t, z: 0, w: 1, u: 1, v: 1),
		]
	}

	var vertexDescriptor: MTLVertexDescriptor {
		let vertexDescriptor = MTLVertexDescriptor()
		vertexDescriptor.attributes[0].offset = 0
		vertexDescriptor.attributes[0].format = .Float4
		vertexDescriptor.attributes[0].bufferIndex = 0

		vertexDescriptor.attributes[1].offset = 0
		vertexDescriptor.attributes[1].format = .Float2
		vertexDescriptor.attributes[1].bufferIndex = 0
		
		vertexDescriptor.layouts[0].stepFunction = .PerVertex
		vertexDescriptor.layouts[0].stride = sizeof(Vertex)
		return vertexDescriptor
	}

	lazy var renderPipelineState: MTLRenderPipelineState = {
		let renderPipelineDescriptor = MTLRenderPipelineDescriptor()
		renderPipelineDescriptor.vertexDescriptor = self.vertexDescriptor
		renderPipelineDescriptor.vertexFunction = self.library.newFunctionWithName("image_vertex")!
		renderPipelineDescriptor.fragmentFunction = self.library.newFunctionWithName("image_fragment")!

		renderPipelineDescriptor.colorAttachments[0].pixelFormat = .BGRA8Unorm
		renderPipelineDescriptor.colorAttachments[0].blendingEnabled = true
		renderPipelineDescriptor.colorAttachments[0].rgbBlendOperation = .Add
		renderPipelineDescriptor.colorAttachments[0].alphaBlendOperation = .Add

		renderPipelineDescriptor.colorAttachments[0].sourceRGBBlendFactor = .SourceAlpha
		renderPipelineDescriptor.colorAttachments[0].sourceAlphaBlendFactor = .SourceAlpha
		renderPipelineDescriptor.colorAttachments[0].destinationRGBBlendFactor = .OneMinusSourceAlpha
		renderPipelineDescriptor.colorAttachments[0].destinationAlphaBlendFactor = .OneMinusSourceAlpha

		let samplerDescriptor = MTLSamplerDescriptor()
		samplerDescriptor.minFilter = .Nearest
		samplerDescriptor.magFilter = .Linear
		samplerDescriptor.sAddressMode = .Repeat
		samplerDescriptor.tAddressMode = .Repeat
		self.colorSamplerState = self.device.newSamplerStateWithDescriptor(samplerDescriptor)

		return try! self.device.newRenderPipelineStateWithDescriptor(renderPipelineDescriptor)
	}()

	func renderImage(renderContext: RenderContext, texture: MTLTexture, vertexBuffer: VertexBuffer) {
		let transform = renderContext.transform
		var uniforms = Uniforms(modelViewProjectionMatrix: transform)
		let uniformsBuffer = device.newBufferWithBytes(&uniforms, length: sizeof(Uniforms), options: .OptionCPUCacheModeDefault)
		
		
		let commandEncoder = renderContext.commandEncoder
		commandEncoder.setRenderPipelineState(self.renderPipelineState)

		commandEncoder.setFrontFacingWinding(.CounterClockwise)
		commandEncoder.setCullMode(.Back)
		commandEncoder.setVertexBuffer(vertexBuffer.buffer, offset: 0, atIndex: 0)
		commandEncoder.setVertexBuffer(uniformsBuffer, offset: 0, atIndex: 1)

		commandEncoder.setFragmentTexture(texture, atIndex: 0)
		commandEncoder.setFragmentSamplerState(self.colorSamplerState, atIndex: 0)

		commandEncoder.drawPrimitives(.Triangle, vertexStart: 0, vertexCount: vertexBuffer.count)
	}
}