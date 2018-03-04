//
//  AGLKView.swift
//  OpenGLES-Ch2-2
//
//  Created by Lizhen Hu on 04/03/2018.
//  Copyright © 2018 Lizhen Hu. All rights reserved.
//

import UIKit
import OpenGLES.ES2

@objc
protocol AGLKViewDelegate: AnyObject {
    func glkView(_ view: AGLKView, drawIn rect:CGRect)
}

// This class uses OpenGL ES to render pixel data into
// a Frame Buffer that shares pixel color storage with
// a Core Animation Layer.
class AGLKView: UIView {
    @IBOutlet weak var delegate: AGLKViewDelegate!
    var defaultFrameBuffer: GLuint = 0
    var colorRenderBuffer: GLuint = 0
    var drawableWidth: GLint {
        var backingWidth: GLint = 0
        glGetRenderbufferParameteriv(
            GLenum(GL_RENDERBUFFER),
            GLenum(GL_RENDERBUFFER_WIDTH),
            &backingWidth
        )
        return backingWidth
    }
    var drawableHeight: GLint {
        var backingHeight: GLint = 0
        glGetRenderbufferParameteriv(
            GLenum(GL_RENDERBUFFER),
            GLenum(GL_RENDERBUFFER_HEIGHT),
            &backingHeight
        )
        return backingHeight
    }
    
    // If the current context is different from the new one,
    // then delete OpenGL ES Frame Buffer resource in the old
    // context and recreate them in the new context.
    var context: EAGLContext! {
        set {
            let currentContext = EAGLContext.current()
            guard currentContext != newValue else { return }
            
            if currentContext != nil {
                // Delete any buffers previously created in old context
                if defaultFrameBuffer != 0 {
                    glDeleteFramebuffers(1, &defaultFrameBuffer)
                    defaultFrameBuffer = 0
                }
                if colorRenderBuffer != 0 {
                    glDeleteRenderbuffers(1, &colorRenderBuffer)
                    colorRenderBuffer = 0
                }
            }
            
            // Configure the new context with required buffers
            EAGLContext.setCurrent(newValue)
            
            if newValue != nil {
                glGenFramebuffers(1, &defaultFrameBuffer)
                glBindFramebuffer(GLenum(GL_FRAMEBUFFER), defaultFrameBuffer)
                
                glGenRenderbuffers(1, &colorRenderBuffer)
                glBindRenderbuffer(GLenum(GL_RENDERBUFFER), colorRenderBuffer)
                
                // Attach color render buffer to bound Frame buffer
                glFramebufferRenderbuffer(
                    GLenum(GL_FRAMEBUFFER),
                    GLenum(GL_COLOR_ATTACHMENT0),
                    GLenum(GL_RENDERBUFFER),
                    colorRenderBuffer
                )
            }
        }
        get {
            return EAGLContext.current()
        }
    }

    // Return the CALayer subclass to be used by CoreAnimation with this view
    override class var layerClass: AnyClass {
        return CAEAGLLayer.self
    }
    
    deinit {
        context = nil
    }
    
    // Designated initializer
    init(frame: CGRect, context: EAGLContext) {
        super.init(frame: frame)
        commonInit()
        
        self.context = context
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        commonInit()
    }
    
    func commonInit() {
        if let eaglLayer = self.layer as? CAEAGLLayer {
            eaglLayer.drawableProperties = [
                kEAGLDrawablePropertyRetainedBacking: false,
                kEAGLDrawablePropertyColorFormat: kEAGLColorFormatRGBA8
            ]
        }
    }
    
    // Called automatically whenever the receiver needs to redraw
    // the contents of its associated OpenGL ES Frame Buffer.
    // This method should not be called directly.Call `display()`
    // instead which configures OpenGL ES before calling.
    override func draw(_ rect: CGRect) {
        if let delegate = self.delegate {
            delegate.glkView(self, drawIn: rect)
        }
    }
    
    // Called automatically whenever a UIView is resized including
    // just after the view is added to a UIWindow.
    override func layoutSubviews() {
        super.layoutSubviews()
        
        if let eaglLayer = self.layer as? CAEAGLLayer {
            // Initialize the current Frame Buffer's pixel color buffer
            // so that it shares the corresponding Core Animation Layer's
            // pixel color storage.
            context.renderbufferStorage(Int(GL_RENDERBUFFER), from: eaglLayer)
            
            // Make the Color Render Buffer the current buffer for display
            glBindRenderbuffer(GLenum(GL_RENDERBUFFER), colorRenderBuffer)
            
            // Check for any errors configuring the render buffer
            let status = glCheckFramebufferStatus(GLenum(GL_FRAMEBUFFER))
            if status != GL_FRAMEBUFFER_COMPLETE {
                print("failed to make complete frame buffer object \(status)")
            }
        }
    }
    
    func display() {        
        glViewport(0, 0, self.drawableWidth, self.drawableHeight)
        draw(bounds)
        context.presentRenderbuffer(Int(GL_RENDERBUFFER))
    }
}
