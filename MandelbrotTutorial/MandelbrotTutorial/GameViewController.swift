//
//  GameViewController.swift
//  MandelbrotTutorial
//
//  Created by Silviu Pop on 5/15/15.
//  Copyright (c) 2015 WeHeartSwift. All rights reserved.
//

import UIKit
import SpriteKit
//let DEBUG=true

extension SKNode {
    class func unarchiveFromFile(file : String) -> SKNode? {
        if let path = NSBundle.mainBundle().pathForResource(file, ofType: "sks") {
            let sceneData = try! NSData(contentsOfFile: path, options: .DataReadingMappedIfSafe)
            let archiver = NSKeyedUnarchiver(forReadingWithData: sceneData)
            
            archiver.setClass(self.classForKeyedUnarchiver(), forClassName: "SKScene")
            let scene = archiver.decodeObjectForKey(NSKeyedArchiveRootObjectKey) as! GameScene
            archiver.finishDecoding()
            return scene
        } else {
            return nil
        }
    }
}

class GameViewController: UIViewController, UIScrollViewDelegate {
    
    var node:SKSpriteNode!
    
    @IBOutlet weak var contentView: UIView!
    @IBOutlet weak var scrollView: UIScrollView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        if let scene = GameScene.unarchiveFromFile("GameScene") as? GameScene {
            // Configure the view.
            let skView = self.view as! SKView
            skView.ignoresSiblingOrder = true
            
            /* Set the scale mode to scale to fit the window */
            scene.scaleMode = .Fill
            
            node = scene.childNodeWithName("fractal") as! SKSpriteNode
            
            skView.presentScene(scene)
            
            self.scrollView.delegate = self
            self.contentView.translatesAutoresizingMaskIntoConstraints = true
        }
        
        updateShader(scrollView)
    }
    
    override func viewDidAppear(animated: Bool) {
        super.viewDidAppear(animated)
//        scrollView.contentSize = CGSizeMake(400,2300)
        updateShader(scrollView)
    }
    
    func updateShader(scrollView: UIScrollView) {
        let zoomUniform = node.shader!.uniformNamed("zoom")!
        
        let offsetUniform = node.shader!.uniformNamed("offset")!
        
        var offset = scrollView.contentOffset
        
        offset.x /= scrollView.contentSize.width
        offset.y /= scrollView.contentSize.height
        
        zoomUniform.floatValue = Float(scrollView.zoomScale)
        offsetUniform.floatVector2Value = GLKVector2Make(Float(offset.x), Float(offset.y))
        Log.msg("zoomUniform:"+zoomUniform.floatValue.description)
        Log.msg("offsetUniform:"+offsetUniform.description)
    }
    
    func scrollViewDidScroll(scrollView: UIScrollView) {
        updateShader(scrollView)
    }
    
    func scrollViewDidZoom(scrollView: UIScrollView) {
        updateShader(scrollView)
    }
    
    func viewForZoomingInScrollView(scrollView: UIScrollView) -> UIView? {
        return contentView
    }
    
    override func prefersStatusBarHidden() -> Bool {
        return true
    }
    
}

class Log {
    class func msg(message: String,
        functionName:  String = __FUNCTION__, fileNameWithPath: String = __FILE__, lineNumber: Int = __LINE__ ) {
            // In the default arguments to this function:
            // 1) If I use a String type, the macros (e.g., __LINE__) don't expand at run time.
            //  "\(__FUNCTION__)\(__FILE__)\(__LINE__)"
            // 2) A tuple type, like,
            // typealias SMLogFuncDetails = (String, String, Int)
            //  SMLogFuncDetails = (__FUNCTION__, __FILE__, __LINE__)
            //  doesn't work either.
            // 3) This String = __FUNCTION__ + __FILE__
            //  also doesn't work.
            
            let fileNameWithoutPath = fileNameWithPath
            
//            #if DEBUG
                let output = "\(NSDate()): \(message) [\(functionName) in \(fileNameWithoutPath), line \(lineNumber)]"
                print(output)
//            #endif
    }
}
