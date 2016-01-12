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

//
//	extensions
//

extension MTLDevice {
	var textureLoader: MTKTextureLoader {
		return MTKTextureLoader(device: self)
	}
}


//
//	Renvarable
//

protocol Renderable {

	func render(context: RenderContext)

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

	func render(context: RenderContext) {
	}

	func recursiveRender(context: RenderContext) {
		self.render(context * self.transform)
		if let subnodes = self.subnodes {
			for subnode in subnodes {
				subnode.recursiveRender(context * transform)
			}
		}
	}
}


//
//	Scene
//

class Scene: Node {
	var size: Size
	
	init(size: Size) {
		self.size = size
		super.init(transform: GLKMatrix4Identity)
	}
}

