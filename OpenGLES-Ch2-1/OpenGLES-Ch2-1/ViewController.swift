//
//  ViewController.swift
//  OpenGLES-Ch2-1
//
//  Created by Lizhen Hu on 03/03/2018.
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
    
    var vertexBufferID = GLuint()
    
    let vertices:[SceneVertex] = [
        SceneVertex(positionCoords: GLKVector3Make(-0.5, -0.5, 0)),
        SceneVertex(positionCoords: GLKVector3Make(0.5, -0.5, 0)),
        SceneVertex(positionCoords: GLKVector3Make(-0.5, 0.5, 0)),
    ]
    
    deinit {
        let view = self.view as! GLKView
        EAGLContext.setCurrent(view.context)
        
        // Delete buffers that aren't needed
        if vertexBufferID != 0 {
            glDeleteBuffers(1, &vertexBufferID)
            vertexBufferID = 0
        }
        
        // Stop using the context created in viewDidLoad()
        EAGLContext.setCurrent(nil)
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Get GLKView instance
        let view = self.view as! GLKView
        
        // Create an OpenGL ES 2.0 context and provide it to the view
        view.context = EAGLContext(api: .openGLES3)!  // "Embedded Apple GL"
        
        // Make the new context current
        EAGLContext.setCurrent(view.context)
        
        // Set constants to be used for all subsequent rendering
        self.baseEffect.useConstantColor = GLboolean(GL_TRUE)
        self.baseEffect.constantColor = GLKVector4Make(0, 1, 0, 1)
        
        // Set the background color stored in the current context
        glClearColor(1, 1, 1, 1)
        
        // Generate, bind, and initialize contents of a buffer to be stored in GPU memory
        glGenBuffers(1, &vertexBufferID)
        glBindBuffer(GLenum(GL_ARRAY_BUFFER), vertexBufferID)
        glBufferData(
            GLenum(GL_ARRAY_BUFFER),                          // Initialize buffer contents
            vertices.count * MemoryLayout<SceneVertex>.size,  // Number of bytes to copy
            vertices,                                         // Address of bytes to copy
            GLenum(GL_STATIC_DRAW)                            // Cache in GPU memory
        )
    }
    
    // GLKView delegate method: Called by the view controller's view
    // whenever Cocoa Touch asks the view controller's view to
    // draw itself. (In this case, render into a Frame Buffer that
    // share memory with a Core Animation Layer)
    override func glkView(_ view: GLKView, drawIn rect: CGRect) {
        self.baseEffect.prepareToDraw()
        
        // Clear Frame Buffer (erase previous drawing)
        glClear(GLbitfield(GL_COLOR_BUFFER_BIT))
        
        // Enable use of currently bound vertex buffer
        glEnableVertexAttribArray(GLuint(GLKVertexAttrib.position.rawValue))
        
        // Define an array of generic vertex attribute data
        glVertexAttribPointer(
            GLuint(GLKVertexAttrib.position.rawValue),  // This index is used to provide the vertex position to a shader
            3,                                          // Three components per vertex
            GLenum(GL_FLOAT),                           // Data is floating point
            GLboolean(GL_FALSE),                        // No fixed point scaling
            GLsizei(MemoryLayout<SceneVertex>.size),    // No gaps in data
            nil                                         // nil tells GPU to start at beginning of bound buffer
        )
        
        // Draw triangles using the first three vertices in the
        // currently bound vertex buffer
        glDrawArrays(
            GLenum(GL_TRIANGLES),
            0,                       // Start with first vertex in currently bound buffer
            GLsizei(vertices.count)  // Use three vertices from currently bound buffer
        )
    }
}
