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
    case none = 0
    case border = 1
    case cat = 2
    case tunaCan = 4
    case sprayBottle = 8
    case shoe = 16
}

class GameScene: SKScene, SKPhysicsContactDelegate {
    
    
   
    
    func random() -> CGFloat {
        return CGFloat(Float(arc4random()) / 0xFFFFFFFF)
    }
    
    func random(min: CGFloat, max: CGFloat) -> CGFloat {
        return random() * (max - min) + min
    }

    
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
        addPhysicsBody(toNode: cat, withRectangleOf: CGSize(width: cat.size.width-50, height: cat.size.height-34), withCategoryMask: .cat, contactMask: .tunaCan, andCollisionMask: .border)
        cat.physicsBody?.mass = 0.01
        cat.physicsBody?.allowsRotation = false
        cat.physicsBody?.restitution = 0.6
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
        addPhysicsBody(toNode: tunaCan, ofRadius: 10.0, withCategoryMask: .tunaCan, contactMask: .cat, andCollisionMask: .border)
        tunaCan.physicsBody?.allowsRotation = false
        tunaCan.physicsBody?.affectedByGravity = false
        addChild(tunaCan)
        
        addLevelClearedLabel()
        addChild(challange)
        run(SKAction.repeatForever(SKAction.sequence([SKAction.run(launchShoe),SKAction.wait(forDuration: 2)])))
        run(SKAction.repeatForever(SKAction.sequence([SKAction.run(throwSprayBottle),SKAction.wait(forDuration: 2)])))
        backgroundColor = SKColor.white
    }
    
    func addLevelClearedLabel() {
        levelClearedLabel.position = CGPoint(x: size.width/2, y: size.height/2)
        levelClearedLabel.fontColor = SKColor.red
        levelClearedLabel.fontSize = 44.0
        levelClearedLabel.fontName = "HelveticaNeue-Bold"
        levelClearedLabel.isHidden = true
        levelClearedLabel.zPosition = 4
        addChild(levelClearedLabel)
    }
    
    func throwSprayBottle() {
        let bottle = SKSpriteNode(imageNamed: "sprayBottle")
        bottle.zPosition = 10
        bottle.size = CGSize(width: 40, height: 30)
        bottle.position = CGPoint(x: (bottle.size.width * -1), y: size.height/2)
        addPhysicsBody(toNode: bottle, withRectangleOf: CGSize(width: bottle.size.width, height: bottle.size.height), withCategoryMask: .sprayBottle, contactMask: .cat, andCollisionMask: .none)
        bottle.physicsBody?.restitution = 0.5
        addChild(bottle)
        bottle.physicsBody?.applyImpulse(CGVector(dx: 30, dy: 20))
    }
    
    func launchShoe() {
        
        let shoe = SKSpriteNode(imageNamed: "shoe")
        shoe.position = CGPoint(x: frame.size.width + shoe.size.width,y: random(min:0,max:frame.size.height) )
        shoe.size = CGSize(width:90,height:70)
        shoe.zPosition = 5
        addPhysicsBody(toNode: shoe, ofRadius: 10, withCategoryMask: .shoe, contactMask: .cat, andCollisionMask: .none)
        addChild(shoe)
        shoe.physicsBody?.applyImpulse(CGVector(dx:-30,dy:9))
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
        let contactMade = contact.bodyA.categoryBitMask | contact.bodyB.categoryBitMask
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
    
    //MARK: PhysicsBody Config Helper Functions
    func addPhysicsBody(toNode node: SKSpriteNode, withRectangleOf size: CGSize, withCategoryMask categoryMask: TunaCatObjectType, contactMask: TunaCatObjectType, andCollisionMask collisionMask: TunaCatObjectType) {
        node.physicsBody = SKPhysicsBody(rectangleOf: size)
        addPhysicsMasks(toNode: node, withCategoryMask: categoryMask, contactMask: contactMask, andCollisionMask: collisionMask)
    }
    
    func addPhysicsBody(toNode node: SKSpriteNode, ofRadius radius: CGFloat, withCategoryMask categoryMask: TunaCatObjectType, contactMask: TunaCatObjectType, andCollisionMask collisionMask: TunaCatObjectType) {
        node.physicsBody = SKPhysicsBody(circleOfRadius: radius)
        addPhysicsMasks(toNode: node, withCategoryMask: categoryMask, contactMask: contactMask, andCollisionMask: collisionMask)
    }
    
    func addPhysicsMasks(toNode node: SKSpriteNode, withCategoryMask categoryMask: TunaCatObjectType, contactMask: TunaCatObjectType, andCollisionMask collisionMask: TunaCatObjectType) {
        node.physicsBody?.categoryBitMask = categoryMask.rawValue
        node.physicsBody?.contactTestBitMask = contactMask.rawValue
        node.physicsBody?.collisionBitMask = collisionMask.rawValue
    }
    
    //MARK: Touch Handling Functions
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

