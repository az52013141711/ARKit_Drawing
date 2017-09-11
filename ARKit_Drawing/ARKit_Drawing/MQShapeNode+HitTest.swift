//
//  MQShapeNode+HitTest.swift
//  ARKit_Drawing
//
//  Created by 杨孟强 on 2017/9/11.
//  Copyright © 2017年 杨孟强. All rights reserved.
//

import ARKit

extension MQShapeNode {
    
    /* point一个点在2D坐标系中的坐标,如果该点在世界中是一个平面锚上的位置返回SCNVector3，否则返回nil*/
    func hitTest(_ point: CGPoint) -> SCNVector3? {
        
        var planeHitTestPosition:SCNVector3? = nil
        
        //            ARHitTestResult.ResultType:
        //            featurePoint 由ARKit自动识别的点是连续表面的一部分，但没有相应的锚点。
        //            estimatedHorizontalPlane 通过搜索（没有相应的锚）检测到的现实平面，其方向垂直于重力。
        //            existingPlane 已经在场景中的平面锚（用planeDetection选项检测到），而不考虑平面的大小。
        //            existingPlaneUsingExtent 已经在场景中的平面锚（用planeDetection选项检测到），考虑平面的有限大小。
        let planeHitTestResults = self.sceneView?.hitTest(point, types: .existingPlaneUsingExtent)
        if let result = planeHitTestResults?.first {
            
            let translation = result.worldTransform.columns.3
            planeHitTestPosition = SCNVector3Make(translation.x, translation.y, translation.z)
        }
        
        return planeHitTestPosition
    }
    
    /* 检测point点(一个点在2D坐标系中的坐标)是否在Self上*/
    func isHitTestSelfNode(_ point: CGPoint) -> Bool {
        
        var isSelfNode = false
        let hitTestResults = self.sceneView?.hitTest(point, options: [.firstFoundOnly:true])
        if let hitTestResult = hitTestResults?.first {
            if hitTestResult.node == self {
                isSelfNode = true
            }
        }
        
        return isSelfNode
    }
}
