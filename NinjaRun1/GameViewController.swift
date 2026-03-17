//
//  GameViewController.swift
//  NinjaRun1
//
//  Created by Akshay Yadav on 3/5/26.
//

import UIKit
import SpriteKit

class GameViewController: UIViewController {

    override func viewDidLoad() {
        super.viewDidLoad()
        
        if let view = self.view as! SKView? {
            // Create the main menu scene
            let scene = MainMenuScene()
            scene.size = view.bounds.size
            scene.scaleMode = .aspectFill

            // Present the scene
            view.presentScene(scene)
            
            view.ignoresSiblingOrder = true
            
            // Show debug info during development
            view.showsFPS = true
            view.showsNodeCount = true
        }
    }

    override var supportedInterfaceOrientations: UIInterfaceOrientationMask {
        // Force portrait mode as per PRD
        return .portrait
    }

    override var prefersStatusBarHidden: Bool {
        return true
    }
}
