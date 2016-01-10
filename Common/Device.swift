//
//  Device.swift
//  Metal2D
//
//  Created by Kaz Yoshikawa on 1/11/16.
//
//

import Foundation
import MetalKit

//
//	Device
//

class Device {

	lazy var device: MTLDevice = { return MTLCreateSystemDefaultDevice()! }()
	lazy var imageRenderer: ImageRenderer = { return ImageRenderer(device: self.device) }()

	static var sharedDevice = Device()
	private init() {
	}

}



