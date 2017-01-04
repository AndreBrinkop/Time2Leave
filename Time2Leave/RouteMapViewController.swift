//
//  RouteMapViewController.swift
//  Time2Leave
//
//  Created by André Brinkop on 04.01.17.
//  Copyright © 2017 André Brinkop. All rights reserved.
//

import UIKit
import MapKit

class RouteMapViewController: UIViewController {
    
    // MARK: - Properties
    
    @IBOutlet var routeMapView: MKMapView!
    
    // MARK: - Functions

    func showRouteOnMap(_ route: Route) {
        routeMapView.removeOverlays(routeMapView.overlays)
        let polylineCoordinates = route.polylineCoordinates
        
        routeMapView.add(MKPolyline.init(coordinates: polylineCoordinates, count: polylineCoordinates.count))
        
        var region = route.polylineBounds
        
        // Add padding
        region.span.latitudeDelta *= Constants.userInterface.mapRegionSpanFactor
        region.span.longitudeDelta *= Constants.userInterface.mapRegionSpanFactor
        
        routeMapView.setRegion(region, animated: false)
    }
}

// MARK: - MKMapViewDelegate
extension RouteMapViewController: MKMapViewDelegate {
    func mapView(_ mapView: MKMapView, rendererFor overlay: MKOverlay) -> MKOverlayRenderer {
        let polylineRenderer = MKPolylineRenderer(overlay: overlay);
        polylineRenderer.strokeColor = Color.darkColor.withAlphaComponent(0.7);
        polylineRenderer.lineWidth = 5;
        return polylineRenderer;
    }
}
