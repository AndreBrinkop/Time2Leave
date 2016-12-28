//
//  DestinationViewController.swift
//  Time2Leave
//
//  Created by André Brinkop on 24.12.16.
//  Copyright © 2016 André Brinkop. All rights reserved.
//

import UIKit
import CoreData
import CoreLocation

class DestinationViewController: UIViewController {
    
    // MARK: - Properties
    
    @IBOutlet var tableView: UITableView!
    
    let tableViewSectionCount = 2
    var autocompleteLocations = [Location]()
    let autocompleteSection = 0
    let autocompleteSectionName = "Search Results"
    var favoriteLocations = [FavoriteLocation]()
    let favoriteSection = 1
    let favoriteSectionName = "Favorite Locations"
    
    var userLocation: CLLocation?
    var selectedDestination: Location?
    
    var fetchedResultsController: NSFetchedResultsController<FavoriteLocation>!
    let locationManager = CLLocationManager()
    let searchController = UISearchController(searchResultsController: nil)
    let appDelegate = UIApplication.shared.delegate as! AppDelegate
    
    var showNoResultsCell: Bool {
        return searchController.isActive && searchController.searchBar.text! != "" && autocompleteLocations.count == 0
    }
    
    var showWaitingForLocationCell: Bool {
        return searchController.isActive && userLocation == nil
    }
    
    // MARK: Alerts
    
    private(set) var noLocationFoundAlert: UIAlertController!
    private(set) var needLocationAlert: UIAlertController!
    private(set) var waitingForLocationAfterSelectionAlert: UIAlertController!
    
    private(set) var networkProblemAlert: UIAlertController!
    
    // MARK: - Initialization

    override func viewDidLoad() {
        super.viewDidLoad()
        initializeFetchedResultsController()
        initializeSearchController()
        initializeLocationManager()
        initializeAlerts()
    }
    
    func initializeFetchedResultsController() {
        let request: NSFetchRequest<FavoriteLocation> = FavoriteLocation.fetchRequest()
        
        let sortDescriptor = NSSortDescriptor(key: "locationDescription", ascending: true)
        request.sortDescriptors = [sortDescriptor]
        
        fetchedResultsController = NSFetchedResultsController(fetchRequest: request, managedObjectContext: appDelegate.persistentContainer.viewContext, sectionNameKeyPath: nil, cacheName: nil)
        fetchedResultsController.delegate = self
        
        do {
            try fetchedResultsController.performFetch()
            if let response = fetchedResultsController.fetchedObjects {
                favoriteLocations = response
            }
        } catch {
            appDelegate.showErrorMessage(title: "Failed to retrieve favorite Locations!", message: error.localizedDescription)
        }
    }
    
    func initializeSearchController() {
        searchController.searchResultsUpdater = self
        searchController.dimsBackgroundDuringPresentation = false
        definesPresentationContext = true
        tableView.tableHeaderView = searchController.searchBar
        searchController.delegate = self
    }
    
    func initializeLocationManager() {
        locationManager.delegate = self
        locationManager.desiredAccuracy = Constants.userLocation.accuracy
    }
    
    func initializeAlerts() {
        noLocationFoundAlert = UIAlertController.init(title: "Need User Location", message: "Your location could not be found!", preferredStyle: .alert)
        needLocationAlert = UIAlertController.init(title: "Need User Location", message: "Please activate the location services for this app!", preferredStyle: .alert)
        waitingForLocationAfterSelectionAlert = UIAlertController.init(title: "Destination selected", message: "Waiting for GPS location to continue..", preferredStyle: .alert)
        waitingForLocationAfterSelectionAlert.addAction(UIAlertAction(title: "Cancel", style: .cancel, handler: { action in self.selectedDestination = nil }))
        
        networkProblemAlert = UIAlertController.init(title: "Could not search for destinations", message: "Network problem", preferredStyle: .alert)
        networkProblemAlert.addAction(UIAlertAction(title: "Cancel", style: .cancel, handler: nil))
    }
    
    // MARK: - Actions
    
    func toggleFavorite(location: Location) {
        let context = appDelegate.persistentContainer.viewContext
        
        if !favoriteLocations.contains { $0.locationId == location.id } {
            // add favorite
            let _ = FavoriteLocation(context: context, location: location)
        } else {
            // delete favorite
            let favoriteLocation = favoriteLocations.filter { $0.locationId == location.id }.first!
            context.delete(favoriteLocation)
        }
        
        appDelegate.saveContext()
    }
    
    func foundPositionAndSelectedDestination() {
        TripDetails.setOriginAndDestination(originCoordinates: userLocation!.coordinate, destination: selectedDestination!)
        performSegue(withIdentifier: "destinationSelected", sender: self)
    }
}

// MARK: - UISearchControllerDelegate
extension DestinationViewController: UISearchControllerDelegate {
    func didPresentSearchController(_ searchController: UISearchController) {
        tableView.reloadData()
    }
    
    func didDismissSearchController(_ searchController: UISearchController) {
        tableView.reloadData()
    }
}

// MARK: - CLLocationManagerDelegate
extension DestinationViewController: CLLocationManagerDelegate {
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        dismissLocationErrorAlerts()
        userLocation = locations.last!

        if selectedDestination != nil {
            foundPositionAndSelectedDestination()
        }
        
        updateSearchResults(for: searchController)
    }
    
    func locationManager(_ manager: CLLocationManager, didFailWithError error: Error) {
        dismissLocationErrorAlerts()
        switch error {
        case CLError.locationUnknown:
            present(noLocationFoundAlert, animated: true)
            locationManager.requestLocation()
        default:
            present(needLocationAlert, animated: true)
        }
    }
    
    func locationManager(_ manager: CLLocationManager, didChangeAuthorization status: CLAuthorizationStatus) {
        dismissLocationErrorAlerts()
        if status == .notDetermined {
            locationManager.requestWhenInUseAuthorization()
        }
        if status == .denied || status == .restricted {
            present(needLocationAlert, animated: true)
        }
        if status == .authorizedWhenInUse {
            locationManager.requestLocation()
        }
    }
    
    private func dismissLocationErrorAlerts() {
        noLocationFoundAlert.dismiss(animated: true, completion: nil)
        needLocationAlert.dismiss(animated: true, completion: nil)
        waitingForLocationAfterSelectionAlert.dismiss(animated: true, completion: nil)
    }
}

// MARK: - UISearchResultsUpdating
extension DestinationViewController: UISearchResultsUpdating {
    func updateSearchResults(for searchController: UISearchController) {
        let input = searchController.searchBar.text!
        
        guard let userLocation = userLocation else {
            return
        }
        
        GooglePlacesClient.autocomplete(input: input, location: userLocation.coordinate) { locations, error in
            guard error == nil else {
                self.searchController.searchBar.text = ""
                self.networkProblemAlert.message = error?.localizedDescription
                self.present(self.networkProblemAlert, animated: true)
                return
            }
            
            self.autocompleteLocations = locations!
            self.tableView.reloadData()
        }
    }
}

// MARK: - UITableViewDataSource
extension DestinationViewController: UITableViewDataSource {
    func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        if self.tableView(tableView, numberOfRowsInSection: section) == 0 {
            return nil
        }
        
        switch section {
        case autocompleteSection:
            return autocompleteSectionName
        case favoriteSection:
            return favoriteSectionName
        default:
            return nil
        }
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        switch section {
        case autocompleteSection:
            if showNoResultsCell || showWaitingForLocationCell {
                return 1
            }
            return autocompleteLocations.count
        case favoriteSection:
            let sections = fetchedResultsController.sections!
            let sectionInfo = sections[0]
            return sectionInfo.numberOfObjects
        default:
            return 0
        }
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        if showWaitingForLocationCell && indexPath.section == autocompleteSection {
            let cell = tableView.dequeueReusableCell(withIdentifier: "waitingForLocationTableViewCell") as! WaitingForLocationTableViewCell
            cell.activitySpinner.startAnimating()
            return cell
        }
        if showNoResultsCell && indexPath.section == autocompleteSection {
            return tableView.dequeueReusableCell(withIdentifier: "noResultsCell")!
        }
        
        let cell = tableView.dequeueReusableCell(withIdentifier: "locationCell") as! LocationTableViewCell
        cell.destinationViewController = self
        
        switch indexPath.section {
        case autocompleteSection:
            cell.setLocation(autocompleteLocations[indexPath.row])
            cell.isFavorite = favoriteLocations.contains(where: { $0.locationId == cell.location.id })
        case favoriteSection:
            let indexPath = IndexPath.init(row: indexPath.row, section: 0)
            cell.setLocation(fetchedResultsController.object(at: indexPath).location, isFavorite: true)
        default:
            cell.setLocation(nil)
        }
    
        return cell
    }
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return tableViewSectionCount
    }
}

// MARK: - UITableViewDelegate
extension DestinationViewController: UITableViewDelegate {
    
    func tableView(_ tableView: UITableView, shouldHighlightRowAt indexPath: IndexPath) -> Bool {
        if let _ = tableView.cellForRow(at: indexPath) as? LocationTableViewCell {
            return true
        }
        return false
    }
    
    //tableViewselect
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        guard let locationCell = tableView.cellForRow(at: indexPath) as? LocationTableViewCell else {
            return
        }
        
        selectedDestination = locationCell.location
        tableView.deselectRow(at: indexPath, animated: true)
        
        if userLocation == nil {
            present(waitingForLocationAfterSelectionAlert, animated: true)
            return
        }
        
        foundPositionAndSelectedDestination()
    }
    
}

// MARK: - NSFetchedResultsControllerDelegate
extension DestinationViewController: NSFetchedResultsControllerDelegate {
    func controllerWillChangeContent(_ controller: NSFetchedResultsController<NSFetchRequestResult>) {
        tableView.beginUpdates()
    }
    
    func controllerDidChangeContent(_ controller: NSFetchedResultsController<NSFetchRequestResult>) {
        if let results = fetchedResultsController.fetchedObjects {
            favoriteLocations = results
            
            for visibleCell in tableView.visibleCells {
                if let visibleCell = visibleCell as? LocationTableViewCell {
                    visibleCell.isFavorite = favoriteLocations.contains(where: { $0.locationId == visibleCell.location.id })
                }
            }
        }
        tableView.endUpdates()
        
        // Force update of section headers
        tableView.beginUpdates()
        tableView.endUpdates()
    }
    
    func controller(_ controller: NSFetchedResultsController<NSFetchRequestResult>, didChange anObject: Any, at indexPath: IndexPath?, for type: NSFetchedResultsChangeType, newIndexPath: IndexPath?) {
        switch type {
        case .insert:
            let newIndexPath = IndexPath.init(row: newIndexPath!.row, section: favoriteSection)
            tableView.insertRows(at: [newIndexPath], with: .fade)
        case .delete:
            let indexPath = IndexPath.init(row: indexPath!.row, section: favoriteSection)
            tableView.deleteRows(at: [indexPath], with: .fade)
        default:
            break
        }
    }
}

