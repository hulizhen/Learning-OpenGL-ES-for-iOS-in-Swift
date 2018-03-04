//
//  AGLKContext.swift
//  OpenGLES-Ch2-3
//
//  Created by Lizhen Hu on 04/03/2018.
//  Copyright © 2018 Lizhen Hu. All rights reserved.
//

import UIKit
import GLKit

class AGLKContext: EAGLContext {
    private var backingClearColor = GLKVector4()
    
    var clearColor: GLKVector4 {
        set {
            assertCurrentContext()
            backingClearColor = newValue
            glClearColor(backingClearColor.r, backingClearColor.g, backingClearColor.b, backingClearColor.a)
        }
        get {
            return backingClearColor
        }
    }

    // Instructs OpenGL ES to set all data in the current Context's
    // Render Buffer(s) identified by mask to colors (values) specified
    // via clearColor and/or OpenGL ES functions for each Render Buffer type.
    func clear(_ mask: GLbitfield) {
        assertCurrentContext()
        glClear(mask)
    }
}

extension AGLKContext {
    func assertCurrentContext() {
        assert(type(of: self).current() == self, "Receiving context required to be current context")
    }
}
