//
//  GeoUtils.swift
//  Metal2D
//
//  Created by Kaz Yoshikawa on 1/4/16.
//
//

import Foundation
import CoreGraphics
import QuartzCore
import GLKit

func CGRectMakeAspectFill(imageSize: CGSize, _ bounds: CGRect) -> CGRect {
	let result: CGRect
	let margin: CGFloat
	let horizontalRatioToFit = bounds.size.width / imageSize.width
	let verticalRatioToFit = bounds.size.height / imageSize.height
	let imageHeightWhenItFitsHorizontally = horizontalRatioToFit * imageSize.height
	let imageWidthWhenItFitsVertically = verticalRatioToFit * imageSize.width
	let minX = CGRectGetMinX(bounds)
	let minY = CGRectGetMinY(bounds)

	if (imageHeightWhenItFitsHorizontally > bounds.size.height) {
		margin = (imageHeightWhenItFitsHorizontally - bounds.size.height) * 0.5
		result = CGRectMake(minX, minY - margin, imageSize.width * horizontalRatioToFit, imageSize.height * horizontalRatioToFit)
	}
	else {
		margin = (imageWidthWhenItFitsVertically - bounds.size.width) * 0.5
		result = CGRectMake(minX - margin, minY, imageSize.width * verticalRatioToFit, imageSize.height * verticalRatioToFit)
	}
	return result;
}

func CGRectMakeAspectFit(imageSize: CGSize, _ bounds: CGRect) -> CGRect {
	let minX = CGRectGetMinX(bounds)
	let minY = CGRectGetMinY(bounds)
	let widthRatio = bounds.size.width / imageSize.width
	let heightRatio = bounds.size.height / imageSize.height
	let ratio = min(widthRatio, heightRatio)
	let width = imageSize.width * ratio
	let height = imageSize.height * ratio
	let xmargin = (bounds.size.width - width) / 2.0
	let ymargin = (bounds.size.height - height) / 2.0
	return CGRectMake(minX + xmargin, minY + ymargin, width, height)
}

func CGSizeMakeAspectFit(imageSize: CGSize, frameSize: CGSize) -> CGSize {
	let widthRatio = frameSize.width / imageSize.width
	let heightRatio = frameSize.height / imageSize.height
	let ratio = (widthRatio < heightRatio) ? widthRatio : heightRatio
	let width = imageSize.width * ratio
	let height = imageSize.height * ratio
	return CGSizeMake(width, height)
}

extension GLKMatrix4 {
	init(_ transform: CGAffineTransform) {
		let t = CATransform3DMakeAffineTransform(transform)
		self.init(m: (
				Float(t.m11), Float(t.m12), Float(t.m13), Float(t.m14),
				Float(t.m21), Float(t.m22), Float(t.m23), Float(t.m24),
				Float(t.m31), Float(t.m32), Float(t.m33), Float(t.m34),
				Float(t.m41), Float(t.m42), Float(t.m43), Float(t.m44)))
	}
	var scaleFactor : Float {
		return sqrt(m00 * m00 + m01 * m01 + m02 * m02)
	}
	var invert: GLKMatrix4 {
		var invertible: Bool = true
		let t = GLKMatrix4Invert(self, &invertible)
		if !invertible { print("not invertible") }
		return t
	}
	var description: String {
		return	"[ \(self.m00), \(self.m01), \(self.m02), \(self.m03) ;" +
				" \(self.m10), \(self.m11), \(self.m12), \(self.m13) ;" +
				" \(self.m20), \(self.m21), \(self.m22), \(self.m23) ;" +
				" \(self.m30), \(self.m31), \(self.m32), \(self.m33) ]"
	}
}

extension GLKVector2 {
	init(_ point: CGPoint) {
		self.init(v: (Float(point.x), Float(point.y)))
	}
	var description: String {
		return	"[ \(self.x), \(self.y) ]"
	}
}

extension GLKVector4 {
	var description: String {
		return	"[ \(self.x), \(self.y), \(self.z), \(self.w) ]"
	}
}

func * (l: GLKMatrix4, r: GLKMatrix4) -> GLKMatrix4 {
	return GLKMatrix4Multiply(l, r)
}

func + (l: GLKVector2, r: GLKVector2) -> GLKVector2 {
	return GLKVector2Add(l, r)
}

func * (l: GLKMatrix4, r: GLKVector2) -> GLKVector2 {
	let vector4 = GLKMatrix4MultiplyVector4(l, GLKVector4Make(r.x, r.y, 0.0, 1.0))
	return GLKVector2Make(vector4.x, vector4.y)
}


