//
//  ViewController.swift
//  ARDiceeeiOS13-14
//
//  Created by Sonali Patel on 12/28/20.
//

import UIKit
import SceneKit
import ARKit

class ViewController: UIViewController, ARSCNViewDelegate {

    @IBOutlet var sceneView: ARSCNView!
    
    var diceNodeArray = [SCNNode]()
    
    override func viewDidLoad() {
        super.viewDidLoad()
    
        self.navigationController?.navigationBar.titleTextAttributes = [NSAttributedString.Key.font: UIFont(name: "Marker Felt", size: 15.0)!]
        self.navigationController?.navigationBar.barTintColor = #colorLiteral(red: 0.3098039329, green: 0.01568627544, blue: 0.1294117719, alpha: 1)
        
        // Set the view's delegate
        sceneView.delegate = self
        
        self.sceneView.debugOptions = [ARSCNDebugOptions.showFeaturePoints]
        
        sceneView.autoenablesDefaultLighting = true
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        if ARWorldTrackingConfiguration.isSupported {
                   
                    let configuration = ARWorldTrackingConfiguration()
                    configuration.planeDetection = ARWorldTrackingConfiguration.PlaneDetection.horizontal
                    configuration.isLightEstimationEnabled = true

                print("IsSupported")
                    sceneView.session.run(configuration, options: [ARSession.RunOptions.resetTracking, ARSession.RunOptions.removeExistingAnchors])
                }
    }
    
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        
        sceneView.session.pause()
    }
    
//MARK: - Dice Rendering Methods
    
    @IBAction func rollAgainButtonPressed(_ sender: UIBarButtonItem) {
        rollAll()
    }
    
    override func motionEnded(_ motion: UIEvent.EventSubtype, with event: UIEvent?) {
        rollAll()
    }
    
    
    @IBAction func removeAllDiceButtonPressed(_ sender: UIBarButtonItem) {
        
        if !diceNodeArray.isEmpty {
            for dice in diceNodeArray {
                dice.removeFromParentNode()
            }
        }
    }
    
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        if let touch = touches.first {
            
            let touchLocation = touch.location(in: sceneView)
            
           //let result = sceneView.hitTest(touchLocation, types: .existingPlaneUsingExtent)
            let results = sceneView.hitTest(touchLocation, options: [SCNHitTestOption.searchMode : 1])
            
            if let hitResult = results.first {
                print(hitResult)
                self.addDice(atLocation: hitResult)
            } else {
                print("Touched somewhere else ")
            }
        }
    }
    
    
    func addDice(atLocation location: SCNHitTestResult) {
        // Create a new scene
        let diceScene = SCNScene(named: "art.scnassets/diceCollada.scn")!
        
        if let diceNode = diceScene.rootNode.childNode(withName: "Dice", recursively: true) {
        
            diceNode.position = SCNVector3(
                location.simdWorldCoordinates.x,
                location.simdWorldCoordinates.y,
                location.simdWorldCoordinates.z
            )
//                        hitResult.worldTransform.columns.3.x,
//                        hitResult.worldTransform.columns.3.y + diceNode.boundingSphere.radius,
//                        hitResult.worldTransform.columns.3.z
//                    )

            self.diceNodeArray.append(diceNode)
            
            // Set the scene to the view
            sceneView.scene.rootNode.addChildNode(diceNode)
            
            self.roll(dice: diceNode)
        }
    }
    
    func roll(dice diceNode: SCNNode) {
        let randomX = Float(arc4random_uniform(4) + 1) * Float(Float.pi/2)
        let randomZ = Float(arc4random_uniform(4) + 1) * Float(Float.pi/2)
        
        diceNode.runAction(
            SCNAction.rotateBy(
                x: CGFloat(randomX) * 5,
                y: 0,
                z: CGFloat(randomZ) * 5,
                duration: 0.5
            )
        )
    }
    
    func rollAll() {
        if !diceNodeArray.isEmpty {
            for dice in diceNodeArray {
                self.roll(dice: dice)
            }
        }
    }

    //MARK: - ARSCNViewDelegate Methods
    
    func renderer(_ renderer: SCNSceneRenderer, didAdd node: SCNNode, for anchor: ARAnchor) {
        
        guard let planeAnchor = anchor as? ARPlaneAnchor  else {
            return
        }
        
        let planeNode = createPlane(withPlaneAnchor: planeAnchor)
        
        node.addChildNode(planeNode)
    }
    
    //MARK: - Plane Rendering Methods
    
    func createPlane(withPlaneAnchor planeAnchor: ARPlaneAnchor) -> SCNNode {
        print("Plane Detected")
        
        let plane = SCNPlane(width: CGFloat(planeAnchor.extent.x), height: CGFloat(planeAnchor.extent.z))
        
        let planeNode = SCNNode()
        
        planeNode.position = SCNVector3(planeAnchor.center.x, 0, planeAnchor.center.z)
        
        planeNode.transform = SCNMatrix4MakeRotation(-Float.pi / 2, 1, 0, 0)
        
        let gridMaterial = SCNMaterial()
        
        gridMaterial.diffuse.contents = UIImage(named: "art.scnassets/grid.png")
        
        plane.materials = [gridMaterial]
        
        planeNode.geometry = plane
        
        return planeNode
    }
}
