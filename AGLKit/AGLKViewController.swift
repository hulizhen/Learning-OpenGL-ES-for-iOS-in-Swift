//
//  AGLKViewController.swift
//  OpenGLES-Ch2-2
//
//  Created by Lizhen Hu on 04/03/2018.
//  Copyright © 2018 Lizhen Hu. All rights reserved.
//

import UIKit

// This constant defines the default number of frame per second
// rate to redraw the receiver's view when the receiver is not
// paused.
let kAGLKDefaultFramesPerSecond = 30

class AGLKViewController: UIViewController {
    var displayLink: CADisplayLink!
    
    // This property contains the desired frames per second rate for
    // drawing.
    var preferredFramesPerSecond: Int {
        set {
            displayLink.preferredFramesPerSecond = newValue
        }
        get {
            return displayLink.preferredFramesPerSecond
        }
    }
    
    // This property determines whether to pause or resume drawing
    // at the rate defined by the framesPerSecond property.
    // Initial value is false.
    var isPaused: Bool {
        set {
            displayLink.isPaused = newValue
        }
        get {
            return displayLink.isPaused
        }
    }
    
    override init(nibName nibNameOrNil: String?, bundle nibBundleOrNil: Bundle?) {
        super.init(nibName: nibNameOrNil, bundle: nibBundleOrNil)
        commonInit()
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        commonInit()
    }
    
    func commonInit() {
        displayLink = CADisplayLink(target: self, selector: #selector(drawRect(_:)))
        displayLink.add(to: RunLoop.current, forMode: .defaultRunLoopMode)
        preferredFramesPerSecond = kAGLKDefaultFramesPerSecond
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()

        if let view = self.view as? AGLKView {
            view.isOpaque = true
            view.delegate = self
        }
    }
    
    @objc
    func drawRect(_ rect: CGRect) {
        if let view = self.view as? AGLKView {
            view.display()
        }
    }
}

extension AGLKViewController: AGLKViewDelegate {
    // This required AGLKViewDelegate method does nothing.
    // Subclasses of this class may override this method to
    // draw on behalf of the receiver's view.
    func glkView(_ view: AGLKView, drawIn rect: CGRect) {
    }
}
