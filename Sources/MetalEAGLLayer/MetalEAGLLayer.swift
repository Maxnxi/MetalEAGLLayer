// The Swift Programming Language
// https://docs.swift.org/swift-book

//
//  MetalEAGLLayer.swift
//
//  Created by Maksim Ponomarev on 8/28/25.
//

import QuartzCore
import Metal
import UIKit


final class MetalEAGLLayer: CAEAGLLayer {
	let metalLayer: CAMetalLayer
	
	override init() {
		metalLayer = CAMetalLayer()
		super.init()
		setupMetalLayer()
	}
	
	required init?(coder: NSCoder) {
		metalLayer = CAMetalLayer()
		super.init(coder: coder)
		setupMetalLayer()
	}
	
	override init(layer: Any) {
		metalLayer = CAMetalLayer()
		super.init(layer: layer)
		setupMetalLayer()
	}
	
	private func setupMetalLayer() {
		addSublayer(metalLayer)
		// Set default values that make sense
		metalLayer.framebufferOnly = true
		// Inherit scale from parent layer
		metalLayer.contentsScale = contentsScale
	}
	
	override func layoutSublayers() {
		super.layoutSublayers()
		metalLayer.frame = bounds
		// Update drawable size when bounds change
		updateDrawableSize()
	}
	
	override var contentsScale: CGFloat {
		didSet {
			metalLayer.contentsScale = contentsScale
			updateDrawableSize()
		}
	}
	
	private func updateDrawableSize() {
		// Only update if we have valid bounds
		guard bounds.width > 0 && bounds.height > 0 else { return }
		
		metalLayer.drawableSize = CGSize(
			width: bounds.width * contentsScale,
			height: bounds.height * contentsScale
		)
	}
	
	// MARK: - Metal Layer Properties
	
	var nextDrawable: CAMetalDrawable? {
		return metalLayer.nextDrawable()
	}
	
	var pixelFormat: MTLPixelFormat {
		get { return metalLayer.pixelFormat }
		set { metalLayer.pixelFormat = newValue }
	}
	
	var device: MTLDevice? {
		get { return metalLayer.device }
		set { metalLayer.device = newValue }
	}
	
	var framebufferOnly: Bool {
		get { return metalLayer.framebufferOnly }
		set { metalLayer.framebufferOnly = newValue }
	}
	
	var drawableSize: CGSize {
		get { return metalLayer.drawableSize }
		set { metalLayer.drawableSize = newValue }
	}
	
	override var presentsWithTransaction: Bool {
		get { return metalLayer.presentsWithTransaction }
		set { metalLayer.presentsWithTransaction = newValue }
	}
	
	var colorspace: CGColorSpace? {
		get { return metalLayer.colorspace }
		set { metalLayer.colorspace = newValue }
	}
	
	@available(iOS 16.0, *)
	override var wantsExtendedDynamicRangeContent: Bool {
		get { return metalLayer.wantsExtendedDynamicRangeContent }
		set { metalLayer.wantsExtendedDynamicRangeContent = newValue }
	}
	
	// MARK: - EAGL Compatibility
	
	func setDrawableProperties(_ properties: [AnyHashable: Any]!) {
		guard let properties = properties else { return }
		
		if let retainedBacking = properties[kEAGLDrawablePropertyRetainedBacking] as? Bool {
			metalLayer.framebufferOnly = !retainedBacking
		}
		
		if let colorFormat = properties[kEAGLDrawablePropertyColorFormat] as? String {
			metalLayer.pixelFormat = metalPixelFormat(from: colorFormat)
		}
	}
	
	func drawableProperties() -> [AnyHashable: Any]! {
		var properties: [AnyHashable: Any] = [:]
		
		properties[kEAGLDrawablePropertyColorFormat] = eaglColorFormat(from: metalLayer.pixelFormat)
		properties[kEAGLDrawablePropertyRetainedBacking] = !metalLayer.framebufferOnly
		
		return properties
	}
	
	// MARK: - Format Conversion Helpers
	
	private func metalPixelFormat(from eaglFormat: String) -> MTLPixelFormat {
		switch eaglFormat {
		case kEAGLColorFormatRGBA8:
			return .bgra8Unorm
		case kEAGLColorFormatRGB565:
			return .b5g6r5Unorm
		case kEAGLColorFormatSRGBA8:
			if #available(iOS 10.0, *) {
				return .bgra8Unorm_srgb
			} else {
				return .bgra8Unorm
			}
		default:
			return .bgra8Unorm
		}
	}
	
	private func eaglColorFormat(from metalFormat: MTLPixelFormat) -> String {
		switch metalFormat {
		case .bgra8Unorm:
			return kEAGLColorFormatRGBA8
		case .b5g6r5Unorm:
			return kEAGLColorFormatRGB565
		case .bgra8Unorm_srgb:
			if #available(iOS 10.0, *) {
				return kEAGLColorFormatSRGBA8
			} else {
				return kEAGLColorFormatRGBA8
			}
		default:
			return kEAGLColorFormatRGBA8
		}
	}
}
