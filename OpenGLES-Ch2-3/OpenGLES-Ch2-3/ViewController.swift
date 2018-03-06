//
//  ViewController.swift
//  OpenGLES-Ch2-3
//
//  Created by Lizhen Hu on 04/03/2018.
//  Copyright © 2018 Lizhen Hu. All rights reserved.
//

import UIKit
import GLKit

struct SceneVertex {
    var positionCoords: GLKVector3
}

class ViewController: GLKViewController {
    // Create a base effect that provides standard OpenGL ES 2.0 Shading Language programs
    var baseEffect = GLKBaseEffect()
    
    var vertexBuffer: AGLKVertexAttribArrayBuffer!
    
    let vertices:[SceneVertex] = [
        SceneVertex(positionCoords: GLKVector3Make(-0.5, -0.5, 0)),
        SceneVertex(positionCoords: GLKVector3Make(0.5, -0.5, 0)),
        SceneVertex(positionCoords: GLKVector3Make(-0.5, 0.5, 0)),
        ]
    
    deinit {
        // Make the view's context current
        let view = self.view as! GLKView
        AGLKContext.setCurrent(view.context)
        
        // Delete buffers that aren't needed
        vertexBuffer = nil
        
        // Stop using the context created in viewDidLoad()
        AGLKContext.setCurrent(nil)
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Get GLKView instance
        let view = self.view as! GLKView
        
        // Create an OpenGL ES 2.0 context and provide it to the view
        view.context = AGLKContext(api: .openGLES3)!
        
        // Make the new context current
        AGLKContext.setCurrent(view.context)
        
        // Set constants to be used for all subsequent rendering
        self.baseEffect.useConstantColor = GLboolean(GL_TRUE)
        self.baseEffect.constantColor = GLKVector4Make(0, 1, 0, 1)
        
        // Set the background color stored in the current context
        (view.context as! AGLKContext).clearColor = GLKVector4Make(1, 1, 1, 1)
        
        // Create vertex buffer containing vertices to draw
        vertexBuffer = AGLKVertexAttribArrayBuffer(
            attribStride: MemoryLayout<SceneVertex>.stride,
            numberOfVertices: GLsizei(vertices.count),
            data: vertices,
            usage: GLenum(GL_STATIC_DRAW)
        )
    }
    
    // GLKView delegate method: Called by the view controller's view
    // whenever Cocoa Touch asks the view controller's view to
    // draw itself. (In this case, render into a Frame Buffer that
    // share memory with a Core Animation Layer)
    override func glkView(_ view: GLKView, drawIn rect: CGRect) {
        self.baseEffect.prepareToDraw()
        
        // Clear Frame Buffer (erase previous drawing)
        (view.context as! AGLKContext).clear(GLbitfield(GL_COLOR_BUFFER_BIT))
        
        vertexBuffer.prepareToDraw(
            withAttrib: GLuint(GLKVertexAttrib.position.rawValue),
            numberOfCoordinates: 3,
            attribOffset: GLsizeiptr(0),
            shouldEnable: true
        )
        
        // Draw triangles using the first three vertices in the
        // currently bound vertex buffer
        vertexBuffer.drawArray(withMode: GLenum(GL_TRIANGLES), startVertexIndex: 0, numberOfVertices: 3)
    }
}
