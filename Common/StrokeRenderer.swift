//
//  StrokeRenderer.swift
//  Metal2D
//
//  Created by Kaz Yoshikawa on 1/11/16.
//
//

import Foundation
import CoreGraphics
import QuartzCore
import GLKit

typealias StrokeVertex = StrokeRenderer.Vertex

//
//	StrokeRenderer
//

class StrokeRenderer: Renderer {

	struct Vertex {
		var x: Float
		var y: Float
		var z: Float
		var force: Float

		var altitudeAngle: Float
		var azimuthAngle: Float
		var velocity: Float
		var angle: Float
		init(x: Float, y: Float, z: Float, force: Float, altitudeAngle: Float, azimuthAngle: Float, velocity: Float, angle: Float) {
			self.x = x; self.y = y; self.z = z; self.force = force
			self.altitudeAngle = altitudeAngle; self.azimuthAngle = azimuthAngle; self.velocity = velocity; self.angle = angle
		}
		init() {
			self.x = 0; self.y = 0; self.z = 0; self.force = 0
			self.altitudeAngle = 0; self.azimuthAngle = 0; self.velocity = 0; self.angle = 0
		}
	}

	struct Uniforms {
		var modelViewProjectionMatrix: GLKMatrix4
	}

	let device: MTLDevice

	var colorSamplerState: MTLSamplerState!

	init(device: MTLDevice) {
		self.device = device
	}

	var vertexDescriptor: MTLVertexDescriptor {
		let vertexDescriptor = MTLVertexDescriptor()
		vertexDescriptor.attributes[0].offset = 0
		vertexDescriptor.attributes[0].format = .Float2
		vertexDescriptor.attributes[0].bufferIndex = 0

		vertexDescriptor.layouts[0].stepFunction = .PerVertex
		vertexDescriptor.layouts[0].stride = sizeof(Vertex)
		return vertexDescriptor
	}

	lazy var renderPipelineState: MTLRenderPipelineState = {
		let renderPipelineDescriptor = MTLRenderPipelineDescriptor()
		renderPipelineDescriptor.vertexDescriptor = self.vertexDescriptor
		renderPipelineDescriptor.vertexFunction = self.library.newFunctionWithName("stroke_vertex")!
		renderPipelineDescriptor.fragmentFunction = self.library.newFunctionWithName("stroke_fragment")!

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
	
	func vertexBufferWithVertices(vertices: [Vertex], capacity: Int) -> VertexBuffer<Vertex> {
		return VertexBuffer<Vertex>(self.device, vertices, capacity)
	}

	func renderStroke(renderContext: RenderContext, texture: MTLTexture, vertexBuffer: VertexBuffer<Vertex>) {
		let transform = renderContext.transform
		var uniforms = Uniforms(modelViewProjectionMatrix: transform)
		let uniformsBuffer = device.newBufferWithBytes(&uniforms, length: sizeof(Uniforms), options: .OptionCPUCacheModeDefault)

		let commandEncoder = renderContext.commandEncoder
		commandEncoder.setRenderPipelineState(self.renderPipelineState)

		commandEncoder.setVertexBuffer(vertexBuffer.buffer, offset: 0, atIndex: 0)
		commandEncoder.setVertexBuffer(uniformsBuffer, offset: 0, atIndex: 1)

		commandEncoder.setFragmentTexture(texture, atIndex: 0)
		commandEncoder.setFragmentSamplerState(self.colorSamplerState, atIndex: 0)

		commandEncoder.drawPrimitives(.Point, vertexStart: 0, vertexCount: vertexBuffer.count)
//		commandEncoder.drawPrimitives(.LineStrip, vertexStart: 0, vertexCount: vertexBuffer.count)
	}
}
