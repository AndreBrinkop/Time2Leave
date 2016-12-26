//
//  ViewController.swift
//  Time2Leave
//
//  Created by André Brinkop on 24.12.16.
//  Copyright © 2016 André Brinkop. All rights reserved.
//

import UIKit
import CoreLocation

class ViewController: UIViewController, UITableViewDelegate, UITableViewDataSource, UISearchResultsUpdating {
    
    // TODO: Remove Dummy Data
    var dummyLocation = CLLocationCoordinate2D(latitude: 52.373715, longitude: 9.731253)
    
    @IBOutlet var tableView: UITableView!
    
    let searchController = UISearchController(searchResultsController: nil)
    
    let tableViewSectionCount = 2
    var autocompleteLocations = [Location]()
    let autocompleteSection = 0
    let autocompleteSectionName = "Search Results"
    var favoriteLocations = [Location]()
    let favoriteSection = 1
    let favoriteSectionName = "Favorite Locations"
    
    var showNoResultsCell: Bool {
        return searchController.isActive && autocompleteLocations.count == 0 && searchController.searchBar.text! != ""
    }

    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // TODO: Remove Dummy Data
        favoriteLocations.append(Location(description: "favorite", id: "1"))
        favoriteLocations.append(Location(description: "location", id: "2"))

        searchController.searchResultsUpdater = self
        searchController.dimsBackgroundDuringPresentation = false
        definesPresentationContext = true
        tableView.tableHeaderView = searchController.searchBar
    }

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
            return favoriteLocations.count
        default:
            return 0
        }
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        if showNoResultsCell && indexPath.section == autocompleteSection {
            return tableView.dequeueReusableCell(withIdentifier: "noResultsCell")!
        }
        
        let cell = tableView.dequeueReusableCell(withIdentifier: "locationCell")!
        
        switch indexPath.section {
        case autocompleteSection:
            cell.textLabel?.text = autocompleteLocations[indexPath.row].description
        case favoriteSection:
            cell.textLabel?.text = favoriteLocations[indexPath.row].description
        default:
            cell.textLabel?.text = ""
        }
    
        return cell
    }
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return tableViewSectionCount
    }


}

