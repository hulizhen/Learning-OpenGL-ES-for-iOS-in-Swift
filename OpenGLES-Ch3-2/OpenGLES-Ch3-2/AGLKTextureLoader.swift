//
//  AGLKTextureLoader.swift
//  OpenGLES-Ch3-2
//
//  Created by Lizhen Hu on 06/03/2018.
//  Copyright © 2018 Lizhen Hu. All rights reserved.
//

import UIKit
import GLKit

// This data type is used specify power of 2 values. OpenGL ES
// best supports texture images that have power of 2 dimensions.
enum AGLKPowerOf2: GLsizei {
    case aglk1 = 1
    case aglk2 = 2
    case aglk4 = 4
    case aglk8 = 8
    case aglk16 = 16
    case aglk32 = 32
    case aglk64 = 64
    case aglk128 = 128
    case aglk256 = 256
    case aglk512 = 512
    case aglk1024 = 1024
}

struct AGLKTextureInfo {
    var name: GLuint
    var target: GLenum
    var width: GLsizei
    var height: GLsizei
}

class AGLKTextureLoader: NSObject {
    // Generates a new OpenGL ES texture buffer and
    // initializes the buffer contents using pixel data from the
    // specified Core Graphics image, cgImage. This method returns an
    // immutable AGLKTextureInfo instance initialized with
    // information about the newly generated texture buffer.
    // The generated texture buffer has power of 2 dimensions. The
    // provided image data is scaled (re-sampled) by Core Graphics as
    // necessary to fit within the generated texture buffer.
    class func texture(with image:CGImage, options: Dictionary<String, Any>? = nil) throws -> AGLKTextureInfo {
        // Get the bytes to be used when copying data into new texture buffer
        var width: GLsizei = 0
        var height: GLsizei = 0
        let imageData = data(withResizedCGImage: image, width: &width, height: &height)

        // Generation, bind, and copy data into a new texture buffer
        var textureBufferID: GLuint = 0
        glGenTextures(1, &textureBufferID)
        glBindTexture(GLenum(GL_TEXTURE_2D), textureBufferID)
        glTexImage2D(
            GLenum(GL_TEXTURE_2D),
            0,                         // MIP map level of detail
            GL_RGBA,                   // GL_RGB or GL_RGBA: Specifies the amount of information to be stored by each texel within the texture buffer
            width,                     // The width should be powers of two
            height,                    // The height should be powers of two
            0,                         // Used to define the size of a border around the texture’s texels, but it is always set to zero for OpenGL ES
            GLenum(GL_RGBA),           // Should always be the same as the internalFormat argument
            GLenum(GL_UNSIGNED_BYTE),  // Specifies the type of bit encoding
            imageData
        )
        
        // Set parameters that control texture sampling for the bound texture
        glTexParameteri(GLenum(GL_TEXTURE_2D), GLenum(GL_TEXTURE_MIN_FILTER), GL_LINEAR)
        
        // Allocate and initialize the AGLKTextureInfo instance to be returned
        return AGLKTextureInfo(name: textureBufferID, target: GLenum(GL_TEXTURE_2D), width: width, height: height)
    }
    
    // This function returns an NSData object that contains bytes
    // loaded from the specified Core Graphics image, cgImage. This
    // function also returns (by reference) the power of 2 width and
    // height to be used when initializing an OpenGL ES texture buffer
    // with the bytes in the returned NSData instance. The widthPtr
    // and heightPtr arguments must be valid pointers.
    class func data(withResizedCGImage image: CGImage, width: inout GLsizei, height: inout GLsizei) -> UnsafeMutablePointer<UInt8> {
        let originalWidth = GLsizei(image.width)
        let originalHeight = GLsizei(image.height)
        assert(originalWidth > 0, "Invalid iamge width")
        assert(originalHeight > 0, "Invalid iamge height")
        
        // Calculate the width and height of the new texture buffer
        // The new texture buffer will have power of 2 dimensions.
        width = calculatePowerOf2ForDimension(dimension: originalWidth)
        height = calculatePowerOf2ForDimension(dimension: originalHeight)
        
        // Allocate sufficient storage for RGBA pixel color data with
        // the power of 2 sizes specified
        let imageData = UnsafeMutablePointer<UInt8>.allocate(capacity: Int(width * height * 4))
        
        // Create a Core Graphics context that draws into the allocated bytes
        let colorSpace = CGColorSpaceCreateDeviceRGB()
        if let context = CGContext(
            data: imageData,
            width: Int(width),
            height: Int(height),
            bitsPerComponent: 8,
            bytesPerRow: 4 * Int(width),
            space: colorSpace,
            bitmapInfo: CGImageAlphaInfo.premultipliedLast.rawValue) {
            // Flip the Core Graphics Y-axis for future drawing
            context.translateBy(x: 0, y: CGFloat(height))
            context.scaleBy(x: 1, y: -1)
            
            // Draw the loaded image into the Core Graphics context
            // resizing as necessary
            context.draw(image, in: CGRect(x: 0, y: 0, width: CGFloat(width), height: CGFloat(height)))
            
            return imageData
        } else {
            fatalError("Unable create Core Graphics context.")
        }
    }

    // This function calculates and returns the nearest power of 2
    // that is greater than or equal to the dimension argument and
    // less than or equal to 1024.
    class func calculatePowerOf2ForDimension(dimension: GLsizei) -> GLsizei {
        var result = AGLKPowerOf2.aglk1.rawValue;
    
        if dimension > AGLKPowerOf2.aglk512.rawValue {
            result = AGLKPowerOf2.aglk1024.rawValue;
        } else if dimension > AGLKPowerOf2.aglk256.rawValue {
            result = AGLKPowerOf2.aglk512.rawValue;
        } else if dimension > AGLKPowerOf2.aglk128.rawValue {
            result = AGLKPowerOf2.aglk256.rawValue;
        } else if dimension > AGLKPowerOf2.aglk64.rawValue {
            result = AGLKPowerOf2.aglk128.rawValue;
        } else if dimension > AGLKPowerOf2.aglk32.rawValue {
            result = AGLKPowerOf2.aglk64.rawValue;
        } else if dimension > AGLKPowerOf2.aglk16.rawValue {
            result = AGLKPowerOf2.aglk32.rawValue;
        } else if dimension > AGLKPowerOf2.aglk8.rawValue {
            result = AGLKPowerOf2.aglk16.rawValue;
        } else if dimension > AGLKPowerOf2.aglk4.rawValue {
            result = AGLKPowerOf2.aglk8.rawValue;
        } else if dimension > AGLKPowerOf2.aglk2.rawValue {
            result = AGLKPowerOf2.aglk4.rawValue;
        } else if dimension > AGLKPowerOf2.aglk1.rawValue {
            result = AGLKPowerOf2.aglk2.rawValue;
        }
    
        return result;
    }
}
