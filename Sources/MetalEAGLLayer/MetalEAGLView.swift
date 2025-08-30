//
//  MetalEAGLView.swift
//  MetalEAGLLayer
//
//  Created by Maksim Ponomarev on 8/30/25.
//

import UIKit

class MetalEAGLView: UIView {
	private let metalLayer = MetalEAGLLayer()
	
	override init(frame: CGRect) {
		super.init(frame: frame)
		setupLayer()
	}
	
	required init?(coder: NSCoder) {
		super.init(coder: coder)
		setupLayer()
	}
	
	private func setupLayer() {
		metalLayer.device = MTLCreateSystemDefaultDevice()
		metalLayer.framebufferOnly = true
		layer.addSublayer(metalLayer)
	}
	
	override func layoutSubviews() {
		super.layoutSubviews()
		metalLayer.frame = bounds
	}
	
	// Expose layer for framework integration
	var renderingLayer: MetalEAGLLayer {
		return metalLayer
	}
}
