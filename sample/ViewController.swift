//
//  ViewController.swift
//  sample
//
//  Created by kido  on 2022/01/20.
//

import UIKit
import SceneKit
import ARKit

class ViewController: UIViewController, ARSCNViewDelegate {

    @IBOutlet var sceneView: ARSCNView!
    
    let defaultConfige : ARWorldTrackingConfiguration = {
        let confige = ARWorldTrackingConfiguration()
        confige.planeDetection = [.horizontal, .vertical]
        confige.environmentTexturing = .automatic
        return confige
    }()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Set the view's delegate
        sceneView.delegate = self
        
        //光源の追加
        sceneView.autoenablesDefaultLighting = true
        // Create a new scene
        
        
        // Set the scene to the view
     
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)

        // Run the view's session
        sceneView.session.run(defaultConfige)
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        
        // Pause the view's session
        sceneView.session.pause()
    }

    var isTouch : Bool = false
    var touchLocation : CGPoint = .zero  //(0,0)
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        // 画面をタップした際の指が触れた場所の座標をとる
        guard let location = touches.first?.location(in: sceneView) else{
            return
        }
        //上で作った変数にタップした座標を追加する。
        touchLocation = location
        //ball()
        //Box()
        isTouch = true
    }
    
    
    override func touchesMoved(_ touches: Set<UITouch>, with event: UIEvent?) {
        guard let location = touches.first?.location(in: sceneView) else {
            return
        }
        touchLocation = location
    }
    
    override func touchesEnded(_ touches: Set<UITouch>, with event: UIEvent?) {
        //画面タッチが終わったタイミングでisTouchをfalseにして、下のrendererでcreateLine関数が呼び出されないようにする。
        isTouch = false
    }
    
    //球体を表示させる。
    func ball(){
        //球の基本を作る。radiusは丸みの度合いである。数値が高いほど丸くなる。
        let ball = SCNSphere(radius: 0.3)
        
        //球に色や輝きをつける。オブジェクトの装飾
        if let metarial = ball.firstMaterial{
            metarial.lightingModel = .physicallyBased
            metarial.metalness.contents = 1.0
            metarial.metalness.intensity = 1.0
            metarial.reflective.contents = metarial
            metarial.diffuse.contents = UIColor.red
        }
        
        //ノードにジオメトリをセット。
        let ballNode = SCNNode(geometry: ball)
        //ノードの大きさ
        ballNode.scale = SCNVector3(0.2,0.2,0.2)
        
        //ここでZ軸だけ決める。これでカメラの30cm前に表示される。(X,Y,Z)
        let cameraInfront = SCNVector3Make(0, 0, -0.3)
        guard let camera = sceneView.pointOfView else {
            return
        }
        //toの後をnilにすることでワールド座標にできる。
        let worldPosition = camera.convertPosition(cameraInfront, to: nil)
        //ワールド座標からスクリーン座標に変換する。
        var screenPosition = sceneView.projectPoint(worldPosition)
        //タップした場所をスクリーン座標を反映させる。
        screenPosition.x = Float(touchLocation.x)  //X軸
        screenPosition.y = Float(touchLocation.y)  //Y軸
        //スクリーン座標からワールド座標に変換し、finalPositionにセットする。
        let finalPosition = sceneView.unprojectPoint(screenPosition)
        //ノードに作った座標をセットする。
        ballNode.position = finalPosition
        self.sceneView.scene.rootNode.addChildNode(ballNode)
        
    }
    
    //箱を作る。
    func Box(){
        let box = SCNBox(width: 1, height: 1, length: 1, chamferRadius: 0.0)
        let boxNode = SCNNode(geometry: box)
        boxNode.scale = SCNVector3(0.3,0.3,0.3)
        
        let matetial0 = SCNMaterial()
        let matetial1 = SCNMaterial()
        let matetial2 = SCNMaterial()
        let matetial3 = SCNMaterial()
        let matetial4 = SCNMaterial()
        let matetial5 = SCNMaterial()
        
        //Assetsに画像を入れておくことで、物体に画像を貼ることができる。
        matetial0.diffuse.contents = UIImage(named: "kokubann")
        matetial1.diffuse.contents = UIImage(named: "mireBall")
        matetial2.diffuse.contents = UIImage(named: "ramumu")
        matetial3.diffuse.contents = UIImage(named: "rumumuRog")
        matetial4.diffuse.contents = UIImage(named: "phot")
        matetial5.diffuse.contents = UIImage(named: "tree")
        
        box.materials = [matetial0,matetial1,matetial2,matetial3,matetial4,matetial5]
        
        let cameraInfront = SCNVector3Make(0, 0, -0.3)
        guard let camera = sceneView.pointOfView else {
            return
        }
        let worldPosition = camera.convertPosition(cameraInfront, to: nil)
        var screenPosition = sceneView.projectPoint(worldPosition)
        screenPosition.x = Float(touchLocation.x)
        screenPosition.y = Float(touchLocation.y)
        let finalPosition = sceneView.unprojectPoint(screenPosition)
        boxNode.position = finalPosition
        
        //回るだけのモーションの実装
        //.piは180度のことである。　durationは時間のことで、7秒かけて回るということ
       /* let move = SCNAction.rotateBy(x: 0, y: .pi, z: 0, duration: 7)
        let roop = SCNAction.repeatForever(move)
        boxNode.runAction(roop)*/
        
        
        //落ちながら回転し消えるモーションの実装
        let cameraInfront2 = SCNVector3Make(0, -4, -0.3)
        guard let camera = sceneView.pointOfView else {
            return
        }
        let worldPosition2 = camera.convertPosition(cameraInfront2, to: nil)
        let move1 = SCNAction.rotateBy(x: 0, y: .pi, z: 0, duration: 3)
        let move2 = SCNAction.rotateBy(x: 0, y: 0, z: 2, duration: 3)
        let move3 = SCNAction.move(to: worldPosition2 , duration: 8)
        move3.timingMode = .easeIn
        let roop = SCNAction.repeat(move1, count: 2)
        let groupAction = SCNAction.group([roop,move2,move3])
        let fadeOut = SCNAction.fadeOut(duration: 2)
        let sequence = SCNAction.sequence([groupAction,fadeOut])
        
        boxNode.runAction(sequence)
        
        sceneView.scene.rootNode.addChildNode(boxNode)
    }
    
    //線を書く。
    func createLine(){
        //球体の作成とノードにジオメトリ（形状）を追加
        let ball = SCNSphere(radius: 0.005)
        let ballNode = SCNNode(geometry: ball)
        
        //色の追加と大きさの変更
        ballNode.geometry?.firstMaterial?.diffuse.contents = UIColor.red
        ballNode.scale = SCNVector3(1.2,1.2,1.2)
        
        //座標の指定
        let infrontOfCamera = SCNVector3Make(0, 0, -0.3)
        guard let cameraNode = sceneView.pointOfView else {
            return
        }

        let worldPoint = cameraNode.convertPosition(infrontOfCamera, to: nil)
        var screenPoint = sceneView.projectPoint(worldPoint)
        screenPoint.x = Float(touchLocation.x)
        screenPoint.y = Float(touchLocation.y)
        
        let finalPosition = sceneView.unprojectPoint(screenPoint)
        ballNode.position = finalPosition
        sceneView.scene.rootNode.addChildNode(ballNode)
        
    }
  
    
    // MARK: - ARSCNViewDelegate
    
/*
    // Override to create and configure nodes for anchors added to the view's session.
    func renderer(_ renderer: SCNSceneRenderer, nodeFor anchor: ARAnchor) -> SCNNode? {
        let node = SCNNode()
     
        return node
    }
*/
    //アンカーが検出された時に
    func renderer(_ renderer: SCNSceneRenderer, updateAtTime time: TimeInterval) {
        //isTouchがtrueの時にcreateLine関数を呼び出す。
        if isTouch == true {
            createLine()
        }
    }
    
    func session(_ session: ARSession, didFailWithError error: Error) {
        // Present an error message to the user
        
    }
    
    func sessionWasInterrupted(_ session: ARSession) {
        // Inform the user that the session has been interrupted, for example, by presenting an overlay
        
    }
    
    func sessionInterruptionEnded(_ session: ARSession) {
        // Reset tracking and/or remove existing anchors if consistent tracking is required
        
    }
}
