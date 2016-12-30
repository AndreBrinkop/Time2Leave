//
//  RouteViewController.swift
//  Time2Leave
//
//  Created by André Brinkop on 30.12.16.
//  Copyright © 2016 André Brinkop. All rights reserved.
//

import UIKit
import MapKit

class RouteViewController: UIViewController {

    // MARK: - Properties
    
    @IBOutlet var routeMapView: MKMapView!
    
    // MARK: - Initialization
    
    override func viewDidLoad() {
        super.viewDidLoad()
        initializeMapView()
    }
    
    func initializeMapView() {
        let polylineCoordinates = TripDetails.route!.polylineCoordinates
        routeMapView.add(MKPolyline.init(coordinates: polylineCoordinates, count: polylineCoordinates.count))
        
        let region = TripDetails.route!.polylineBounds
        routeMapView.setRegion(region, animated: false)
    }
}

// MARK: - MKMapViewDelegate
extension RouteViewController: MKMapViewDelegate {
    func mapView(_ mapView: MKMapView, rendererFor overlay: MKOverlay) -> MKOverlayRenderer {
        let polylineRenderer = MKPolylineRenderer(overlay: overlay);
        polylineRenderer.strokeColor = Color.darkColor.withAlphaComponent(0.7);
        polylineRenderer.lineWidth = 5;
        return polylineRenderer;
    }
}
