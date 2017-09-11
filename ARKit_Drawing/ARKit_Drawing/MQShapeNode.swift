//
//  MQShapeNode.swift
//  ARKit_Drawing
//
//  Created by 杨孟强 on 2017/9/10.
//  Copyright © 2017年 杨孟强. All rights reserved.
//

import UIKit
import SceneKit
import ARKit

class MQShapeNode: SCNNode {
    
    var sceneView:ARSCNView?
    
    var _beganAddVertices = false
    var _quantity:Int = 0
    
    private var _lineVertices:[SCNVector3] = []//线条信息
    private var _lineIndices:[UInt32] = []//线条顶点索引信息
    private var _planeVertices:[SCNVector3] = []//面信息
    private var _planeIndices:[UInt32] = []//面顶点索引信息
    private var _height:Float = 0.0
    
    init(sceneView: ARSCNView) {
        
        super.init()
        
        self.sceneView = sceneView
        if self.sceneView != nil {
            self.sceneView?.scene.rootNode.addChildNode(self)
        }
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    //MARK: 添加一个笔触位置
    func addVertices(vertice: SCNVector3) {
        
        if self._height > 0 {//高度大于0时，不允许添加笔触
            return
        }
        
        if self._beganAddVertices == false {//重新再另外位置画线
            
            if self._quantity > 0 {
                
                for i in 0..<self._quantity-1 {
                    
                    if (self._quantity - i + 1) <= self._lineVertices.count {
                        self._lineIndices.append(UInt32(self._lineVertices.count - (self._quantity - i + 1)))
                        self._lineIndices.append(UInt32(self._lineVertices.count - (self._quantity - i)))
                    }
                }
                
                self.updateDrawing()
            }
            
            self._lineVertices.append(vertice)
            self._quantity = 0;
            self._beganAddVertices = true
        } else {
            
            self._lineVertices.append(vertice)
            self._quantity += 1
            
            if self._quantity >= 3 {
                for i in 0..<self._quantity {

                    if (self._quantity - i + 1) <= self._lineVertices.count {
                        self._lineIndices.append(UInt32(self._lineVertices.count - (self._quantity - i + 1)))
                        self._lineIndices.append(UInt32(self._lineVertices.count - (self._quantity - i)))
                    }
                }
                
                self.updateDrawing()
                self._quantity = 0;
            }
            
        }
    }
    
    func removeAllVertices() {
        self._planeIndices = []
        self._planeVertices = []
        self._lineVertices = []
        self._lineIndices = []
        self._height = 0
        self.updateDrawing()
    }
    
    //MARK: 增加高度
    func addPlaneHeight(height: Float) {
        
        if self._lineIndices.count > 0 &&
            self._lineVertices.count > 0 {
            self._height += height
            if self._height < 0 {
                self._height = 0
            }
            updateDrawing()
        } else {
            self._height = 0
        }
    }
    
    //MARK: 更新图像
    func updateDrawing() {

        if self._lineVertices.count == 0 {
            self._lineIndices = []
            self.geometry = SCNGeometry();
            return
        }
        
        if self._height > 0 {//画面
            
            //初始化
            self._planeIndices = []
            self._planeVertices = []
            
            //
            var i = 0
            let lineIndicesCount = self._lineIndices.count
            while i+1 < lineIndicesCount {
                
                let firstIndice = Int(self._lineIndices[i])
                let secondIndice = Int(self._lineIndices[i+1])
                //是否是一条新的线段
                let isNewLine = (i-1 > 0 && firstIndice == self._lineIndices[i-1]) ? false : true
                
                if isNewLine {
                    
                    let count = UInt32(self._planeVertices.count)
                    //顶点索引
                    self._planeIndices += [0+count, 2+count, 1+count,
                                           1+count, 2+count, 3+count]
                    
                    //四个顶点
                    let firstVertice = self._lineVertices[firstIndice]
                    let secondVertice = self._lineVertices[secondIndice]
                    
                    self._planeVertices += [firstVertice,
                                            SCNVector3Make(firstVertice.x, firstVertice.y+self._height, firstVertice.z),
                                            secondVertice,
                                            SCNVector3Make(secondVertice.x, secondVertice.y+self._height, secondVertice.z)]
                } else {
                    
                    let count = UInt32(self._planeVertices.count-2)
                    //顶点索引
                    self._planeIndices += [0+count, 2+count, 1+count,
                                           1+count, 2+count, 3+count]
                    
                    //添加新的两个顶点
                    let secondVertice = self._lineVertices[secondIndice]
                    self._planeVertices += [secondVertice,
                                            SCNVector3Make(secondVertice.x, secondVertice.y+self._height, secondVertice.z)]
                }
                
                i += 2
            }
            
            let source = SCNGeometrySource(vertices:self._planeVertices)
            let elements = SCNGeometryElement(indices: self._planeIndices, primitiveType: .triangles)
            let geometry = SCNGeometry(sources: [source], elements: [elements])
            
            //渲染器
            geometry.firstMaterial = SCNMaterial()
            geometry.firstMaterial?.isDoubleSided = true
            geometry.firstMaterial?.diffuse.contents = UIColor.red
            
            self.geometry = geometry
            
        } else {//画线
            
            let source = SCNGeometrySource(vertices:self._lineVertices)
            let elements = SCNGeometryElement(indices: self._lineIndices, primitiveType: .line)
            let geometry = SCNGeometry(sources: [source], elements: [elements])
            
            //渲染器
            geometry.firstMaterial = SCNMaterial()
            geometry.firstMaterial?.diffuse.contents = UIColor.red
            
            self.geometry = geometry
        }
    
    }
    
}
