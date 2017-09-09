//
//  GameViewController.swift
//  Kosmonaut
//
//  Created by David Szemenkar on 2017-09-04.
//  Copyright © 2017 David Szemenkar. All rights reserved.
//

import UIKit
import QuartzCore
import SceneKit

struct bodyNames{
    static let Person = 0x1 >> 1
    static let Coin = 0x1 >> 2
}

class GameViewController: UIViewController, SCNSceneRendererDelegate, SCNPhysicsContactDelegate {

    let scene = SCNScene()
    let cameraNode = SCNNode()
    
    var person = SCNNode()
    
    let firstBox = SCNNode()
    
    var goingLeft = Bool()
    var tempBox = SCNNode()
    var boxNumber = Int()
    var prevBoxNumber = Int()
    
    var firstOne = Bool()
    
    var score = Int()
    var highscore = Int()
    
    var dead = Bool()
    
    
    override func viewDidLoad() {
        self.createScene()
        scene.physicsWorld.contactDelegate = self
    }
    
    func fadeIn(node : SCNNode){
        node.opacity = 0
        node.runAction(SCNAction.fadeIn(duration: 0.5))
    }
    func fadeOut(node : SCNNode){
        let move = SCNAction.move(to: SCNVector3Make(node.position.x, node.position.y - 2, node.position.z), duration: 0.5)
        node.runAction(move)
        node.runAction(SCNAction.fadeOut(duration: 0.5))
    }
    
    /*func createCoin(box : SCNNode){
        scene.physicsWorld.gravity = SCNVector3Make(0, 0, 0)

        let spin = SCNAction.rotate(by: CGFloat(Double.pi), around: SCNVector3Make(0, 0.5, 0), duration: 0.5)
        let randomNumber = arc4random() % 8
        if randomNumber == 3{
            let coinScene = SCNScene(named: "coin.dae")
            let coin = coinScene?.rootNode.childNode(withName: "coin", recursively: true)
            coin?.position = SCNVector3Make(box.position.x, box.position.y + 2, box.position.z)
            coin?.scale = SCNVector3Make(0.2, 0.2, 0.2)
            
            coin?.physicsBody = SCNPhysicsBody(type: SCNPhysicsBodyType.dynamic, shape: SCNPhysicsShape(node: coin!, options: nil))
            coin?.physicsBody?.categoryBitMask = bodyNames.Coin
            coin?.physicsBody?.contactTestBitMask = bodyNames.Person
            coin?.physicsBody?.collisionBitMask = bodyNames.Person
            coin?.physicsBody?.isAffectedByGravity = false
                
            scene.rootNode.addChildNode(coin!)
            coin?.runAction(SCNAction.repeatForever(spin))
            fadeIn(node: coin!)
        }
    }*/
    /*func physicsWorld(_ world: SCNPhysicsWorld, didBegin contact: SCNPhysicsContact) {
        let nodeA = contact.nodeA
        let nodeB = contact.nodeB
        
        if nodeA.physicsBody?.categoryBitMask == bodyNames.Coin && nodeB.physicsBody?.categoryBitMask == bodyNames.Person {
            nodeA.removeFromParentNode()
            addScore()
            
        }
        
        else if nodeA.physicsBody?.categoryBitMask == bodyNames.Person && nodeB.physicsBody?.categoryBitMask == bodyNames.Coin{
            nodeB.removeFromParentNode()
            addScore()
        }
    }*/
    
    func addScore(){
        score += 1
        print(score)
        
        if score > highscore{
            
            highscore = score
            
        }
    }
    
    func renderer(_ renderer: SCNSceneRenderer, updateAtTime time: TimeInterval){
        //if dead == false {
        let deleteBox = self.scene.rootNode.childNode(withName: "\(prevBoxNumber)", recursively: true)
        let currentBox = self.scene.rootNode.childNode(withName: "\(prevBoxNumber + 1)", recursively: true)
        
        if (deleteBox?.position.x)! > person.position.x + 1 || (deleteBox?.position.z)! > person.position.z + 1{
            prevBoxNumber += 1
            fadeOut(node: deleteBox!)
            deleteBox?.removeFromParentNode()
            createBox()
        }
        
        // Check so player does not fall of the stage
        if person.position.x > (currentBox?.position.x)! - 0.4 && person.position.x < (currentBox?.position.x)! + 0.4 || person.position.z > (currentBox?.position.z)! - 0.4 && person.position.z < (currentBox?.position.z)! + 0.4{
            // On platform
        }
        else{
            die()
            dead = true
        }
        //}
    }
    
    func die(){
        person.runAction(SCNAction.move(to: SCNVector3Make(person.position.x, person.position.y - 5, person.position.y), duration: 1))
        
        let wait = SCNAction.wait(duration: 0.5)
        let sequence = SCNAction.sequence([wait,SCNAction.run({ node in
            self.scene.rootNode.enumerateChildNodes({ node, stop in
                node.removeFromParentNode()
            })
        }), SCNAction.run({ node in
            self.createScene()
        })])
        
        person.runAction(sequence)
    }
    
    func createBox(){
        tempBox = SCNNode(geometry: firstBox.geometry)
        let previousBox = scene.rootNode.childNode(withName: "\(boxNumber)", recursively: true)
        
        boxNumber += 1
        tempBox.name = "\(boxNumber)"
        
        let randomNumber = arc4random() % 2
        
        switch randomNumber{
        case 0:
            tempBox.position = SCNVector3Make((previousBox?.position.x)! - firstBox.scale.x, (previousBox?.position.y)!, (previousBox?.position.z)!)
            if firstOne == true {
                firstOne = false
                goingLeft = false
            }
            break
        case 1:
            tempBox.position = SCNVector3Make((previousBox?.position.x)!, (previousBox?.position.y)!, (previousBox?.position.z)! - firstBox.scale.z)
            if firstOne == true {
                firstOne = false
                goingLeft = true
            }
            break
        default:
            
            break
        }
        self.scene.rootNode.addChildNode(tempBox)
        //createCoin(box: tempBox)
        fadeIn(node: tempBox)
    }
    
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        //createBox()
        if goingLeft == false{
            person.removeAllActions()
            person.runAction(SCNAction.repeatForever(SCNAction.move(by: SCNVector3Make(-100, 0, 0), duration: 20)))
            goingLeft = true
        }
        else{
            person.removeAllActions()
            person.runAction(SCNAction.repeatForever(SCNAction.move(by: SCNVector3Make(0, 0, -100), duration: 20)))
            goingLeft = false
        }
    }
    
    func createScene(){
        boxNumber = 0
        prevBoxNumber = 0
        firstOne = true
        dead = false
    
        //let scoreDefault = userDefaults
        
        let sceneView = self.view as! SCNView
        sceneView.delegate = self
        sceneView.scene = scene
        
        //Create Person
        
        let personGeo = SCNSphere(radius: 0.2)
        person = SCNNode(geometry: personGeo)
        let personMat = SCNMaterial()
        personMat.diffuse.contents = UIColor.white
        personGeo.materials = [personMat]
        person.position = SCNVector3Make(0, 1.0, 0)
        
        person.physicsBody = SCNPhysicsBody(type: SCNPhysicsBodyType.static, shape: SCNPhysicsShape(node: person, options: nil))
        person.physicsBody?.categoryBitMask = bodyNames.Person
        person.physicsBody?.collisionBitMask = bodyNames.Coin
        person.physicsBody?.contactTestBitMask = bodyNames.Coin
        person.physicsBody?.isAffectedByGravity = false
        scene.rootNode.addChildNode(person)
        
        //Create Camera
        
        cameraNode.camera = SCNCamera()
        cameraNode.camera?.usesOrthographicProjection = true
        cameraNode.camera?.orthographicScale = 4
        cameraNode.position = SCNVector3Make(20, 20, 20)
        cameraNode.eulerAngles = SCNVector3Make(-45, 45, 0)
        let constraint = SCNLookAtConstraint(target: person)
        constraint.isGimbalLockEnabled = true
        self.cameraNode.constraints = [constraint]
        scene.rootNode.addChildNode(cameraNode)
        person.addChildNode(cameraNode)
        
        //Create Box
        let firstBoxGeo = SCNBox(width: 1, height: 1.5, length: 1, chamferRadius: 0)
        firstBox.geometry = firstBoxGeo
        let boxMaterial = SCNMaterial()
        boxMaterial.diffuse.contents = UIColor(red: 0.8, green: 0.4, blue: 0.4, alpha: 1.0)
        firstBoxGeo.materials = [boxMaterial]
        firstBox.position = SCNVector3Make(0, 0, 0)
        scene.rootNode.addChildNode(firstBox)
        firstBox.name = "\(boxNumber)"
        
        for _ in 0...7{
            createBox()
        }
        
        // Create Light
        
        let light = SCNNode()
        light.light = SCNLight()
        light.light?.type = SCNLight.LightType.directional
        light.eulerAngles = SCNVector3Make(-45, 45, 0)
        scene.rootNode.addChildNode(light)
        
        /*let light2 = SCNNode()
        light2.light = SCNLight()
        light2.light?.type = SCNLight.LightType.directional
        light2.eulerAngles = SCNVector3Make(45, 45, 0)
        scene.rootNode.addChildNode(light2)*/
    }

    
}
