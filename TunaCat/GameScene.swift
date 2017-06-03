//
//  GameScene.swift
//  Testy
//
//  Created by Nicholas Dixon on 6/1/17.
//  Copyright © 2017 Nicholas Dixon. All rights reserved.
//

import SpriteKit
import GameplayKit

enum TunaCatObjectType: UInt32 {
    case cat = 1
    case tunaCan = 2
    case border = 4
}

class GameScene: SKScene, SKPhysicsContactDelegate {
    
    private var cat = SKSpriteNode(imageNamed: "myCat")
    private var kitchen = SKSpriteNode(imageNamed: "kitchen_background")
    private var tunaCan = SKSpriteNode(imageNamed: "tunaCan")
    private var levelClearedLabel = SKLabelNode()
    private var levelCleared = false
    private var needsRestart = false
    private var endGamePauseTimer: Timer?
    private var challange = SKLabelNode()
    
    override func didMove(to view: SKView) {
        cat.name = "kitty"
        cat.position = CGPoint(x: 100, y: 100)
        cat.zPosition = 2
        cat.size = CGSize(width: 170,height: 100)
        cat.physicsBody = SKPhysicsBody(rectangleOf: CGSize(width: cat.size.width-50, height: cat.size.height-34))
        cat.physicsBody?.mass = 0.01
        cat.physicsBody?.allowsRotation = false
        cat.physicsBody?.restitution = 0.6
        cat.physicsBody?.contactTestBitMask = TunaCatObjectType.tunaCan.rawValue
        cat.physicsBody?.collisionBitMask = TunaCatObjectType.border.rawValue
        cat.physicsBody?.categoryBitMask = TunaCatObjectType.cat.rawValue
        cat.zPosition = 2
        addChild(cat)
        
        physicsBody = SKPhysicsBody(edgeLoopFrom: frame.insetBy(dx: 0, dy: 0))
        physicsWorld.contactDelegate = self
        
        kitchen.position = CGPoint(x: size.width/2, y: size.height/2)
        kitchen.zPosition = 0
        kitchen.size = CGSize(width: frame.size.width, height: frame.size.height + 20)
        addChild(kitchen)
        
        tunaCan.name = "tunaCan"
        tunaCan.position = CGPoint(x: size.width * 0.8, y: 302)
        tunaCan.size = CGSize(width: 40, height: 30)
        tunaCan.zPosition = 1
        tunaCan.physicsBody = SKPhysicsBody(circleOfRadius: 10.0)
        tunaCan.physicsBody?.allowsRotation = false
        tunaCan.physicsBody?.affectedByGravity = false
        tunaCan.physicsBody?.contactTestBitMask = TunaCatObjectType.cat.rawValue
        tunaCan.physicsBody?.collisionBitMask = TunaCatObjectType.border.rawValue
        tunaCan.physicsBody?.categoryBitMask = TunaCatObjectType.tunaCan.rawValue
        addChild(tunaCan)
        
        levelClearedLabel.position = CGPoint(x: size.width/2, y: size.height/2)
        levelClearedLabel.fontColor = SKColor.red
        levelClearedLabel.fontSize = 44.0
        levelClearedLabel.fontName = "HelveticaNeue-Bold"
        levelClearedLabel.isHidden = true
        levelClearedLabel.zPosition = 4
        addChild(levelClearedLabel)
        
        
        
        addChild(challange)
        
        
        
        backgroundColor = SKColor.white
    }
    
    func setNeedsRestart() {
        needsRestart = true
        levelCleared = false
        levelClearedLabel.text = "Tap to Restart"
        endGamePauseTimer?.invalidate()
        endGamePauseTimer = nil
    }

    func startOver() {
        cat.physicsBody?.allowsRotation = true
        cat.position = CGPoint(x: 100, y: 100)
        tunaCan.physicsBody?.affectedByGravity = false
        tunaCan.position = CGPoint(x: size.width * 0.8, y: 302)
        needsRestart = false
        kitchen.isHidden =  false
        tunaCan.isHidden = false
        cat.isHidden = false
        backgroundColor = SKColor.white
        levelClearedLabel.isHidden = true
    }
    
    func didEnd(_ contact: SKPhysicsContact) {
        let contactMade = contact.bodyA.contactTestBitMask | contact.bodyB.contactTestBitMask
        if contactMade == TunaCatObjectType.cat.rawValue | TunaCatObjectType.tunaCan.rawValue {
            endGameAndPause()
        }
    }
    
    func endGameAndPause() {
        tunaCan.physicsBody?.affectedByGravity = true
        levelClearedLabel.isHidden = false
        backgroundColor = SKColor.black
        kitchen.isHidden = true
        tunaCan.isHidden = true
        cat.isHidden = true
        levelCleared = true
        levelClearedLabel.text = "Level Cleared!!!"
        endGamePauseTimer = Timer.scheduledTimer(timeInterval: 2.0, target: self, selector: #selector(setNeedsRestart), userInfo: nil, repeats: false)
    }
    
    func touchDown(atPoint pos : CGPoint) {
        guard endGamePauseTimer == nil && !levelCleared else { return }
        
        if needsRestart {
            startOver()
        } else {
            let multiplier = pos.x > size.width/2 ? 1 : -1
            cat.physicsBody?.applyImpulse(CGVector(dx: multiplier*3, dy: 5))
        }
    }
    
    func touchMoved(toPoint pos : CGPoint) {
    }
    
    func touchUp(atPoint pos : CGPoint) {
    }
    
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        for t in touches { self.touchDown(atPoint: t.location(in: self)) }
    }
    
    override func touchesMoved(_ touches: Set<UITouch>, with event: UIEvent?) {
        for t in touches { self.touchMoved(toPoint: t.location(in: self)) }
    }
    
    override func touchesEnded(_ touches: Set<UITouch>, with event: UIEvent?) {
        for t in touches { self.touchUp(atPoint: t.location(in: self)) }
    }
    
    override func touchesCancelled(_ touches: Set<UITouch>, with event: UIEvent?) {
        for t in touches { self.touchUp(atPoint: t.location(in: self)) }
    }
    
    override func update(_ currentTime: TimeInterval) {
        // Called before each frame is rendered
    }
}

