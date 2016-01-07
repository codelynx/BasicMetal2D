//
//  DrawView.swift
//  Metal2D
//
//  Created by Kaz Yoshikawa on 12/29/15.
//
//


#if os(OSX)
import Cocoa
#elseif os(iOS)
import UIKit
#endif

import MetalKit


//
//	DrawView
//

class DrawView: MTKView {

#if os(OSX)
	override var flipped: Bool {
		return true
	}
#endif

}