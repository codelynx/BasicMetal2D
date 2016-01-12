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

	
	private init() {
	}

	static var textureCache = NSMapTable.strongToWeakObjectsMapTable()
	
	func textureNamed(name: String) -> MTLTexture? {
		if let imagePath = NSBundle.mainBundle().pathForResource(name, ofType: "png") { // other types?
			return textureWithContentsOfFile(imagePath)
		}
		return nil
	}

	func textureWithContentsOfFile(path: String) -> MTLTexture? {
		if NSFileManager.defaultManager().fileExistsAtPath(path) {
			if let texture = DeviceManager.textureCache.objectForKey(path) as? MTLTexture {
				return texture
			}
			let imageURL = NSURL.fileURLWithPath(path)
			do {
				let texture = try self.device.textureLoader.newTextureWithContentsOfURL(imageURL, options: nil)
				DeviceManager.textureCache.setObject(texture, forKey: path)
				return texture
			}
			catch let error { NSLog("Failed loading texture: '\(path)'\r\(error)") }
		}
		return nil
	}

}
