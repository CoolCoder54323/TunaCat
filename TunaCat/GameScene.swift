//
//  GameScene.swift
//  TunaCat
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

    
    var second: Int = 0 { didSet { if second >= 12 { endGameAndPause(withLevelCleared: false) } } }
    var timer = SKLabelNode()
    private var cat = SKSpriteNode(imageNamed: "myCat")
    private var kitchen = SKSpriteNode(imageNamed: "kitchen_background")
    private var tunaCan = SKSpriteNode(imageNamed: "tunaCan")
    private var levelClearedLabel = SKLabelNode()
    private var levelCleared = false
    private var needsRestart = false
    private var endGamePauseTimer: Timer?
    private var challange = SKLabelNode()
    private var levels: [[TCLevelDef]] = []
    private var currentLevel: Int = 0

    private var endScene: SKSpriteNode?
    private var endSceneImageNames = ["endScene1","endScene2","endScene3","endScene4","endScene5","endScene6","endScene7"]
    private var currentEndScene: Int = 0
    private var isGameEnded = false

    override func didMove(to view: SKView) {
        
        cat.name = "kitty"
        cat.position = CGPoint(x: 100, y: 100)
        cat.zPosition = 2
        cat.size = CGSize(width: 170,height: 100)
        addPhysicsBody(toNode: cat, withRectangleOf: CGSize(width: cat.size.width-50, height: cat.size.height-34), withCategoryMask: .cat, contactMasks: [.tunaCan], andCollisionMasks: [.shoe,.sprayBottle,.border])
        cat.physicsBody?.mass = 0.01
        cat.physicsBody?.allowsRotation = false
        cat.physicsBody?.restitution = 0.6
        cat.zPosition = 2
        addChild(cat)
        
        physicsBody = SKPhysicsBody(edgeLoopFrom: frame.insetBy(dx: 0, dy: 0))
        physicsBody?.categoryBitMask = TunaCatObjectType.border.rawValue
        physicsBody?.collisionBitMask = 0
        physicsWorld.contactDelegate = self
        
        kitchen.position = CGPoint(x: size.width/2, y: size.height/2)
        kitchen.zPosition = 0
        kitchen.size = CGSize(width: frame.size.width, height: frame.size.height + 20)
        addChild(kitchen)
        
        tunaCan.name = "tunaCan"
        tunaCan.position = CGPoint(x: size.width * 0.8, y: 302)
        tunaCan.size = CGSize(width: 40, height: 30)
        tunaCan.zPosition = 1
        addPhysicsBody(toNode: tunaCan, ofRadius: 10.0, withCategoryMask: .tunaCan, contactMasks: [.cat], andCollisionMasks: [.border,.cat])
        tunaCan.physicsBody?.isDynamic = false
        tunaCan.physicsBody?.allowsRotation = false
        tunaCan.physicsBody?.affectedByGravity = false
        addChild(tunaCan)
        
        createLevels()
        startActions()
        addLevelClearedLabel()
        addChild(challange)
        backgroundColor = SKColor.white
        
        //timer properties
        timer.fontName = "HelveticaNeue"
        timer.position = CGPoint(x:99,y: frame.size.height - 30)
        timer.fontColor = SKColor.black
        timer.zPosition = 6
        addChild(timer)
    
        
        
        
    }
    
    func endGame() {
        isGameEnded = true
        removeAllActions()
        run(SKAction.repeat(SKAction.sequence([SKAction.run(showEndScene),SKAction.wait(forDuration: 4),SKAction.run({self.currentEndScene += 1})]), count: endSceneImageNames.count))
    }
    
    func showEndScene() {
        removeAllChildren()
        if currentEndScene < endSceneImageNames.count {
            endScene = SKSpriteNode(imageNamed: endSceneImageNames[currentEndScene])
            endScene?.position = CGPoint(x: size.width/2, y: size.height/2)
            endScene?.zPosition = 11
            endScene?.size = CGSize(width: frame.size.width, height: frame.size.height + 20)
            addChild(endScene!)
        }
    }
    
    
    func movingTuna(){
        
        tunaCan.run(
            SKAction.moveBy(x: -frame.size.width + 130, y: 0.0,duration: 12))
        
    }
    
    func movingTunaFast(){
        tunaCan.run(SKAction.sequence([
            SKAction.moveBy(x: -frame.size.width + 130, y: 0.0,duration: 4),
            SKAction.moveBy(x: frame.size.width , y: 0.0,duration: 4),
            SKAction.moveBy(x: -frame.size.width, y: 0.0,duration: 4)]))

    }
    
    func createLevels() {
        let levelDefs = [[],
                         [TCLevelDef(withActionFunc: launchShoe, andActionPause: 2)],
                         [TCLevelDef(withActionFunc: launchShoe, andActionPause: 2),
                         TCLevelDef(withActionFunc: throwSprayBottle, andActionPause: 2),
                         TCLevelDef(withActionFunc: movingTuna, andActionPause: 100)],
                         [TCLevelDef(withActionFunc: launchShoe, andActionPause: 1),
                          TCLevelDef(withActionFunc: throwSprayBottle, andActionPause: 1),
                            TCLevelDef(withActionFunc: movingTunaFast, andActionPause: 100)],
                        [TCLevelDef(withActionFunc: launchShoe, andActionPause: 0.5),
                        TCLevelDef(withActionFunc: throwSprayBottle, andActionPause: 0.5),
                        TCLevelDef(withActionFunc: movingTunaFast, andActionPause: 100)]
        ]
        
        for levelDef in levelDefs {
            levels.append(levelDef)
        }
    }
    
    func startActions() {
        second = 0
        run(SKAction.repeat(SKAction.sequence([SKAction.run({self.second = self.second + 1;self.timer.text = "\(self.second) seconds" }),SKAction.wait(forDuration: 1)]), count: 180))
        
        let level = currentLevel < levels.count ? currentLevel : levels.count - 1
        for levelDef in levels[level] {
            run(SKAction.repeatForever(SKAction.sequence([SKAction.run(levelDef.actionFunc),SKAction.wait(forDuration: levelDef.actionPause)])))
        }
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
        bottle.position = CGPoint(x: (bottle.size.width * -1), y: random(min: 0.0, max: size.height))
        addPhysicsBody(toNode: bottle, withRectangleOf: CGSize(width: bottle.size.width, height: bottle.size.height), withCategoryMask: .sprayBottle, contactMasks: [.cat], andCollisionMasks: [.cat,.shoe])
        bottle.physicsBody?.restitution = 0.5
        addChild(bottle)
        bottle.physicsBody?.applyImpulse(CGVector(dx: 30, dy: 20))
    }
    
    func launchShoe() {
        
        let shoe = SKSpriteNode(imageNamed: "shoe")
        shoe.position = CGPoint(x: frame.size.width + shoe.size.width,y: random(min:0,max:frame.size.height) )
        shoe.size = CGSize(width:90,height:70)
        shoe.zPosition = 5
        addPhysicsBody(toNode: shoe, ofRadius: 10, withCategoryMask: .shoe, contactMasks: [.cat], andCollisionMasks: [.cat,.sprayBottle])
        addChild(shoe)
        shoe.physicsBody?.applyImpulse(CGVector(dx:-10,dy:9))
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
        //tunaCan.physicsBody?.affectedByGravity = false
        tunaCan.position = CGPoint(x: size.width * 0.8, y: 302)
        needsRestart = false
        kitchen.isHidden =  false
        tunaCan.isHidden = false
        cat.isHidden = false
        backgroundColor = SKColor.white
        levelClearedLabel.isHidden = true
        startActions()
    }
    
    func didEnd(_ contact: SKPhysicsContact) {
        let contactMade = contact.bodyA.categoryBitMask | contact.bodyB.categoryBitMask
        if contactMade == TunaCatObjectType.cat.rawValue | TunaCatObjectType.tunaCan.rawValue {
            endGameAndPause(withLevelCleared: true)
        }
    }
    
    func endGameAndPause(withLevelCleared isLevelCleared: Bool) {
        if currentLevel < levels.count {
            levelClearedLabel.isHidden = false
            backgroundColor = SKColor.black
            kitchen.isHidden = true
            tunaCan.isHidden = true
            cat.isHidden = true
            levelCleared = true
            levelClearedLabel.text = isLevelCleared ? "Level Cleared!!!" : "Level Fail!!!"
            currentLevel = isLevelCleared ? currentLevel + 1 : currentLevel
            endGamePauseTimer = Timer.scheduledTimer(timeInterval: 2.0, target: self, selector: #selector(setNeedsRestart), userInfo: nil, repeats: false)
            removeAllActions()
        } else {
            removeAllChildren()
            endGame()
        }
    }
    
    //MARK: PhysicsBody Config Helper Functions
    func addPhysicsBody(toNode node: SKSpriteNode, withRectangleOf size: CGSize, withCategoryMask categoryMask: TunaCatObjectType, contactMasks: [TunaCatObjectType], andCollisionMasks collisionMasks: [TunaCatObjectType]) {
        node.physicsBody = SKPhysicsBody(rectangleOf: size)
        addPhysicsMasks(toNode: node, withCategoryMask: categoryMask, contactMasks: contactMasks, andCollisionMasks: collisionMasks)
    }
    
    func addPhysicsBody(toNode node: SKSpriteNode, ofRadius radius: CGFloat, withCategoryMask categoryMask: TunaCatObjectType, contactMasks: [TunaCatObjectType], andCollisionMasks collisionMasks: [TunaCatObjectType]) {
        node.physicsBody = SKPhysicsBody(circleOfRadius: radius)
        addPhysicsMasks(toNode: node, withCategoryMask: categoryMask, contactMasks: contactMasks, andCollisionMasks: collisionMasks)
    }
    
    func addPhysicsMasks(toNode node: SKSpriteNode, withCategoryMask categoryMask: TunaCatObjectType, contactMasks: [TunaCatObjectType], andCollisionMasks collisionMasks: [TunaCatObjectType]) {
        node.physicsBody?.categoryBitMask = categoryMask.rawValue
        node.physicsBody?.contactTestBitMask = 0
        for contactMask in contactMasks {
            node.physicsBody?.contactTestBitMask = (node.physicsBody?.contactTestBitMask)! | contactMask.rawValue
        }
        node.physicsBody?.collisionBitMask = 0
        for collisionMask in collisionMasks {
            node.physicsBody?.collisionBitMask = (node.physicsBody?.collisionBitMask)! | collisionMask.rawValue
        }
    }
    
    //MARK: Touch Handling Functions
    func touchDown(atPoint pos : CGPoint) {
        guard endGamePauseTimer == nil && !levelCleared else { return }
        if !isGameEnded {
            if needsRestart {
                startOver()
            } else {
                let multiplier = pos.x > size.width/2 ? 1 : -1
                cat.physicsBody?.applyImpulse(CGVector(dx: multiplier*3, dy: 5))
            }
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

public struct TCLevelDef {
    var actionFunc: (() -> Void)
    var actionPause: TimeInterval
            
    init(withActionFunc actionFunc: @escaping (() -> Void), andActionPause actionPause: TimeInterval) {
        self.actionFunc = actionFunc
        self.actionPause = actionPause
    }
}



