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
//	DeviceManager
//

class DeviceManager {

	static var device: MTLDevice = { return DeviceManager.sharedManager.device }()
	static var sharedManager = DeviceManager()

	static var imageRenderer: ImageRenderer = { return ImageRenderer(device: DeviceManager.device) }()
	static var strokeRenderer: StrokeRenderer = { return StrokeRenderer(device: DeviceManager.device) }()

	lazy var device: MTLDevice = { return MTLCreateSystemDefaultDevice()! }()

	
	fileprivate init() {
	}

	static var textureCache = NSMapTable<NSString, MTLTexture>.strongToWeakObjects()
	
	func textureNamed(_ name: String) -> MTLTexture? {
		if let imagePath = Bundle.main.path(forResource: name, ofType: "png") { // other types?
			return textureWithContentsOfFile(imagePath)
		}
		return nil
	}

	func textureWithContentsOfFile(_ path: String) -> MTLTexture? {
		if FileManager.default.fileExists(atPath: path) {
			if let texture = DeviceManager.textureCache.object(forKey: path as NSString) {
				return texture
			}
			let imageURL = URL(fileURLWithPath: path)
			do {
				let texture = try self.device.textureLoader.newTexture(withContentsOf: imageURL, options: nil)
				DeviceManager.textureCache.setObject(texture, forKey: path as NSString)
				return texture
			}
			catch let error { NSLog("Failed loading texture: '\(path)'\r\(error)") }
		}
		return nil
	}

}
