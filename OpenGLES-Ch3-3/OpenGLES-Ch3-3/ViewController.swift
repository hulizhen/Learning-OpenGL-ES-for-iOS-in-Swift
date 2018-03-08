//
//  ViewController.swift
//  OpenGLES-Ch3-3
//
//  Created by Lizhen Hu on 08/03/2018.
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

class ViewController: GLKViewController, GLKViewControllerDelegate {
    var baseEffect = GLKBaseEffect()  // Create a base effect that provides standard OpenGL ES 2.0 Shading Language programs
    var vertexBuffer: AGLKVertexAttribArrayBuffer!
    var shouldUseLinearFilter = false
    var shouldAnimate = true
    var shouldRepeatTexture = true
    var sCoordinateOffset: GLfloat = 0
    
    // Define vertex data for a triangle to use in example
    var vertices:[SceneVertex] = [
        SceneVertex(positionCoords: GLKVector3Make(-0.5, -0.5, 0), textureCoords: GLKVector2Make(0, 0)),
        SceneVertex(positionCoords: GLKVector3Make(0.5, -0.5, 0), textureCoords: GLKVector2Make(1, 0)),
        SceneVertex(positionCoords: GLKVector3Make(-0.5, 0.5, 0), textureCoords: GLKVector2Make(0, 1)),
        ]
    
    // Define defualt vertex data to reset vertices when needed
    let defaultVertices:[SceneVertex] = [
        SceneVertex(positionCoords: GLKVector3Make(-0.5, -0.5, 0), textureCoords: GLKVector2Make(0, 0)),
        SceneVertex(positionCoords: GLKVector3Make(0.5, -0.5, 0), textureCoords: GLKVector2Make(1, 0)),
        SceneVertex(positionCoords: GLKVector3Make(-0.5, 0.5, 0), textureCoords: GLKVector2Make(0, 1)),
        ]
    
    // Provide storage for the vectors that control the direction
    // and distance that each vertex moves per update when animated
    var movementVertors:[GLKVector3] = [
        GLKVector3Make(-0.02, -0.01, 0),
        GLKVector3Make(0.01, -0.005, 0),
        GLKVector3Make(-0.01, 0.01, 0)
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
        
        self.delegate = self
        
        // Get GLKView instance
        let view = self.view as! GLKView
        
        // Create an OpenGL ES 2.0 context and provide it to the view
        view.context = AGLKContext(api: .openGLES2)!
        
        // Make the new context current
        AGLKContext.setCurrent(view.context)
        
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
            usage: GLenum(GL_DYNAMIC_DRAW)
        )
        
        // Setup texture
        if let imageRef = UIImage(named:"grid")?.cgImage {
            let textureInfo = try! GLKTextureLoader.texture(with: imageRef, options: nil)
            baseEffect.texture2d0.name = textureInfo.name
            baseEffect.texture2d0.target = GLKTextureTarget(rawValue: textureInfo.target)!
        } else {
            fatalError("Unable to load the image")
        }
    }
    
    // Update the current OpenGL ES context texture wrapping mode
    func updateTextureParameters() {
        baseEffect.texture2d0.setParameter(parameterID: GLenum(GL_TEXTURE_WRAP_S),
                                           with: (self.shouldRepeatTexture ? GL_REPEAT : GL_CLAMP_TO_EDGE))
        
        baseEffect.texture2d0.setParameter(parameterID: GLenum(GL_TEXTURE_MAG_FILTER),
                                           with: (self.shouldUseLinearFilter ? GL_LINEAR : GL_NEAREST))
    }

    // Update the position of vertex data to create a bouncing animation
    func updateAnimatedVertexPosition() {
        if shouldAnimate {
            // Animate the triangle vertex positions
            for i in 0..<3 {
                vertices[i].positionCoords.x += movementVertors[i].x
                if vertices[i].positionCoords.x >= 1 || vertices[i].positionCoords.x <= -1 {
                    movementVertors[i].x = -movementVertors[i].x;
                }
                vertices[i].positionCoords.y += movementVertors[i].y
                if vertices[i].positionCoords.y >= 1 || vertices[i].positionCoords.y <= -1 {
                    movementVertors[i].y = -movementVertors[i].y;
                }
                vertices[i].positionCoords.z += movementVertors[i].z
                if vertices[i].positionCoords.z >= 1 || vertices[i].positionCoords.z <= -1 {
                    movementVertors[i].z = -movementVertors[i].z;
                }
            }
        } else {
            // Restore the triangle vertex positions to defaults
            for i in 0..<3 {
                vertices[i].positionCoords.x = defaultVertices[i].positionCoords.x;
                vertices[i].positionCoords.y = defaultVertices[i].positionCoords.y;
                vertices[i].positionCoords.z = defaultVertices[i].positionCoords.z;
            }
        }
        
        // Adjust the S texture coordinates to slide texture and
        // reveal effect of texture repeat vs. clamp behavior
        for i in 0..<3 {
            vertices[i].textureCoords.s = defaultVertices[i].textureCoords.s + sCoordinateOffset
        }
    }
    
    func glkViewControllerUpdate(_ controller: GLKViewController) {
        updateAnimatedVertexPosition()
        updateTextureParameters()
        
        vertexBuffer.reinit(
            attribStride: GLsizei(MemoryLayout<SceneVertex>.stride),
            numberOfVertices: GLsizei(vertices.count),
            data: vertices
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
        
        vertexBuffer.prepareToDraw(
            withAttrib: GLuint(GLKVertexAttrib.texCoord0.rawValue),
            numberOfCoordinates: 2,
            attribOffset: GLsizeiptr(MemoryLayout<GLfloat>.size * 4),  // FIXME: The offset of `textureCoords` in struct `SceneVertex`.
            shouldEnable: true
        )
        
        // Draw triangles using the first three vertices in the
        // currently bound vertex buffer
        vertexBuffer.drawArray(
            withMode: GLenum(GL_TRIANGLES),
            startVertexIndex: 0,
            numberOfVertices: GLsizei(vertices.count)
        )
    }
    
    @IBAction func updateShouldUseLinearFilter(_ sender: UISwitch) {
        shouldUseLinearFilter = sender.isOn
    }
    
    @IBAction func updateShouldAnimate(_ sender: UISwitch) {
        shouldAnimate = sender.isOn
    }
    
    @IBAction func updateShouldRepeatTexture(_ sender: UISwitch) {
        shouldRepeatTexture = sender.isOn
    }
    
    @IBAction func updateSCoordinateOffset(_ sender: UISlider) {
        sCoordinateOffset = sender.value
    }
}
