//
//  ViewController.swift
//  OpenGLES-Ch3-6
//
//  Created by Lizhen Hu on 13/03/2018.
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

extension GLKMatrix4 {
    var array: [Float] {
        return (0..<16).map { i in
            self[i]
        }
    }
}

extension GLKMatrix3 {
    var array: [Float] {
        return (0..<9).map { i in
            self[i]
        }
    }
}

struct SceneVertex {
    var positionCoords: GLKVector3
    var normalCoords: GLKVector3
    var textureCoords: GLKVector2
}

enum Uniform: GLint {
    case modelViewProjectionMatrix
    case normalMatrix
    case texture0Sampler2D
    case texture1Sampler2D
    case numberOfUniforms
}

class ViewController: GLKViewController {
    var baseEffect = GLKBaseEffect()  // Create a base effect that provides standard OpenGL ES 2.0 Shading Language programs
    var vertexBuffer: AGLKVertexAttribArrayBuffer!
    var program: GLuint = 0
    var uniforms: [GLint] = [GLint](repeating: 0, count: Int(Uniform.numberOfUniforms.rawValue))
    var modelViewProjectionMatrix: GLKMatrix4!
    var normalMatrix: GLKMatrix3!
    var rotation: GLfloat = 0

    // Define vertex data for a triangle to use in example
    var vertices:[SceneVertex] = [
        SceneVertex(positionCoords: GLKVector3Make( 0.5, -0.5, -0.5), normalCoords: GLKVector3Make( 1.0,  0.0,  0.0), textureCoords: GLKVector2Make(0.0, 0.0)),
        SceneVertex(positionCoords: GLKVector3Make( 0.5,  0.5, -0.5), normalCoords: GLKVector3Make( 1.0,  0.0,  0.0), textureCoords: GLKVector2Make(1.0, 0.0)),
        SceneVertex(positionCoords: GLKVector3Make( 0.5, -0.5,  0.5), normalCoords: GLKVector3Make( 1.0,  0.0,  0.0), textureCoords: GLKVector2Make(0.0, 1.0)),
        SceneVertex(positionCoords: GLKVector3Make( 0.5, -0.5,  0.5), normalCoords: GLKVector3Make( 1.0,  0.0,  0.0), textureCoords: GLKVector2Make(0.0, 1.0)),
        SceneVertex(positionCoords: GLKVector3Make( 0.5,  0.5,  0.5), normalCoords: GLKVector3Make( 1.0,  0.0,  0.0), textureCoords: GLKVector2Make(1.0, 1.0)),
        SceneVertex(positionCoords: GLKVector3Make( 0.5,  0.5, -0.5), normalCoords: GLKVector3Make( 1.0,  0.0,  0.0), textureCoords: GLKVector2Make(1.0, 0.0)),
        
        SceneVertex(positionCoords: GLKVector3Make( 0.5,  0.5, -0.5), normalCoords: GLKVector3Make( 0.0,  1.0,  0.0), textureCoords: GLKVector2Make(1.0, 0.0)),
        SceneVertex(positionCoords: GLKVector3Make(-0.5,  0.5, -0.5), normalCoords: GLKVector3Make( 0.0,  1.0,  0.0), textureCoords: GLKVector2Make(0.0, 0.0)),
        SceneVertex(positionCoords: GLKVector3Make( 0.5,  0.5,  0.5), normalCoords: GLKVector3Make( 0.0,  1.0,  0.0), textureCoords: GLKVector2Make(1.0, 1.0)),
        SceneVertex(positionCoords: GLKVector3Make( 0.5,  0.5,  0.5), normalCoords: GLKVector3Make( 0.0,  1.0,  0.0), textureCoords: GLKVector2Make(1.0, 1.0)),
        SceneVertex(positionCoords: GLKVector3Make(-0.5,  0.5, -0.5), normalCoords: GLKVector3Make( 0.0,  1.0,  0.0), textureCoords: GLKVector2Make(0.0, 0.0)),
        SceneVertex(positionCoords: GLKVector3Make(-0.5,  0.5,  0.5), normalCoords: GLKVector3Make( 0.0,  1.0,  0.0), textureCoords: GLKVector2Make(0.0, 1.0)),
        
        SceneVertex(positionCoords: GLKVector3Make(-0.5,  0.5, -0.5), normalCoords: GLKVector3Make(-1.0,  0.0,  0.0), textureCoords: GLKVector2Make(1.0, 0.0)),
        SceneVertex(positionCoords: GLKVector3Make(-0.5, -0.5, -0.5), normalCoords: GLKVector3Make(-1.0,  0.0,  0.0), textureCoords: GLKVector2Make(0.0, 0.0)),
        SceneVertex(positionCoords: GLKVector3Make(-0.5,  0.5,  0.5), normalCoords: GLKVector3Make(-1.0,  0.0,  0.0), textureCoords: GLKVector2Make(1.0, 1.0)),
        SceneVertex(positionCoords: GLKVector3Make(-0.5,  0.5,  0.5), normalCoords: GLKVector3Make(-1.0,  0.0,  0.0), textureCoords: GLKVector2Make(1.0, 1.0)),
        SceneVertex(positionCoords: GLKVector3Make(-0.5, -0.5, -0.5), normalCoords: GLKVector3Make(-1.0,  0.0,  0.0), textureCoords: GLKVector2Make(0.0, 0.0)),
        SceneVertex(positionCoords: GLKVector3Make(-0.5, -0.5,  0.5), normalCoords: GLKVector3Make(-1.0,  0.0,  0.0), textureCoords: GLKVector2Make(0.0, 1.0)),
        
        SceneVertex(positionCoords: GLKVector3Make(-0.5, -0.5, -0.5), normalCoords: GLKVector3Make( 0.0, -1.0,  0.0), textureCoords: GLKVector2Make(0.0, 0.0)),
        SceneVertex(positionCoords: GLKVector3Make( 0.5, -0.5, -0.5), normalCoords: GLKVector3Make( 0.0, -1.0,  0.0), textureCoords: GLKVector2Make(1.0, 0.0)),
        SceneVertex(positionCoords: GLKVector3Make(-0.5, -0.5,  0.5), normalCoords: GLKVector3Make( 0.0, -1.0,  0.0), textureCoords: GLKVector2Make(0.0, 1.0)),
        SceneVertex(positionCoords: GLKVector3Make(-0.5, -0.5,  0.5), normalCoords: GLKVector3Make( 0.0, -1.0,  0.0), textureCoords: GLKVector2Make(0.0, 1.0)),
        SceneVertex(positionCoords: GLKVector3Make( 0.5, -0.5, -0.5), normalCoords: GLKVector3Make( 0.0, -1.0,  0.0), textureCoords: GLKVector2Make(1.0, 0.0)),
        SceneVertex(positionCoords: GLKVector3Make( 0.5, -0.5,  0.5), normalCoords: GLKVector3Make( 0.0, -1.0,  0.0), textureCoords: GLKVector2Make(1.0, 1.0)),
        
        SceneVertex(positionCoords: GLKVector3Make( 0.5,  0.5,  0.5), normalCoords: GLKVector3Make( 0.0,  0.0,  1.0), textureCoords: GLKVector2Make(1.0, 1.0)),
        SceneVertex(positionCoords: GLKVector3Make(-0.5,  0.5,  0.5), normalCoords: GLKVector3Make( 0.0,  0.0,  1.0), textureCoords: GLKVector2Make(0.0, 1.0)),
        SceneVertex(positionCoords: GLKVector3Make( 0.5, -0.5,  0.5), normalCoords: GLKVector3Make( 0.0,  0.0,  1.0), textureCoords: GLKVector2Make(1.0, 0.0)),
        SceneVertex(positionCoords: GLKVector3Make( 0.5, -0.5,  0.5), normalCoords: GLKVector3Make( 0.0,  0.0,  1.0), textureCoords: GLKVector2Make(1.0, 0.0)),
        SceneVertex(positionCoords: GLKVector3Make(-0.5,  0.5,  0.5), normalCoords: GLKVector3Make( 0.0,  0.0,  1.0), textureCoords: GLKVector2Make(0.0, 1.0)),
        SceneVertex(positionCoords: GLKVector3Make(-0.5, -0.5,  0.5), normalCoords: GLKVector3Make( 0.0,  0.0,  1.0), textureCoords: GLKVector2Make(0.0, 0.0)),
        
        SceneVertex(positionCoords: GLKVector3Make( 0.5, -0.5, -0.5), normalCoords: GLKVector3Make( 0.0,  0.0, -1.0), textureCoords: GLKVector2Make(4.0, 0.0)),
        SceneVertex(positionCoords: GLKVector3Make(-0.5, -0.5, -0.5), normalCoords: GLKVector3Make( 0.0,  0.0, -1.0), textureCoords: GLKVector2Make(0.0, 0.0)),
        SceneVertex(positionCoords: GLKVector3Make( 0.5,  0.5, -0.5), normalCoords: GLKVector3Make( 0.0,  0.0, -1.0), textureCoords: GLKVector2Make(4.0, 4.0)),
        SceneVertex(positionCoords: GLKVector3Make( 0.5,  0.5, -0.5), normalCoords: GLKVector3Make( 0.0,  0.0, -1.0), textureCoords: GLKVector2Make(4.0, 4.0)),
        SceneVertex(positionCoords: GLKVector3Make(-0.5, -0.5, -0.5), normalCoords: GLKVector3Make( 0.0,  0.0, -1.0), textureCoords: GLKVector2Make(0.0, 0.0)),
        SceneVertex(positionCoords: GLKVector3Make(-0.5,  0.5, -0.5), normalCoords: GLKVector3Make( 0.0,  0.0, -1.0), textureCoords: GLKVector2Make(0.0, 4.0)),
        ]
    
    deinit {
        // Make the view's context current
        let view = self.view as! GLKView
        AGLKContext.setCurrent(view.context)
        
        // Delete buffers that aren't needed
        vertexBuffer = nil
        
        if (program != 0) {
            glDeleteProgram(program)
            program = 0
        }
        
        // Stop using the context created in viewDidLoad()
        AGLKContext.setCurrent(nil)
    }
    
    override var shouldAutorotate: Bool {
        if UIDevice.current.userInterfaceIdiom == .phone {
            return !UIDeviceOrientationIsPortrait(.portraitUpsideDown)
        } else {
            return true
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.delegate = self
        
        // Get GLKView instance
        let view = self.view as! GLKView
        
        // Create an OpenGL ES 2.0 context and provide it to the view
        view.context = AGLKContext(api: .openGLES2)!
        view.drawableDepthFormat = .format24
        
        // Make the new context current
        AGLKContext.setCurrent(view.context)
        
        if !loadShaders() {
            fatalError("Failed to load shaders")
        }
        
        // Determine how many textures can be combined in a single pass.
        // Use `GL_MAX_TEXTURE_IMAGE_UNITS` instead of `GL_MAX_TEXTURE_UNITS`,
        // according to https://www.khronos.org/opengl/wiki/Common_Mistakes.
        var units: GLint = 0;
        glGetIntegerv(GLenum(GL_MAX_TEXTURE_IMAGE_UNITS), &units)
        print("\(units) texture uints can be combine in a single pass")
        
        // Set constants to be used for all subsequent rendering
        baseEffect.light0.enabled = GLboolean(GL_TRUE)
        baseEffect.light0.diffuseColor = GLKVector4Make(0.7, 0.7, 0.7, 1)
        
        glEnable(GLenum(GL_DEPTH_TEST))
        
        // Set the background color stored in the current context
        (view.context as! AGLKContext).clearColor = GLKVector4Make(0.65, 0.65, 0.65, 1)
        
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
        baseEffect.texture2d0.setParameter(parameterID: GLenum(GL_TEXTURE_WRAP_S), with: GLint(GL_REPEAT))
        baseEffect.texture2d0.setParameter(parameterID: GLenum(GL_TEXTURE_WRAP_T), with: GLint(GL_REPEAT))
        
        let imageRef1 = UIImage(named:"beetle")!.cgImage!
        let textureInfo1 = try! GLKTextureLoader.texture(with: imageRef1, options: [GLKTextureLoaderOriginBottomLeft: true as NSNumber])
        baseEffect.texture2d1.name = textureInfo1.name
        baseEffect.texture2d1.target = GLKTextureTarget(rawValue: textureInfo1.target)!
        baseEffect.texture2d1.envMode = GLKTextureEnvMode.decal
        baseEffect.texture2d1.setParameter(parameterID: GLenum(GL_TEXTURE_WRAP_S), with: GLint(GL_REPEAT))
        baseEffect.texture2d1.setParameter(parameterID: GLenum(GL_TEXTURE_WRAP_T), with: GLint(GL_REPEAT))
    }
    
    // GLKView delegate method: Called by the view controller's view
    // whenever Cocoa Touch asks the view controller's view to
    // draw itself. (In this case, render into a Frame Buffer that
    // share memory with a Core Animation Layer)
    override func glkView(_ view: GLKView, drawIn rect: CGRect) {
        // Clear Frame Buffer (erase previous drawing)
        (view.context as! AGLKContext).clear(GLbitfield(GL_COLOR_BUFFER_BIT|GL_DEPTH_BUFFER_BIT))
        
        vertexBuffer.prepareToDraw(
            withAttrib: GLuint(GLKVertexAttrib.position.rawValue),
            numberOfCoordinates: 3,
            attribOffset: GLsizeiptr(0),
            shouldEnable: true
        )
        vertexBuffer.prepareToDraw(
            withAttrib: GLuint(GLKVertexAttrib.normal.rawValue),
            numberOfCoordinates: 3,
            attribOffset: GLsizeiptr(MemoryLayout<GLfloat>.size * 3),  // FIXME: The offset of `normalCoords` in struct `SceneVertex`.
            shouldEnable: true
        )
        vertexBuffer.prepareToDraw(
            withAttrib: GLuint(GLKVertexAttrib.texCoord0.rawValue),
            numberOfCoordinates: 2,
            attribOffset: GLsizeiptr(MemoryLayout<GLfloat>.size * 6),  // FIXME: The offset of `textureCoords` in struct `SceneVertex`.
            shouldEnable: true
        )
        vertexBuffer.prepareToDraw(
            withAttrib: GLuint(GLKVertexAttrib.texCoord1.rawValue),
            numberOfCoordinates: 2,
            attribOffset: GLsizeiptr(MemoryLayout<GLfloat>.size * 6),  // FIXME: The offset of `textureCoords` in struct `SceneVertex`.
            shouldEnable: true
        )
        baseEffect.prepareToDraw()
        
        // Draw triangles using baseEffect
        vertexBuffer.drawArray(
            withMode: GLenum(GL_TRIANGLES),
            startVertexIndex: 0,
            numberOfVertices: GLsizei(vertices.count)
        )
        
        // Render the object again with ES2
        glUseProgram(program)
        
        glUniformMatrix4fv(uniforms[Int(Uniform.modelViewProjectionMatrix.rawValue)], 1, 0, modelViewProjectionMatrix.array)
        glUniformMatrix3fv(uniforms[Int(Uniform.normalMatrix.rawValue)], 1, 0, normalMatrix.array)
        glUniform1i(uniforms[Int(Uniform.texture0Sampler2D.rawValue)], 0)
        glUniform1i(uniforms[Int(Uniform.texture1Sampler2D.rawValue)], 1)
        
        glDrawArrays(GLenum(GL_TRIANGLES), 0, GLsizei(vertices.count))
    }
}

extension ViewController {
    func loadShaders() -> Bool {
        // Create shader program
        program = glCreateProgram()
        
        // Create and compile vertex shader
        var vertexShader: GLuint = 0
        let vertexShaderPath = Bundle.main.path(forResource: "Shader", ofType: "vsh")!
        if !compileShader(&vertexShader, type: GLenum(GL_VERTEX_SHADER), file: vertexShaderPath) {
            print("Failed to compile vertex shader")
            return false
        }
        
        // Create and compile fragment shader
        var fragmentShader: GLuint = 0
        let fragmentShaderPath = Bundle.main.path(forResource: "Shader", ofType: "fsh")!
        if !compileShader(&fragmentShader, type: GLenum(GL_FRAGMENT_SHADER), file: fragmentShaderPath) {
            print("Failed to compile fragment shader")
            return false
        }
        
        // Attach vertex & fragment shader to program
        glAttachShader(program, vertexShader)
        glAttachShader(program, fragmentShader)
        
        // Bind attribute locations.
        // This needs to be done prior to linking.
        glBindAttribLocation(program, GLuint(GLKVertexAttrib.position.rawValue), "aPosition")
        glBindAttribLocation(program, GLuint(GLKVertexAttrib.normal.rawValue), "aNormal")
        glBindAttribLocation(program, GLuint(GLKVertexAttrib.texCoord0.rawValue), "aTextureCoord0")
        glBindAttribLocation(program, GLuint(GLKVertexAttrib.texCoord1.rawValue), "aTextureCoord1")
        
        // Link program
        if !linkProgram(program) {
            print("Failed to link program: \(program)")
            
            if vertexShader != 0 {
                glDeleteShader(vertexShader)
                vertexShader = 0
            }
            if fragmentShader != 0 {
                glDeleteShader(fragmentShader)
                fragmentShader = 0
            }
            if program != 0 {
                glDeleteProgram(program)
                program = 0
            }
            
            return false
        }
        
        // Get uniform locations
        uniforms[Int(Uniform.modelViewProjectionMatrix.rawValue)] = glGetUniformLocation(program, "uModelViewProjectionMatrix")
        uniforms[Int(Uniform.normalMatrix.rawValue)] = glGetUniformLocation(program, "uNormalMatrix")
        uniforms[Int(Uniform.texture0Sampler2D.rawValue)] = glGetUniformLocation(program, "uSampler0")
        uniforms[Int(Uniform.texture1Sampler2D.rawValue)] = glGetUniformLocation(program, "uSampler1")
        
        // Release vertex and fragment shaders
        if vertexShader != 0 {
            glDeleteShader(vertexShader)
            vertexShader = 0
        }
        if fragmentShader != 0 {
            glDeleteShader(fragmentShader)
            fragmentShader = 0
        }
        
        return true
    }
    
    func compileShader(_ shader: inout GLuint, type: GLenum, file: String) -> Bool {
        guard var source = try? NSString(contentsOfFile: file, encoding: String.Encoding.utf8.rawValue).utf8String else {
            print("Failed to load vertex shader")
            return false
        }
        
        shader = glCreateShader(type)
        glShaderSource(shader, 1, &source, nil)
        glCompileShader(shader)
        
        var logLength: GLint = 0
        glGetProgramiv(program, GLenum(GL_INFO_LOG_LENGTH), &logLength)
        if logLength > 0 {
            var log = [GLchar](repeating: 0, count: Int(logLength))
            glGetProgramInfoLog(program, logLength, &logLength, &log)
            print("Shader compile log:\(log)")
        }

        var status: GLint = 0
        glGetShaderiv(shader, GLenum(GL_COMPILE_STATUS), &status);
        return status == GL_TRUE
    }
    
    func linkProgram(_ program: GLuint) -> Bool {
        glLinkProgram(program)
        
        var logLength: GLint = 0
        glGetProgramiv(program, GLenum(GL_INFO_LOG_LENGTH), &logLength)
        if logLength > 0 {
            var log = [GLchar](repeating: 0, count: Int(logLength))
            glGetProgramInfoLog(program, logLength, &logLength, &log)
            print("Program link log:\(log)")
        }
        
        var status: GLint = 0
        glGetProgramiv(program, GLenum(GL_LINK_STATUS), &status)
        return status == GL_TRUE
    }
    
    func validateProgram(_ program: GLuint) -> Bool {
        var logLength: GLint = 0
        var status: Int32 = 0
        
        glValidateProgram(program)
        glGetProgramiv(program, GLenum(GL_INFO_LOG_LENGTH), &logLength)
        if logLength > 0 {
            var log = [GLchar](repeating: 0, count: Int(logLength))
            glGetProgramInfoLog(program, logLength, &logLength, &log)
            print("Program validate log:\(log)")
        }
        
        glGetProgramiv(program, GLenum(GL_VALIDATE_STATUS), &status)
        return status == GL_TRUE
    }
}

extension ViewController: GLKViewControllerDelegate {
    func glkViewControllerUpdate(_ controller: GLKViewController) {
        let aspect = fabsf(Float(view.bounds.size.width) / Float(view.bounds.size.height))
        let projectionMatrix = GLKMatrix4MakePerspective(GLKMathDegreesToRadians(65), aspect, 0.1, 100)
        
        baseEffect.transform.projectionMatrix = projectionMatrix
        
        var baseModelViewMatrix = GLKMatrix4MakeTranslation(0, 0, -4)
        baseModelViewMatrix = GLKMatrix4Rotate(baseModelViewMatrix, rotation, 0, 1, 0)
        
        // Compute the model view matrix for the object rendered with GLKit
        var modelViewMatrix = GLKMatrix4MakeTranslation(0, 0, -1.5)
        modelViewMatrix = GLKMatrix4Rotate(modelViewMatrix, rotation, 1, 1, 1)
        modelViewMatrix = GLKMatrix4Multiply(baseModelViewMatrix, modelViewMatrix)
        
        baseEffect.transform.modelviewMatrix = modelViewMatrix
        
        // Compute the model view matrix for the object rendered with GLKit
        modelViewMatrix = GLKMatrix4MakeTranslation(0, 0, 1.5)
        modelViewMatrix = GLKMatrix4Rotate(modelViewMatrix, rotation, 1, 1, 1)
        modelViewMatrix = GLKMatrix4Multiply(baseModelViewMatrix, modelViewMatrix)
        
        normalMatrix = GLKMatrix4GetMatrix3(GLKMatrix4InvertAndTranspose(modelViewMatrix, nil))
        modelViewProjectionMatrix = GLKMatrix4Multiply(projectionMatrix, modelViewMatrix)
        
        rotation += GLfloat(timeSinceLastUpdate * 0.5)
    }
}
