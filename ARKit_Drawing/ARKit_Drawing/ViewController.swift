//
//  ViewController.swift
//  ARKit_Drawing
//
//  Created by 杨孟强 on 2017/9/10.
//  Copyright © 2017年 杨孟强. All rights reserved.
//

import UIKit
import SceneKit
import ARKit

class ViewController: UIViewController, ARSCNViewDelegate, ARSessionDelegate {

    @IBOutlet var sceneView: ARSCNView!
    let scene = SCNScene()
    
    //会话配置开启水平的平面检测(planeDetection默认情况下平面检测关闭的)
    let standardConfiguration: ARWorldTrackingConfiguration = {
        let configuration = ARWorldTrackingConfiguration()
        configuration.planeDetection = .horizontal
        return configuration
    }()
    
    //用配置启动session
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        sceneView.session.run(self.standardConfiguration)//启动
    }
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        sceneView.session.pause()//暂停
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        sceneView.delegate = self
        sceneView.showsStatistics = true
        
        sceneView.scene = scene
    }
    
    // MARK: - Gesture Recognizers
    lazy var shapeNode: MQShapeNode = MQShapeNode(sceneView: self.sceneView)
    
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        self.shapeNode.addTouchesBegan(touches, with: event)
    }
    
    override func touchesMoved(_ touches: Set<UITouch>, with event: UIEvent?) {
        self.shapeNode.addTouchesMoved(touches, with: event)
    }
    
    override func touchesEnded(_ touches: Set<UITouch>, with event: UIEvent?) {
        self.shapeNode.addTouchesEnded(touches, with: event)
    }
    
    override func touchesCancelled(_ touches: Set<UITouch>, with event: UIEvent?) {
        self.shapeNode.addTouchesCancelled(touches, with: event)
    }
    
    //点击清屏
    @IBAction func clickClearTheScreen(_ sender: Any) {
        self.shapeNode.clearTheScreen()
    }
    
    // MARK: - ARSCNViewDelegate
    //一个与新的AR锚点相对应的SceneKit节点已添加到场景中。
    /*根据会话配置，ARKit可以自动向会话添加锚点。该视图为每个新锚点调用此方法一次。ARKit还会为调用add(anchor:)方法为ARAnchor使用会话的方法手动添加的任何对象提供可视内容。您可以通过将几何（或其他SceneKit功能）附加到此节点或添加子节点来为锚点提供可视内容。或者，您可以实现renderer(_:nodeFor:)SCNNode方法来为锚点创建自己的节点（或子类的实例）。*/
    func renderer(_ renderer: SCNSceneRenderer, didAdd node: SCNNode, for anchor: ARAnchor) {

        if anchor is ARPlaneAnchor {

            //获取ARPlaneAnchor
            let planeAnchor = anchor as! ARPlaneAnchor
            /*当ARKit首先检测到一个ARPlaneAnchor平面时，产生的对象具有一个center值(0,0,0)，表示其值的transform位于平面的中心点。
             随着场景分析和平面检测的继续，ARKit可能会确定先前检测到的平面锚点是更大的现实世界表面的一部分，从而增加extent宽度和长度值。平面的新边界可能不会围绕其初始位置对称，所以center点相对于锚（未更改）transform矩阵而改变
            虽然此属性的类型为vector_float3，但平面锚总是二维的，并且总是相对于其
            transform位置仅在x和z方向上定位和定尺寸。（即，该向量的y分量始终为零）*/
            let extent = planeAnchor.extent//估计的检测平面的宽度和长度
            let center = planeAnchor.center
//            let transform = planeAnchor.transform

//            print("node.position:\(node.position)")
//            print(anchor)
//            print("\(transform.columns.0):\(transform.columns.1):\(transform.columns.2):\(transform.columns.3):")

            //添加平面node
            let w_2 = extent.x / 2.0
            let h_2 = extent.z / 2.0
            let lineSource = SCNGeometrySource(vertices:
                [SCNVector3Make(-w_2, 0,  h_2),
                 SCNVector3Make( w_2, 0,  h_2),
                 SCNVector3Make(-w_2, 0, -h_2),
                 SCNVector3Make( w_2, 0, -h_2)])
            let indices:[UInt32] = [0, 1, 1, 3, 3, 2, 2, 0]
            let lineElements = SCNGeometryElement(indices: indices, primitiveType: .line)
            let line = SCNGeometry(sources: [lineSource], elements: [lineElements])
            //渲染器
            line.firstMaterial = SCNMaterial()
            line.firstMaterial?.diffuse.contents = UIColor.orange

            let planeNode = SCNNode(geometry: line)
            planeNode.position = SCNVector3(center)
//            planeNode.transform = SCNMatrix4(transform)

            node.addChildNode(planeNode)
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
    
    // MARK: -
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Release any cached data, images, etc that aren't in use.
    }
}
