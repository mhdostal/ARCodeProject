Introduction

 Augmented Reality (AR) experiences are designed to "augment" the physical world with virtual content that respects real world scale, position, and orientation of a device.  The ArcGIS Runtime SDK for iOS and the ArcGIS Runtime Toolkit for iOS from Esri provide a simplified approach to developing AR solutions.  By overlaying maps and data on top of a live camera feed, users can feel like they are viewing digital content in the real world.
 
 In the case of Runtime, a SceneView displays 3D geographic data as virtual content on top of a camera feed which representing the physical world.  The ArcGISToolkit contains an AR component which allows quick and easy integration of AR into your application for a wide variety of scenarios.

Before getting started, be sure to check out this Quick Start guide to get signed up for a free ArcGIS for Developers subscription. <link to Esri developer page>

There are links at the end if you want more details on anything presented here.

Background
    In order to use the information and code presented in this article you will need to install a couple of items:
    - ArcGIS Runtime SDK for iOS (<link>)
        A modern, high-performance, mapping API that can be used in both Swift and Objective-C
    - ArcGIS Runtime Toolkit for iOS (<link>)
        Open-source code containing a collection of components that will simplify your iOS app development with ArcGIS Runtime.  This includes the AR component we will be showcasing here.

    Information on installing the ArcGIS Runtime SDK can be found [here]()
    Information on incorporting the Toolkit into your project can be found [here]()

    The AR Toolkit component allows you to build appliations using three common AR patterns:

        Flyover – Flyover AR is a kind of AR scenario that allows you to explore a scene using your device as a window into the virtual world. A typical flyover AR scenario will start with the scene’s virtual camera positioned over an area of interest. You can walk around and reorient the device to focus on specific content in the scene.

        Tabletop – A kind of AR scenario where scene content is anchored to a physical surface, as if it were a 3D-printed model. You can walk around the tabletop and view the scene from different angles.

        World-scale – A kind of AR scenario where scene content is rendered exactly where it would be in the physical world. This is used in scenarios ranging from viewing hidden infrastructure to displaying waypoints for navigation. In AR, the real world, rather than a basemap, provides the context for your GIS data.

    The AR toolkit component is comprised of one class: ArcGISARView. This is a subclass of UIView that contains the functionality needed to display an AR experience in your application. It uses ARKit, Apple's augmented reality framework to display the live camera feed and handle real world tracking and synchronization with the Runtime SDK's AGSSceneView. The ArcGISARView is responsible for starting and managing an ARKit session. It uses an AGSLocationDataSource for getting an initial GPS location and when continuous GPS tracking is required.

    Features of ArcGISARView
    
        Allows display of the live camera feed
        Manages ARKit ARSession lifecycle
        Tracks user location and device orientation through a combination of ARKit and the device GPS
        Provides access to an AGSSceneView to display your GIS 3D data over the live camera feed
        ARScreenToLocation method to convert a screen point to a real-world coordinate
        Easy access to all ARKit and AGSLocationDataSource delegate methods

    The steps needed to implement each of the three AR patterns are similar and will be detailed below.

    The rest of the article assumes you have installed the SDK, cloned or forked the Toolkit repo and set up your project to incorporate both.

Methodology

    Creating an AR-enabled application is quite simple using the aformentioned SDK and Toolkit.  The basic steps are:

    - Add the ArcGISARView as a sub-view of your application's view controller view.  This can be accomplished either in code or via a Storyboard/.xib file.
    - Add the required entries to your application's plist file (for the camera and GPS).
    - Create and set an `AGSScene` on the ArcGISARView.sceneView.scene property (the `AGSScene` contains the 3D data you want to display over the live camera feed).
    - Set a location data source on the ArcGISARView (if you want to track the device location).  More on this later...
    - Call `ArcGISARView.startTracking()` to begin tracking location and device motion when your application is ready to begin it's AR session.

    All three AR patterns use the same basic steps.  The differences are in how certain properties of the ArcGISARView are set.  These properties are:

    - originCamera - the initial camera position for the view; used to specify a location when the data is not at your current real-world location.
    - translationFactor - specifies how many meters the camera will move for each meter moved in the real world.  Used in Tabletop and Flyover scenarios.
    - locationDataSource - this specifies the data source used to get location updates.  The SDK provides an AGSCLLocationDataSource which uses CoreLocation to generate location updates.  If you're not interested in location updates (for example in flyover and table top scenarios), this property can be nil.
    - startTracking(_ locationTrackingMode: ARLocationTrackingMode, completion: ((_ error: Error?) -> Void)? = nil) the first argument denotes how you want to use the location data source.  There are three options:
        - ignore: this ignores the location data source updates completely
        - initial: uses only the first location data source location update
        - continuous: use all location updates

  
Using the code
We'll start by creating a basic World-scale AR experience.  This will display a simple base map that you can view by moving your device to see the data around you.

The first thing we need to do is add an ArcGISARView to your application.  This can be done in storyboards/.xib files or in code.  Here's some code which adds the ArcGISARView to your view controller's view:

```
// Creates and ArcGISARView and specifies we want to view the live camera feed.
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
}
```

Next you'll need to add the required privacy keys for the camera and device location to your application's plist file:

```
<key>NSCameraUsageDescription</key>
<string>For displaying the live camera feed</string>

<key>NSLocationWhenInUseUsageDescription</key>
<string>For determining your current location</string>
```

In order to load and display data, create an AGSScene.  For now, we'll simply use a scene containing a basemap, so we can see the camera move in response to device movement:

```
// Create our scene and set it on the arView.sceneView.
let scene = AGSScene(basemapType: .streets)
arView.sceneView.scene = scene
```

Then, create a location data source and set it on arView.  We're using an `AGSCLLocationDataSource`, included in the ArcGISRuntime SDK, to provide location information using UIKit's CoreLocation.

`arView.locationDataSource = AGSCLLocationDataSource()`

The last step is to call `startTracking` on arView to initiate the location and device motion tracking using ARKit.

`arView.startTracking(.continuous)`

We used `.continous` above because we want to continually track the device location using the GPS.  This is common for World-scale AR experiences.  For Tabletop and Flyover experiences, you would use either `.initial`, to get only the initial device location or `.ignore`, when the device location is not needed (for example when setting an origin camera).

At this point you can build and run the app.  The display will look similar to this, but at your geographic location.  Rotating, tilting, and panning the device will cause the display of the data to change accordingly.

Now that we've created a basic AR experience for World-scale scenarios, let's move on to a Flyover scenario.  Flyover AR is a kind of AR scenario that allows you to explore a scene using your device as a window into the virtual world.  A couple of the differences with Flyovers as compared to World-scale, are the ability to explore more than just your immediate surroundings and not using the device location to determine where in the virtual world to position the camera.  ArcGISARView's translationFactor property allows for more movement in the virtual world than that represented in the real world.  The default value for `translationFactor` is 1.0, which means moving your device 1 meter in the real word moves the camera 1 meter in the virtual world.  Setting the `traslationFactor` to 500.0 means that for every meter in the real world the device is moved the camera will move 500.0 meters in the virtual world. We'll also set an origin camera, which represents the initial location and orientation of the camera, instead of using the device location.

We'll use some different data this time, so we'll create a new scene with no base map, a layer representing data along the US-Mexican border, and an elevation source (using an AGSScene extension) to display the data at it's real-world height.

```
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

// Start tracking, but ignore the GPS as we've set an origin camera.
arView.startTracking(.ignore)


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
```

Building and running the app at this point allows you to view the data from a higher altitude and "fly" over the data to view the data in a different way.

[*** when testing, build app from scratch to make sure it works...  put on Github]

The last AR scenario we will cover is Tabletop.  In a Tabletop scenario, data is anchored to a physical surface, as if it were a 3D-printed model. You can walk around the tabletop and view the scene from different angles.

We'll start out the same way as the other two scenarios, by creating a scene and an elevation source:

```
let scene = AGSScene()
scene.addElevationSource()

// Create the Yosemite layer.
let layer = AGSIntegratedMeshLayer(url: URL(string: "https://tiles.arcgis.com/tiles/FQD0rKU8X5sAQfh8/arcgis/rest/services/VRICON_Yosemite_Sample_Integrated_Mesh_scene_layer/SceneServer")!)
scene.operationalLayers.add(layer)

// Set the scene on the arView.sceneView.
arView.sceneView.scene = scene

// Create and set the origin camera.
let camera = AGSCamera(latitude: 37.730776, longitude: -119.611843, altitude: 1213.852173, heading: 0, pitch: 90.0, roll: 0)
arView.originCamera = camera

// Set translationFactor.
arView.translationFactor = 18000

// Start tracking, but ignore the GPS as we've set an origin camera.
arView.startTracking(.ignore)
```

When running the app, if you move the camera around slowly, pointed at the table top or other flat surface you want to anchor the data to, the arView will automatically detect horizontal planes.  These planes can be used to determine the surface you want to anchor to.  The planes can be visualized using the following lines of code and the Plane Toolkit class:

In viewDidLoad:

```
// Set ourself as delegate so we can get ARSCNViewDelegate method calls.
arView.arSCNViewDelegate = self

// MARK: ARSCNViewDelegate
extension ARExample: ARSCNViewDelegate {
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
```

Once a plane has been displayed, the user can tap on it and anchor the data to it.  We can make the sceneView semi-transparent to better see the found planes (in the viewDidLoad method):

```
// Dim the SceneView until the user taps on a surface.
arView.sceneView.alpha = 0.5
```

In order to capture the user tap, you want to implement the AGSGeoViewTouchDelegate like so:

In viewDidLoad:

```
// Set ourself as touch delegate so we can get touch events.
arView.sceneView.touchDelegate = self

// MARK: AGSGeoViewTouchDelegate
extension ARExample: AGSGeoViewTouchDelegate {
    public func geoView(_ geoView: AGSGeoView, didTapAtScreenPoint screenPoint: CGPoint, mapPoint: AGSPoint) {
            // We're in table-top mode and haven't placed the scene yet.  Place the scene at the given point by setting the initial transformation.
            if arView.setInitialTransformation(using: screenPoint) {
                // Show the SceneView now that the user has tapped on the surface.
                UIView.animate(withDuration: 0.5) { [weak self] in
                    self?.arView.sceneView.alpha = 1.0
                }
            }
        }
    }
}
```

The arView.setInitialTransformation method will take the tapped screen point and determine if an ARKit plane intersects the screen point; if one does, it will set the arView.initialTransformation property, which has the effect of anchoring the data to the tapped-on plane.  The above code will also make the sceneView fully opaque.

Run the app and slowly move the device around your table top to find a plane; once one is found, tap on it to place the data.  You can then move the device around the table to view the data from all angles.

Points of Interest

[add links mentioned above]

For more information and detail on using the ArcGISRuntime SDK and the ArcGIS Runtime Toolkit to build compelling, full-featured applications, see the ArcGIS Runtime SDK Guide topic: [Display scenes in augmented reality](https://developers.arcgis.com/ios/latest/objective-c/guide/display-scenes-in-augmented-reality.htm).

