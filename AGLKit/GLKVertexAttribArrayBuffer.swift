//
//  AGLKVertexAttribArrayBuffer.swift
//  OpenGLES-Ch2-3
//
//  Created by Lizhen Hu on 04/03/2018.
//  Copyright © 2018 Lizhen Hu. All rights reserved.
//

import UIKit

class AGLKVertexAttribArrayBuffer: NSObject {
    var stride: GLsizei = 0
    var bufferSizeBytes: GLsizeiptr = 0
    var name: GLuint = 0
    
    deinit {
        guard name != 0 else { return }
        glDeleteBuffers(1, &name)
        name = 0
    }
    
    // Creates a vertex attribute array buffer in the current OpenGL ES context
    // for the thread upon which this method is called.
    init(attribStride stride:GLsizei, numberOfVertices count:GLsizei, data:UnsafeRawPointer, usage:GLenum) {
        assert(stride > 0)
        assert(count > 0)
        
        self.stride = stride
        bufferSizeBytes = GLsizeiptr(stride * count)
        
        glGenBuffers(1, &name)
        glBindBuffer(GLenum(GL_ARRAY_BUFFER), name)
        glBufferData(GLenum(GL_ARRAY_BUFFER), bufferSizeBytes, data, usage)
        
        if name == 0 {
            assert(false, "Failed to generate name")
        }
    }

    func reinit(attribStride stride:GLsizei, numberOfVertices count:GLsizei, data:UnsafeRawPointer) {
        assert(stride > 0)
        assert(count > 0)
        
        self.stride = stride
        bufferSizeBytes = GLsizeiptr(stride * count)
        
        glBindBuffer(GLenum(GL_ARRAY_BUFFER), name)
        glBufferData(GLenum(GL_ARRAY_BUFFER), bufferSizeBytes, data, GLenum(GL_DYNAMIC_DRAW))
        
        if name == 0 {
            assert(false, "Failed to generate name")
        }
    }

    // A vertex attribute array buffer must be prepared when your
    // application wants to use the buffer to render any geometry.
    // When your application prepares an buffer, some OpenGL ES state
    // is altered to allow bind the buffer and configure pointers.
    func prepareToDraw(withAttrib index:GLuint, numberOfCoordinates count:GLint, attribOffset offset:GLsizeiptr, shouldEnable:Bool) {
        assert(stride > 0)
        assert(count > 0 && count < 4)
        assert(name != 0, "Invalid name")
        
        glBindBuffer(GLenum(GL_ARRAY_BUFFER), name)

        if shouldEnable {
            glEnableVertexAttribArray(index)
        }
        
        glVertexAttribPointer(
            index,                                           // This index is used to provide the vertex position to a shader
            count,                                           // Three components per vertex
            GLenum(GL_FLOAT),                                // Data is floating point
            GLboolean(GL_FALSE),                             // No fixed point scaling
            stride,
            UnsafeRawPointer(bitPattern: offset)             // Offset from start of each vertex to first coord for attribute
        )
        
        let error = glGetError()
        assert(error == GL_NO_ERROR, "GL Error: \(error)")
    }
    
    // Submits the drawing command identified by mode and instructs
    // OpenGL ES to use count vertices from the buffer starting from
    // the vertex at index first. Vertex indices start at 0.
    func drawArray(withMode mode:GLenum, startVertexIndex index:GLint, numberOfVertices count:GLsizei) {
        assert(bufferSizeBytes >= GLsizei(index + count) * stride, "Attempt to draw more vertex data than available.")
        glDrawArrays(mode, index, count);
    }
}
