//
//  RoutesViewController.swift
//  Time2Leave
//
//  Created by André Brinkop on 30.12.16.
//  Copyright © 2016 André Brinkop. All rights reserved.
//

import UIKit
import MapKit

class RoutesViewController: UIViewController {

    // MARK: - Properties
    
    @IBOutlet var routeMapView: MKMapView!
    @IBOutlet var routesTableView: UITableView!
    var selectedRoute: Route!
    
    var routes: [Route] {
        return TripDetails.shared.routes!
    }
    
    // MARK: - Initialization
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        // select first route in the table
        let indexPath = IndexPath(row: 0, section: 0)
        routesTableView.selectRow(at: indexPath, animated: animated, scrollPosition: .bottom)
        tableView(routesTableView, didSelectRowAt: indexPath)
    }
    
    // MARK: - Update UI
    
    func updateSelectedRoute(_ selectedRoute: Route) {
        self.selectedRoute = selectedRoute
        
        routeMapView.removeOverlays(routeMapView.overlays)
        let polylineCoordinates = selectedRoute.polylineCoordinates
        routeMapView.add(MKPolyline.init(coordinates: polylineCoordinates, count: polylineCoordinates.count))
        
        let region = selectedRoute.polylineBounds
        routeMapView.setRegion(region, animated: false)
    }
    
    // MARK: - Actions
    
    @IBAction func continueButtonClicked(_ sender: UIBarButtonItem) {
        // TODO: Segue to next page
        print("continue")
        performSegue(withIdentifier: "routeSelected", sender: self)
    }
}

// MARK: - MKMapViewDelegate
extension RoutesViewController: MKMapViewDelegate {
    func mapView(_ mapView: MKMapView, rendererFor overlay: MKOverlay) -> MKOverlayRenderer {
        let polylineRenderer = MKPolylineRenderer(overlay: overlay);
        polylineRenderer.strokeColor = Color.darkColor.withAlphaComponent(0.7);
        polylineRenderer.lineWidth = 5;
        return polylineRenderer;
    }
}

// MARK: - UITableViewDataSource
extension RoutesViewController: UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return routes.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "routeCell") as! RouteTableViewCell
        let route = routes[indexPath.row]

        cell.initialize(route: route)
        return cell
    }
}

// MARK: - UITableViewDelegate
extension RoutesViewController: UITableViewDelegate {
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let route = routes[indexPath.row]
        updateSelectedRoute(route)
    }
}
