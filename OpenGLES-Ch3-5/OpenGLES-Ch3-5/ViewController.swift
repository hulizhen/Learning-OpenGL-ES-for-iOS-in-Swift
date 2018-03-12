//
//  ViewController.swift
//  OpenGLES-Ch3-5
//
//  Created by Lizhen Hu on 12/03/2018.
//  Copyright © 2018 Lizhen Hu. All rights reserved.
//

import UIKit
import GLKit

extension GLKEffectPropertyTexture {
    func setParameter(parameterID: GLenum, with value: GLint) {
        glBindTexture(target.rawValue, name)
        glTexParameteri(target.rawValue, parameterID, value)
    }
}

struct SceneVertex {
    var positionCoords: GLKVector3
    var textureCoords: GLKVector2
}

class ViewController: GLKViewController {
    var baseEffect = GLKBaseEffect()  // Create a base effect that provides standard OpenGL ES 2.0 Shading Language programs
    var vertexBuffer: AGLKVertexAttribArrayBuffer!
    
    // Define vertex data for a triangle to use in example
    var vertices:[SceneVertex] = [
        SceneVertex(positionCoords: GLKVector3Make(-1, -0.67, 0), textureCoords: GLKVector2Make(0, 0)),
        SceneVertex(positionCoords: GLKVector3Make( 1, -0.67, 0), textureCoords: GLKVector2Make(1, 0)),
        SceneVertex(positionCoords: GLKVector3Make(-1,  0.67, 0), textureCoords: GLKVector2Make(0, 1)),
        
        SceneVertex(positionCoords: GLKVector3Make( 1, -0.67, 0), textureCoords: GLKVector2Make(1, 0)),
        SceneVertex(positionCoords: GLKVector3Make(-1,  0.67, 0), textureCoords: GLKVector2Make(0, 1)),
        SceneVertex(positionCoords: GLKVector3Make( 1,  0.67, 0), textureCoords: GLKVector2Make(1, 1)),
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
        view.context = AGLKContext(api: .openGLES2)!
        
        // Make the new context current
        AGLKContext.setCurrent(view.context)
        
        // Determine how many textures can be combined in a single pass.
        // Use `GL_MAX_TEXTURE_IMAGE_UNITS` instead of `GL_MAX_TEXTURE_UNITS`,
        // according to https://www.khronos.org/opengl/wiki/Common_Mistakes.
        var units: GLint = 0;
        glGetIntegerv(GLenum(GL_MAX_TEXTURE_IMAGE_UNITS), &units)
        print("\(units) texture uints can be combine in a single pass")

        // Set constants to be used for all subsequent rendering
        self.baseEffect.useConstantColor = GLboolean(GL_TRUE)
        self.baseEffect.constantColor = GLKVector4Make(1, 1, 1, 1)
        
        // Set the background color stored in the current context
        (view.context as! AGLKContext).clearColor = GLKVector4Make(0, 0, 0, 1)
        
        // Create vertex buffer containing vertices to draw
        vertexBuffer = AGLKVertexAttribArrayBuffer(
            attribStride: GLsizei(MemoryLayout<SceneVertex>.stride),
            numberOfVertices: GLsizei(vertices.count),
            data: vertices,
            usage: GLenum(GL_STATIC_DRAW)
        )
        
        // Setup textures
        let imageRef0 = UIImage(named:"leaves")!.cgImage!
        let textureInfo0 = try! GLKTextureLoader.texture(with: imageRef0, options: [GLKTextureLoaderOriginBottomLeft: true as NSNumber])
        baseEffect.texture2d0.name = textureInfo0.name
        baseEffect.texture2d0.target = GLKTextureTarget(rawValue: textureInfo0.target)!
        
        let imageRef1 = UIImage(named:"beetle")!.cgImage!
        let textureInfo1 = try! GLKTextureLoader.texture(with: imageRef1, options: [GLKTextureLoaderOriginBottomLeft: true as NSNumber])
        baseEffect.texture2d1.name = textureInfo1.name
        baseEffect.texture2d1.target = GLKTextureTarget(rawValue: textureInfo1.target)!
        baseEffect.texture2d1.envMode = GLKTextureEnvMode.decal

        // Enable fragment blending with Frame Buffer contents
        glEnable(GLenum(GL_BLEND))
        glBlendFunc(GLenum(GL_SRC_ALPHA), GLenum(GL_ONE_MINUS_SRC_ALPHA))
    }
    
    // GLKView delegate method: Called by the view controller's view
    // whenever Cocoa Touch asks the view controller's view to
    // draw itself. (In this case, render into a Frame Buffer that
    // share memory with a Core Animation Layer)
    override func glkView(_ view: GLKView, drawIn rect: CGRect) {
        // Clear Frame Buffer (erase previous drawing)
        (view.context as! AGLKContext).clear(GLbitfield(GL_COLOR_BUFFER_BIT))
        
        vertexBuffer.prepareToDraw(
            withAttrib: GLuint(GLKVertexAttrib.position.rawValue),
            numberOfCoordinates: 3,
            attribOffset: GLsizeiptr(0),
            shouldEnable: true
        )
        vertexBuffer.prepareToDraw(
            withAttrib: GLuint(GLKVertexAttrib.texCoord0.rawValue),
            numberOfCoordinates: 2,
            attribOffset: GLsizeiptr(MemoryLayout<GLfloat>.size * 4),  // FIXME: The offset of `textureCoords` in struct `SceneVertex`.
            shouldEnable: true
        )
        vertexBuffer.prepareToDraw(
            withAttrib: GLuint(GLKVertexAttrib.texCoord1.rawValue),
            numberOfCoordinates: 2,
            attribOffset: GLsizeiptr(MemoryLayout<GLfloat>.size * 4),  // FIXME: The offset of `textureCoords` in struct `SceneVertex`.
            shouldEnable: true
        )
        baseEffect.prepareToDraw()

        // Draw triangles using the first three vertices in the
        // currently bound vertex buffer
        vertexBuffer.drawArray(
            withMode: GLenum(GL_TRIANGLES),
            startVertexIndex: 0,
            numberOfVertices: GLsizei(vertices.count)
        )
    }
}
