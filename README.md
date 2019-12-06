# ARCodeProject
This repository contains the companion code for the [Augmented reality with the ArcGIS Runtime SDK for iOS]() [Code Project](https://www.codeproject.com) article.

## Background

Augmented Reality (AR) experiences are designed to "augment" the physical world with virtual content. That means showing virtual content on top of a device's camera feed. As the device is moved around, that virtual content respects the real-world scale, position, and orientation of the camera's view. The *ArcGIS Runtime SDK for iOS* and the *ArcGIS Runtime Toolkit for iOS* from Esri together provide a simplified approach to developing AR solutions that overlay maps and geographic data on top of a live camera feed. Users can feel like they are viewing digital mapping content in the real world.

In Runtime parlance, a `Scene` is a description of a 3D "Map" containing potentially many types of 3D geographic data. A Runtime `SceneView` is a UI component used to display that Scene to the user. When used in conjunction with the ArcGIS Toolkit, a `SceneView` can quickly and easily be turned into an AR experience to display 3D geographic data as virtual content on top of a camera feed.

In order to use the information and code you will need to install a couple of items:
    
- [ArcGIS Runtime SDK for iOS](https://developers.arcgis.com/ios/) - A modern, high-performance, mapping API that can be used in both Swift and Objective-C.
        
- [ArcGIS Runtime Toolkit for iOS](https://github.com/Esri/arcgis-runtime-toolkit-ios) - Open-source code containing a collection of components that will simplify your iOS app development with ArcGIS Runtime.  This includes the AR component we will be showcasing here.  Note: You may have to update the location of the `ArcGISToolkit.xcodeproj` file in the `ARCodeProject` project in order for it to build.

The AR Toolkit component allows you to build applications using three common AR patterns:

**World-scale** – A kind of AR scenario where scene content is rendered exactly where it would be in the physical world. This is used in scenarios ranging from viewing hidden infrastructure to displaying waypoints for navigation. In AR, the real world, rather than a basemap, provides the context for your GIS data.

**Flyover** – Flyover AR is a kind of AR scenario that allows you to explore a scene using your device as a window into the virtual world. A typical flyover AR scenario will start with the scene’s virtual camera positioned over an area of interest. You can walk "through" the data and reorient the device to focus on specific content in the scene.  The origin camera in a flyover scenario is usually above the tallest content in the scene.

**Tabletop** – A kind of AR scenario where scene content is anchored to a physical surface, as if it were a 3D-printed model. You can walk around the tabletop and view the scene from different angles.  The origin camera in a tabletop scenario is usually at the lowest point on the scene.

The AR toolkit component is comprised of one class: `ArcGISARView`. This is a subclass of `UIView` that contains the functionality needed to display an AR experience in your application. It uses ARKit, Apple's augmented reality framework to display the live camera feed and handle real-world tracking and synchronization with the Runtime SDK's `AGSSceneView`. The `ArcGISARView` is responsible for starting and managing an ARKit session. It uses an `AGSLocationDataSource` (a class encapsulating device location information and updates) for getting an initial GPS location and when continuous GPS tracking is required.

## Features of ArcGISARView

- Allows display of the live camera feed
- Manages ARKit ARSession lifecycle
- Tracks user location and device orientation through a combination of ARKit and the device GPS
- Provides access to an `AGSSceneView` to display your GIS 3D data over the live camera feed
- ARScreenToLocation method to convert a screen point to a real-world coordinate
- Easy access to all ARKit and `AGSLocationDataSource` delegate methods

Information on installing the ArcGIS Runtime SDK can be found [here](https://developers.arcgis.com/ios/latest/swift/guide/install.htm).

Information on incorporting the Toolkit into your project can be found [here](https://github.com/Esri/arcgis-runtime-toolkit-ios#instructions).


