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
	func strokeTouchesBegan(_ gesture: StrokeGestureRecognizer, touches: Set<UITouch>, withEvent event: UIEvent)
	func strokeTouchesMoved(_ gesture: StrokeGestureRecognizer, touches: Set<UITouch>, withEvent event: UIEvent)
	func strokeTouchesEnded(_ gesture: StrokeGestureRecognizer, touches: Set<UITouch>, withEvent event: UIEvent)
	func strokeTouchesCancelled(_ gesture: StrokeGestureRecognizer, touches: Set<UITouch>, withEvent event: UIEvent)
}


//
//	StrokeGestureRecognizer
//

class StrokeGestureRecognizer: UIPanGestureRecognizer {

	weak var strokeDelegate: StrokeGestureRecognizerDelegate?

	override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent) {
		self.strokeDelegate?.strokeTouchesBegan(self, touches: touches, withEvent: event)
		super.touchesBegan(touches, with: event)
	}

	override func touchesMoved(_ touches: Set<UITouch>, with event: UIEvent) {
		self.strokeDelegate?.strokeTouchesMoved(self, touches: touches, withEvent: event)
		super.touchesMoved(touches, with: event)
	}

	override func touchesEnded(_ touches: Set<UITouch>, with event: UIEvent) {
		self.strokeDelegate?.strokeTouchesEnded(self, touches: touches, withEvent: event)
		super.touchesEnded(touches, with: event)
	}

	override func touchesCancelled(_ touches: Set<UITouch>, with event: UIEvent) {
		self.strokeDelegate?.strokeTouchesCancelled(self, touches: touches, withEvent: event)
		super.touchesCancelled(touches, with: event)
	}

}

#endif

#if os(macOS)

import Cocoa

//
//	StrokeGestureRecognizerDelegate
//

@objc protocol StrokeGestureRecognizerDelegate {
}

#endif
