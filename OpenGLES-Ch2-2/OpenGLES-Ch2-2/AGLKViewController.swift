//
//  AGLKViewController.swift
//  OpenGLES-Ch2-2
//
//  Created by Lizhen Hu on 04/03/2018.
//  Copyright © 2018 Lizhen Hu. All rights reserved.
//

import UIKit

class AGLKViewController: UIViewController {
    var displayLink: CADisplayLink!
    
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
