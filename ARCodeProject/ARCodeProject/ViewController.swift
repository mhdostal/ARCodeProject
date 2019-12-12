//
// Copyright © 2019 Esri.
//
// Licensed under the Apache License, Version 2.0 (the "License");
// you may not use this file except in compliance with the License.
// You may obtain a copy of the License at
//
//   http://www.apache.org/licenses/LICENSE-2.0
//
// Unless required by applicable law or agreed to in writing, software
// distributed under the License is distributed on an "AS IS" BASIS,
// WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
// See the License for the specific language governing permissions and
// limitations under the License.
//

import UIKit
import ArcGIS
import ArcGISToolkit
import ARKit

class ViewController: UIViewController {

    // Creates an ArcGISARView and specifies we want to view the live camera feed.
    let arView = ArcGISARView(renderVideoFeed: true)
        
    override func viewDidLoad() {
        super.viewDidLoad()

        // Add the ArcGISARView to our view and set up constraints.
        view.addSubview(arView)
        arView.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            arView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            arView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            arView.topAnchor.constraint(equalTo: view.topAnchor),
            arView.bottomAnchor.constraint(equalTo: view.bottomAnchor)
        ])
        
        //
        // World-scale scenario
        //
        
//        // Create our scene and set it on the arView.sceneView.
//        let scene = AGSScene(url: URL(string: "https://runtime.maps.arcgis.com/home/webscene/viewer.html?webscene=b887e33acae84a0195e725c8c093c69a")!)!
//        arView.sceneView.scene = scene
//
//        arView.locationDataSource = AGSCLLocationDataSource()
        
        //
        // Tabletop scenario
        //
        
//        // Create the scene.
//        let scene = AGSScene()
//        scene.addElevationSource()
//
//        // Create the Yosemite layer.
//        let layer = AGSIntegratedMeshLayer(url: URL(string: "https://tiles.arcgis.com/tiles/FQD0rKU8X5sAQfh8/arcgis/rest/services/VRICON_Yosemite_Sample_Integrated_Mesh_scene_layer/SceneServer")!)
//        scene.operationalLayers.add(layer)
//
//        // Set the scene on the arView.sceneView.
//        arView.sceneView.scene = scene
//
//        // Create and set the origin camera.
//        let camera = AGSCamera(latitude: 37.730776, longitude: -119.611843, altitude: 1213.852173, heading: 0, pitch: 90.0, roll: 0)
//        arView.originCamera = camera
//
//        // Set translationFactor.
//        arView.translationFactor = 18000
//
//        // Set ourself as delegate so we can get ARSCNViewDelegate method calls.
//        arView.arSCNViewDelegate = self
//
//        // Dim the SceneView until the user taps on a surface.
//        arView.sceneView.alpha = 0.5
//
//        // Set ourself as touch delegate so we can get touch events.
//        arView.sceneView.touchDelegate = self
                
        //
        // Flyover scenario
        //
        
        // Create the scene.
        let scene = AGSScene()
        scene.addElevationSource()

        // Create the border layer.
        let layer = AGSIntegratedMeshLayer(url: URL(string: "https://tiles.arcgis.com/tiles/FQD0rKU8X5sAQfh8/arcgis/rest/services/VRICON_SW_US_Sample_Integrated_Mesh_scene_layer/SceneServer")!)

        // Add layer to the scene's operational layers array.
        scene.operationalLayers.add(layer)

        // Set the scene on the arView.sceneView.
        arView.sceneView.scene = scene

        // Create and set the origin camera.
        let camera = AGSCamera(latitude: 32.533664, longitude: -116.924699, altitude: 126.349876, heading: 0, pitch: 90.0, roll: 0)
        arView.originCamera = camera

        // Set translationFactor.
        arView.translationFactor = 1000
    }
    
    override func viewDidAppear(_ animated: Bool) {
        //
        // World-scale scenario
        //
        
//        // For World-scale AR, use .continuous location updates...
//        arView.startTracking(.continuous)
        
        //
        // Tabletop and Flyover scenario
        //

        // For Tabletop and Flyover AR, ignore location updates.
        // Start tracking, but ignore the GPS as we've set an origin camera.
        arView.startTracking(.ignore)
    }
    
    override func viewDidDisappear(_ animated: Bool) {
        arView.stopTracking()
    }
}

// MARK: AGSScene extension.
extension AGSScene {
    /// Adds an elevation source to the given `scene`.
    func addElevationSource() {
        let elevationSource = AGSArcGISTiledElevationSource(url: URL(string: "https://elevation3d.arcgis.com/arcgis/rest/services/WorldElevation3D/Terrain3D/ImageServer")!)
        let surface = AGSSurface()
        surface.elevationSources = [elevationSource]
        surface.name = "baseSurface"
        surface.isEnabled = true
        surface.backgroundGrid.isVisible = false
        surface.navigationConstraint = .none
        baseSurface = surface
    }
}

// MARK: ARSCNViewDelegate
extension ViewController: ARSCNViewDelegate {
    func renderer(_ renderer: SCNSceneRenderer, didAdd node: SCNNode, for anchor: ARAnchor) {
        // Place content only for anchors found by plane detection.
        guard let planeAnchor = anchor as? ARPlaneAnchor else { return }
        
        // Create a custom object to visualize the plane geometry and extent.
        let plane = Plane(anchor: planeAnchor, in: arView.arSCNView)
        
        // Add the visualization to the ARKit-managed node so that it tracks
        // changes in the plane anchor as plane estimation continues.
        node.addChildNode(plane)
    }
    
    func renderer(_ renderer: SCNSceneRenderer, didUpdate node: SCNNode, for anchor: ARAnchor) {
        // Update only anchors and nodes set up by `renderer(_:didAdd:for:)`.
        guard let planeAnchor = anchor as? ARPlaneAnchor,
            let plane = node.childNodes.first as? Plane
            else { return }
        
        // Update extent visualization to the anchor's new bounding rectangle.
        if let extentGeometry = plane.node.geometry as? SCNPlane {
            extentGeometry.width = CGFloat(planeAnchor.extent.x)
            extentGeometry.height = CGFloat(planeAnchor.extent.z)
            plane.node.simdPosition = planeAnchor.center
        }
    }
}

// MARK: AGSGeoViewTouchDelegate
extension ViewController: AGSGeoViewTouchDelegate {
    public func geoView(_ geoView: AGSGeoView, didTapAtScreenPoint screenPoint: CGPoint, mapPoint: AGSPoint) {
        // Place the scene at the given point by setting the initial transformation.
        if arView.setInitialTransformation(using: screenPoint) {
            // Show the SceneView now that the user has tapped on the surface.
            UIView.animate(withDuration: 0.5) { [weak self] in
                self?.arView.sceneView.alpha = 1.0
            }
        }
    }
}

/// Helper class to visualize a plane found by ARKit
class Plane: SCNNode {
    let node: SCNNode
    
    init(anchor: ARPlaneAnchor, in sceneView: ARSCNView) {
        // Create a node to visualize the plane's bounding rectangle.
        let extent = SCNPlane(width: CGFloat(anchor.extent.x), height: CGFloat(anchor.extent.z))
        node = SCNNode(geometry: extent)
        node.simdPosition = anchor.center
        
        // `SCNPlane` is vertically oriented in its local coordinate space, so
        // rotate it to match the orientation of `ARPlaneAnchor`.
        node.eulerAngles.x = -.pi / 2

        super.init()

        node.opacity = 0.6
        guard let material = node.geometry?.firstMaterial
            else { fatalError("SCNPlane always has one material") }
        
        material.diffuse.contents = UIColor.white

        // Add the plane node as child node so they appear in the scene.
        addChildNode(node)
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}
