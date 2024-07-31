//
//  GameViewController.swift
//  saisyuukadai
//
//  Created by 長屋天友 on 2024/07/30.
//

import UIKit
import SpriteKit

class GameViewController: UIViewController {

    override func viewDidLoad() {
        super.viewDidLoad()
        
        if let view = self.view as! SKView? {
            let startScene = StartScene(size: view.bounds.size)
            startScene.scaleMode = .aspectFill
            view.presentScene(startScene)
            
            view.ignoresSiblingOrder = true
            view.showsFPS = true
            view.showsNodeCount = true
        }
    }
}
