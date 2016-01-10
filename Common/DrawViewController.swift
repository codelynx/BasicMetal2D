//
//  ViewController.swift
//  Metal2D
//
//  Created by Kaz Yoshikawa on 12/21/15.
//
//

#if os(OSX)
import Cocoa
#elseif os(iOS)
import UIKit
#endif

import MetalKit
import GLKit


#if os(OSX)
typealias XGestureRecognizerDelegate = NSGestureRecognizerDelegate
typealias XViewController = NSViewController
typealias XGestureRecognizer = NSGestureRecognizer
typealias XPanGestureRecognizer = NSPanGestureRecognizer
#elseif os(iOS)
typealias XGestureRecognizerDelegate = UIGestureRecognizerDelegate
typealias XViewController = UIViewController
typealias XGestureRecognizer = UIGestureRecognizer
typealias XPanGestureRecognizer = UIPanGestureRecognizer
#endif


//
//	DrawViewController
//

class DrawViewController: XViewController, MTKViewDelegate, XGestureRecognizerDelegate {

	struct Point {
		var x, y: Float
		var vx, vy: Float
	}

	struct Uniforms {
		var modelViewProjectionMatrix: GLKMatrix4
	}

	@IBOutlet var drawView: MTKView!
	var commandQueue: MTLCommandQueue!
	var canvasTexture: MTLTexture!
	var renderingTexture: MTLTexture!
	var imageRenderer: ImageRenderer!
	lazy var device: Device = { return Device.sharedDevice }()
	var marble: ImageNode!

	override func viewDidLoad() {
		super.viewDidLoad()

		assert(drawView != nil)
		let device = MTLCreateSystemDefaultDevice()!
		drawView.device = self.device.device
		drawView.delegate = self
		drawView.enableSetNeedsDisplay = true

		marble = ImageNode(image: XImage(named: "BlueMarble.png")!, frame: Rect(-1024,-512,2048,1024))
		

#if os(OSX)
		let panGesture = NSPanGestureRecognizer(target: self, action: "panGesture:")
		self.drawView.addGestureRecognizer(panGesture)

		let magnificationGesture = NSMagnificationGestureRecognizer(target: self, action: "magnificationGesture:")
		self.drawView.addGestureRecognizer(magnificationGesture)

		let singleClickGesture = NSClickGestureRecognizer(target: self, action: "singleClickGesture:")
		singleClickGesture.numberOfClicksRequired = 1
		singleClickGesture.delegate = self
		self.drawView.addGestureRecognizer(singleClickGesture)

		let doubleClickGesture = NSClickGestureRecognizer(target: self, action: "doubleClickGesture:")
		doubleClickGesture.numberOfClicksRequired = 2
		doubleClickGesture.delegate = self
		self.drawView.addGestureRecognizer(doubleClickGesture)
#endif

#if os(iOS)
		let panGesture = UIPanGestureRecognizer(target: self, action: "panGesture:")
		self.drawView.addGestureRecognizer(panGesture)
	
		let pinchGesture = UIPinchGestureRecognizer(target: self, action: "pinchGesture:")
		self.drawView.addGestureRecognizer(pinchGesture)

		let singleTapGesture = UITapGestureRecognizer(target: self, action: "singleTapGesture:")
		singleTapGesture.numberOfTapsRequired = 1
		self.drawView.addGestureRecognizer(singleTapGesture)
	
		let doubleTapGesture = UITapGestureRecognizer(target: self, action: "doubleTapGesture:")
		doubleTapGesture.numberOfTapsRequired = 2
		self.drawView.addGestureRecognizer(doubleTapGesture)

		singleTapGesture.requireGestureRecognizerToFail(doubleTapGesture)
#endif


		self.transform = GLKMatrix4Identity
		self.scaling = 1.0
		self.translating = GLKVector2Make(0, 0)

		
		self.commandQueue = device.newCommandQueue()
		self.setNeedsDisplay()
	}

#if os(OSX)
	override var representedObject: AnyObject? {
		didSet {
		}
	}
#endif

	// MARK: -

	func setupMetal() -> Bool {
#if os(OSX)
		assert(self.viewLoaded)
#else
		assert(self.isViewLoaded())
#endif
		self.drawView.colorPixelFormat = .BGRA8Unorm
		return true
	}

    func drawInMTKView(view: MTKView) {
		print("drawInMTKView")
		guard let drawable = self.drawView.currentDrawable else { return }
		guard let renderPassDescriptor = self.drawView.currentRenderPassDescriptor else { return }

		renderPassDescriptor.colorAttachments[0].texture = drawable.texture
		renderPassDescriptor.colorAttachments[0].clearColor = MTLClearColorMake(0.9, 0.9, 0.9, 1)
		renderPassDescriptor.colorAttachments[0].loadAction = .Clear
		renderPassDescriptor.colorAttachments[0].storeAction = .Store

		let commandBuffer = commandQueue.commandBuffer()
		let commandEncoder = commandBuffer.renderCommandEncoderWithDescriptor(renderPassDescriptor)
		
		let renderContext = RenderContext(device: self.device, commandEncoder: commandEncoder, transform: self.currentTransform)
		
		marble.recursiveRender(renderContext, transform: GLKMatrix4Identity)
		commandEncoder.endEncoding()
		
		commandBuffer.presentDrawable(drawable)
		commandBuffer.commit()
	}

	func setNeedsDisplay() {
		self.drawView.setNeedsDisplayInRect(self.drawView.bounds)
	}

    func mtkView(view: MTKView, drawableSizeWillChange size: CGSize) {
		self.setNeedsDisplay()
	}
	
	
	// MARK: -

	var transform = GLKMatrix4Identity

	var scaling: Float = 1.0
	var translating: GLKVector2 = GLKVector2Make(0, 0)
	var zoomPoint: GLKVector2 = GLKVector2Make(0, 0)
	var activeGestures = Set<XGestureRecognizer>()

	var projectionMatrix: GLKMatrix4 {
		let bounds = self.drawView.bounds
		let width = Float(CGRectGetWidth(bounds))
		let height = Float(CGRectGetHeight(bounds))
		let halfWidth = width * 0.5
		let halfHeight = height * 0.5
		return GLKMatrix4MakeOrtho(-halfWidth, halfWidth, halfHeight, -halfHeight, -1, 1)
	}

	func gestureBegan(gesture: XGestureRecognizer) {
		self.activeGestures.insert(gesture)
		self.drawView.paused = false
	}

	func gestureEnded(gesture: XGestureRecognizer) {
		self.activeGestures.remove(gesture)
		if self.activeGestures.count == 0 {
			self.drawView.paused = true
			self.transform = self.transform * self.operatingTransform
			self.zoomPoint = GLKVector2Make(0, 0)
			self.translating = GLKVector2Make(0, 0)
			self.scaling = 1.0
			print("transform updated")
		}
	}

	var operatingTransform: GLKMatrix4 {
		var t = GLKMatrix4Identity
		t = GLKMatrix4Translate(t, self.zoomPoint.x * (1.0-self.scaling), self.zoomPoint.y * (1.0-self.scaling), 0.0)
		t = GLKMatrix4Translate(t, self.translating.x * self.scaling, self.translating.y * self.scaling, 0.0)
		t = GLKMatrix4Scale(t, self.scaling, self.scaling, 1)
		return t
	}

	var currentTransform: GLKMatrix4 {
		return self.projectionMatrix * self.transform * self.operatingTransform
	}

	var transformToFit: GLKMatrix4 {
		let imageSize = CGSizeMake(CGFloat(self.canvasTexture.width), CGFloat(self.canvasTexture.height))
		let viewBounds = self.drawView.bounds
		let rectToFit = CGRectMakeAspectFit(imageSize, viewBounds)
		var t = CGAffineTransformIdentity
		t = CGAffineTransformScale(t, rectToFit.size.width / imageSize.width, rectToFit.size.height / imageSize.height)
		return GLKMatrix4(t)
	}

	var transformToFill: GLKMatrix4 {
		let imageSize = CGSizeMake(CGFloat(self.canvasTexture.width), CGFloat(self.canvasTexture.height))
		let viewBounds = self.drawView.bounds
		let rectToFit = CGRectMakeAspectFill(imageSize, viewBounds)
		var t = CGAffineTransformIdentity
		t = CGAffineTransformScale(t, rectToFit.size.width / imageSize.width, rectToFit.size.height / imageSize.height)
		return GLKMatrix4(t)
	}
	
	// MARK: -
	
	func panGesture(gesture: XPanGestureRecognizer) {
		let translation = gesture.translationInView(self.drawView)
		let scaleFactor = CGFloat((self.transform * self.operatingTransform).scaleFactor)
		let translating = GLKVector2Make(Float(translation.x * (1.0 / scaleFactor)), Float(translation.y * (1.0 / scaleFactor)))

		switch gesture.state {
		case .Began:
			self.gestureBegan(gesture)
			self.translating = translating
			break
		case .Changed:
			self.translating = translating
			break
		case .Ended:
			self.activeGestures.remove(gesture)
			self.gestureEnded(gesture)
			break
		case .Cancelled:
			self.activeGestures.remove(gesture)
			print("pan - Cancelled")
			self.gestureEnded(gesture)
			break
		default:
			break
		}
		self.setNeedsDisplay()
	}

	var centerPoint: CGPoint {
		return CGPointMake(CGRectGetMidX(self.drawView.bounds), CGRectGetMidY(self.drawView.bounds))
	}

#if os(OSX)
	func magnificationGesture(gesture: NSMagnificationGestureRecognizer) {

		let magnification = gesture.magnification
		let scaling = Float((magnification >= 0.0) ? (1.0 + magnification) : 1.0 / (1.0 - magnification))
		let locationPt = gesture.locationInView(self.drawView)
		let scenePt = self.locationToScene(locationPt)

		switch gesture.state {
		case .Began:
			self.gestureBegan(gesture)
			self.scaling = scaling
			self.zoomPoint = scenePt
		case .Changed:
			self.scaling = scaling
		case .Ended:
			self.gestureEnded(gesture)
		case .Cancelled:
			self.gestureEnded(gesture)
		default: break;
		}
		self.setNeedsDisplay()
	}
#endif

#if os(iOS)
	func pinchGesture(gesture: UIPinchGestureRecognizer) {
		let scaling = Float(gesture.scale)
		let locationPt = gesture.locationInView(self.drawView)
		let scenePt = self.locationToScene(locationPt)

		switch gesture.state {
		case .Began:
			self.gestureBegan(gesture)
			self.scaling = scaling
			self.zoomPoint = scenePt
		case .Changed:
			self.scaling = scaling
		case .Ended:
			self.gestureEnded(gesture)
		case .Cancelled:
			self.gestureEnded(gesture)
		default: break;
		}
		self.setNeedsDisplay()
	}
#endif

#if os(OSX)
	func gestureRecognizer(gestureRecognizer: NSGestureRecognizer, shouldRequireFailureOfGestureRecognizer otherGestureRecognizer: NSGestureRecognizer) -> Bool {
		if let gestureRecognizer1 = gestureRecognizer as? NSClickGestureRecognizer,
		   let gestureRecognizer2 = otherGestureRecognizer as? NSClickGestureRecognizer
		   where gestureRecognizer1.numberOfClicksRequired == 1 &&
				 gestureRecognizer2.numberOfClicksRequired == 2 {
			return true
		}
		return false
	}
#endif
	
#if os(OSX)
	func singleClickGesture(gesture: NSClickGestureRecognizer) {
		let locationPt = gesture.locationInView(self.drawView)
		switch gesture.state {
		case .Ended:
			let scenePt = self.locationToScene(locationPt)
			print("scene: (\(scenePt.x), \(scenePt.x))")
			break
		default:
			break
		}
	}
#endif

#if os(iOS)
	func singleTapGesture(gesture: UITapGestureRecognizer) {
		let locationPt = gesture.locationInView(self.drawView)
		switch gesture.state {
		case .Ended:
			let scenePt = self.locationToScene(locationPt)
			print("scene: (\(scenePt.x), \(scenePt.x))")
			break
		default:
			break
		}
	}
#endif

#if os(OSX)
	func doubleClickGesture(gesture: NSClickGestureRecognizer) {
		if gesture.state == .Ended {
			self.transform = self.transformToFit
			self.scaling = 1.0
			self.translating = GLKVector2Make(0, 0)
			self.setNeedsDisplay()
		}
		print("double")
	}
#endif

#if os(iOS)
	func doubleTapGesture(gesture: UITapGestureRecognizer) {
		switch gesture.state {
		case .Ended:
			self.transform = self.transformToFit
			self.scaling = 1.0
			self.translating = GLKVector2Make(0, 0)
			self.setNeedsDisplay()
			break
		default:
			break
		}
	}
#endif

	func locationToScene(location: CGPoint) -> GLKVector2 {
		let bounds = self.drawView.bounds
		let x = (location.x / CGRectGetWidth(bounds) * 2.0) - 1.0
		let y = -((location.y / CGRectGetHeight(bounds) * 2.0) - 1.0)
		let normalizedDeviceCoordinatesPt = GLKVector2Make(Float(x), Float(y))
		let scenePt = self.currentTransform.invert * normalizedDeviceCoordinatesPt
		return scenePt
	}
}

