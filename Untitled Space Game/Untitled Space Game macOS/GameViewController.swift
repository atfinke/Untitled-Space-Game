//
//  GameViewController.swift
//  Untitled Space Game macOS
//
//  Created by Andrew Finke on 3/13/20.
//  Copyright © 2020 Andrew Finke. All rights reserved.
//

import Cocoa
import SpriteKit
import GameplayKit

class GameViewController: NSViewController {

    override func viewDidLoad() {
        super.viewDidLoad()
        
        if NSClassFromString("XCTestCase") != nil {
            return
        }
        
//        scaleMode = .resizeFill
//        let filename = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask)[0].appendingPathComponent("data")
//        let data = try! Data(contentsOf: filename)
//        let scene = try! JSONDecoder().decode(GameScene.self, from: data)
        


        let scene = GameScene.newGameScene()

        // Present the scene
        let skView = self.view as! SKView
        skView.presentScene(scene)

        skView.ignoresSiblingOrder = true

        #if DEBUG
        skView.showsFPS = true
        skView.showsNodeCount = true
        skView.showsQuadCount = true
        skView.showsDrawCount = true
        #else
        let alert = NSAlert()
        alert.messageText = "thanks for looking at this"
        alert.informativeText = "1. lmk what sucks\n2. final version is for touch/ios\n3. right click to reset (only if things seem broken)\n4. there is no end"
        alert.addButton(withTitle: "cool")
        alert.runModal()
        #endif

        NSEvent.addLocalMonitorForEvents(matching: .keyDown) {
            if $0.keyCode == 124 {
                scene.debugMove(x: 125, y: 0)
            } else if $0.keyCode == 123 {
                scene.debugMove(x: -125, y: 0)
            } else if $0.keyCode == 126 {
                scene.debugMove(x: 0, y: 125)
            } else if $0.keyCode == 125 {
                scene.debugMove(x: 0, y: -125)
            } else {
                return $0
            }
            return nil
        }
    }

}
