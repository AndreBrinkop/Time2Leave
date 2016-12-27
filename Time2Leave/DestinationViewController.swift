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
    
    // TODO: Remove Dummy Data
    var dummyLocation = CLLocationCoordinate2D(latitude: 52.373715, longitude: 9.731253)
    
    // MARK: - Properties
    
    @IBOutlet var tableView: UITableView!
    
    let tableViewSectionCount = 2
    var autocompleteLocations = [Location]()
    let autocompleteSection = 0
    let autocompleteSectionName = "Search Results"
    var favoriteLocations = [FavoriteLocation]()
    let favoriteSection = 1
    let favoriteSectionName = "Favorite Locations"
    
    var fetchedResultsController: NSFetchedResultsController<FavoriteLocation>!
    let searchController = UISearchController(searchResultsController: nil)
    let appDelegate = UIApplication.shared.delegate as! AppDelegate
    
    var showNoResultsCell: Bool {
        return searchController.isActive && autocompleteLocations.count == 0 && searchController.searchBar.text! != ""
    }
    
    // MARK: - Initialization

    override func viewDidLoad() {
        super.viewDidLoad()
        initializeFetchedResultsController()
        initializeSearchController()
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
            //appDelegate.showErrorMessage(title: "Failed to fetch stored Locations!", message: error.localizedDescription)
        }
    }
    
    func initializeSearchController() {
        searchController.searchResultsUpdater = self
        searchController.dimsBackgroundDuringPresentation = false
        definesPresentationContext = true
        tableView.tableHeaderView = searchController.searchBar
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
}

// MARK: - UISearchResultsUpdating
extension DestinationViewController: UISearchResultsUpdating {
    func updateSearchResults(for searchController: UISearchController) {
        let input = searchController.searchBar.text!
        
        GooglePlacesClient.autocomplete(input: input, location: dummyLocation) { locations, error in
            guard error == nil else {
                // TODO: Handle Error
                print(error!)
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
            if showNoResultsCell {
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

