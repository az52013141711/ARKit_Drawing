//
//  MQShapeNode+Controller.swift
//  ARKit_Drawing
//
//  Created by 杨孟强 on 2017/9/11.
//  Copyright © 2017年 杨孟强. All rights reserved.
//

import ARKit

extension MQShapeNode {
    
//    /*撤销*/
//    func revoke() {
//        
//    }
//    
//    /*恢复*/
//    func recovery() {
//        
//    }
    
    /**清屏*/
    func clearTheScreen() {
        self.removeAllVertices()
    }
    
    //MARK: - 手势
    func addTouchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        self._beganAddVertices = false
    }
    
    /*添加一次移动手势*/
    func addTouchesMoved(_ touches: Set<UITouch>, with event: UIEvent?) {
        
        if touches.count == 1 {//绘制线条
            
            let firstTouch = touches.first!
            let location = firstTouch.location(in: self.sceneView)
            let pLocation = firstTouch.previousLocation(in: self.sceneView)
            if location.x == pLocation.x && location.y == pLocation.y {
                return
            }
            
            //获取屏幕上当前滑动到点的世界位置
            if let planeHitTestPosition = self.hitTest(location) {
                self.addVertices(vertice: planeHitTestPosition)
            }
            
        } else if touches.count == 2 {//升高面
            
            let firstTouch = touches.first!
            
            let previousLocation = firstTouch.previousLocation(in: self.sceneView)
            let location = firstTouch.location(in: self.sceneView)
            
            if location.y < previousLocation.y {//双指向上滑动
                self.addPlaneHeight(height: 0.01)
            } else if location.y > previousLocation.y {//双指向上滑动
                self.addPlaneHeight(height: -0.01)
            }
        }
    }
    
    func addTouchesEnded(_ touches: Set<UITouch>, with event: UIEvent?) {
        self._beganAddVertices = false
    }
    func addTouchesCancelled(_ touches: Set<UITouch>, with event: UIEvent?) {
        self._beganAddVertices = false
    }

}
