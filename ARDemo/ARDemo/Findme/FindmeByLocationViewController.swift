//
//  FindmeByLocationViewController.swift
//  ARDemo
//
//  Created by 623971951 on 2018/1/24.
//  Copyright © 2018年 syc. All rights reserved.
//

import UIKit
import ARKit
import CoreLocation

class FindmeByLocationViewController: UIViewController {
    
    private lazy var locationService: LocationService = {
        return LocationService()
    }()
    
    private var loadSingleScene: Bool = false
    
    private var sceneView: ARSCNView!
    private var videoRecodeBtn: UIButton!
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        self.navigationItem.title = "查看 findme + spitfire"
        self.view.backgroundColor = UIColor.white
        
        // 录像
        videoRecodeBtn = UIButton(type: UIButtonType.system)
        videoRecodeBtn.setTitle("trans", for: UIControlState.normal)
        videoRecodeBtn.addTarget(self, action: #selector(self.recordBtnAction(sender:)), for: UIControlEvents.touchUpInside)
        let recordBarBtnItem = UIBarButtonItem(customView: videoRecodeBtn)
        self.navigationItem.rightBarButtonItem = recordBarBtnItem
        
        // 获取位置信息
        locationService.startLocation()
        
        // arkit
        sceneView = ARSCNView(frame: self.view.bounds)
        self.view.addSubview(sceneView)
        sceneView.delegate = self
        sceneView.automaticallyUpdatesLighting = true
        sceneView.autoenablesDefaultLighting = true
        sceneView.showsStatistics = true
        sceneView.debugOptions = [ARSCNDebugOptions.showWorldOrigin, ARSCNDebugOptions.showFeaturePoints]
        
        if singleScene != nil && lastLocation != nil{
            // 加载已有场景
            loadSingleScene = true
        }else{
            // 不加载已有场景
            loadSingleScene = false
        }
    }
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        
        UIApplication.shared.isIdleTimerDisabled = true
        
        // 获取当前位置
        if locationService.currentLocation != nil {
            // 结束定位, 省电
            locationService.stopLocation()
        }
        
        if loadSingleScene {
            // 加载已有场景
            sceneView.scene = singleScene
            
            for node in sceneView.scene.rootNode.childNodes{
                print("\(#function) node.position = \(node.position)")
            }
        }
        // session run
        sessionRun()
    }
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        
        UIApplication.shared.isIdleTimerDisabled = false
        
        // 结束定位
        locationService.stopLocation()
        
        // session
        sceneView.session.pause()
    }
    private func sessionRun(){
        let configure = ARWorldTrackingConfiguration()
        configure.worldAlignment = .gravityAndHeading
        sceneView.session.run(configure)
    }
    @objc func recordBtnAction(sender: Any?){
        if loadSingleScene == false {
            // 没有加载场景
            return
        }
        
        // 获取当前位置
        if let location = locationService.currentLocation {
            // 结束定位, 省电
            locationService.stopLocation()
            
            // 加载已有场景
            sceneView.scene = singleScene
            
            // 移动 node
            let translation = MatrixHelper.transformMatrix(for: matrix_identity_float4x4, originLocation: lastLocation, location: location)
            let position = SCNVector3.positionFromTransform(translation)
            
            print("last location = \(lastLocation)")
            print("current location = \(location)")
            print("position = \(position)")
            
            SCNTransaction.begin()
            SCNTransaction.animationDuration = 5
            
            for node in sceneView.scene.rootNode.childNodes{
                print("node.position 0 = \(node.position)")
                
                node.position.x += position.x
                node.position.y += position.y
                node.position.z += position.z
                
                print("node.position 1 = \(node.position)")
            }
            
            SCNTransaction.commit()
            
        }
    }
}
extension FindmeByLocationViewController: ARSCNViewDelegate{
    // MARK: SCN Scene Renderer Delegate 代理
}
