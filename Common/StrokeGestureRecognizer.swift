//
//  StrokeGestureRecognizer.swift
//  Metal2D
//
//  Created by Kaz Yoshikawa on 1/12/16.
//
//

#if os(iOS)

import UIKit
import UIKit.UIGestureRecognizerSubclass

//
//	StrokeGestureRecognizerDelegate
//

@objc protocol StrokeGestureRecognizerDelegate {
	func strokeTouchesBegan(gesture: StrokeGestureRecognizer, touches: Set<UITouch>, withEvent event: UIEvent)
	func strokeTouchesMoved(gesture: StrokeGestureRecognizer, touches: Set<UITouch>, withEvent event: UIEvent)
	func strokeTouchesEnded(gesture: StrokeGestureRecognizer, touches: Set<UITouch>, withEvent event: UIEvent)
	func strokeTouchesCancelled(gesture: StrokeGestureRecognizer, touches: Set<UITouch>, withEvent event: UIEvent)
}


//
//	StrokeGestureRecognizer
//

class StrokeGestureRecognizer: UIPanGestureRecognizer {

	weak var strokeDelegate: StrokeGestureRecognizerDelegate?

	override func touchesBegan(touches: Set<UITouch>, withEvent event: UIEvent) {
		self.strokeDelegate?.strokeTouchesBegan(self, touches: touches, withEvent: event)
		super.touchesBegan(touches, withEvent: event)
	}

	override func touchesMoved(touches: Set<UITouch>, withEvent event: UIEvent) {
		self.strokeDelegate?.strokeTouchesMoved(self, touches: touches, withEvent: event)
		super.touchesMoved(touches, withEvent: event)
	}

	override func touchesEnded(touches: Set<UITouch>, withEvent event: UIEvent) {
		self.strokeDelegate?.strokeTouchesEnded(self, touches: touches, withEvent: event)
		super.touchesEnded(touches, withEvent: event)
	}

	override func touchesCancelled(touches: Set<UITouch>, withEvent event: UIEvent) {
		self.strokeDelegate?.strokeTouchesCancelled(self, touches: touches, withEvent: event)
		super.touchesCancelled(touches, withEvent: event)
	}

}

#endif

#if os(OSX)

import Cocoa

//
//	StrokeGestureRecognizerDelegate
//

@objc protocol StrokeGestureRecognizerDelegate {
}

#endif
