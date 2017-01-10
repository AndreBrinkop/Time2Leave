//
//  RouteDetailViewController.swift
//  Time2Leave
//
//  Created by André Brinkop on 03.01.17.
//  Copyright © 2017 André Brinkop. All rights reserved.
//

import UIKit
import MapKit
import UserNotifications

class RouteDetailViewController: RouteMapViewController {

    // MARK: - IBOutlets
    
    @IBOutlet var tripTypeImageView: UIImageView!
    @IBOutlet var destinationLabel: UILabel!
    
    @IBOutlet var routeSummaryLabel: UILabel!
    @IBOutlet var departureTimeLabel: UILabel!
    @IBOutlet var arrivalTimeLabel: UILabel!
    @IBOutlet var tripDurationLabel: UILabel!
    @IBOutlet var routeWarningsLabel: UILabel!
    @IBOutlet var routeCopyrightLabel: UILabel!
    
    @IBOutlet var reminderDatePicker: UIDatePicker!
    @IBOutlet var datePickerButtons: [CustomButton]!
    
    @IBOutlet var reminderOverlay: UIView!
    @IBOutlet var reminderSetView: UIView!
    @IBOutlet var reminderInformationLabel: UILabel!
    @IBOutlet var reminderCountdownLabel: UILabel!
    @IBOutlet var reminderNotAvailableLabel: UILabel!
    
    // MARK: - Properties
    
    var route: Route {
        return TripDetails.shared.selectedRoute!
    }
    
    var reminderCountdown: Timer?
    var reminderFireDate: Date?
    
    // MARK: - Initialization
    
    override func viewDidLoad() {
        super.viewDidLoad()
        initializeUI()
    }

    private func initializeUI() {
        tripTypeImageView.image = TripDetails.shared.tripType?.image
        destinationLabel.text = TripDetails.shared.destination!.description
        
        showRouteOnMap(route)
        routeSummaryLabel.text = route.summary
        
        let timeStrings = route.times.humanReadable
        departureTimeLabel.text = timeStrings.0
        arrivalTimeLabel.text = timeStrings.1
        tripDurationLabel.text = timeStrings.2
        
        routeWarningsLabel.text = route.warningsString
        routeCopyrightLabel.text = route.copyrights
        
        reminderDatePicker.maximumDate = route.times.departureTime
        
        // Set Date Picker Buttons Enabled State
        for datePickerButton in datePickerButtons {
            guard let timeOffset = getTimeOffsetForDatePickerButton(button: datePickerButton) else {
                break
            }
            
            if Date() >= route.times.departureTime.addingTimeInterval(-timeOffset) {
                datePickerButton.isEnabled = false
            }
        }
        
        refreshUI()
    }
    
    private func checkIfReminderIsAvailable() {
        if reminderDatePicker.minimumDate!.addingTimeInterval(Constants.userInterface.secondsToDepartureForReminderToBecomeAvailable) >= reminderDatePicker.maximumDate! {
            reminderOverlay.isHidden = false
            reminderNotAvailableLabel.text = "To set a reminder the current time must be at least \(Int(Constants.userInterface.secondsToDepartureForReminderToBecomeAvailable / 60.0)) minutes before the departure time"
        }
    }
    
    // MARK: - Refresh User Interface
    
    func refreshUI() {
        reminderDatePicker.minimumDate = DateHelper.roundDateUpToNextMinute(Date())
        refreshTimer()
        checkIfReminderIsAvailable()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        refreshUI()
    }
    
    // MARK: - Date Picker Buttons Action
    
    @IBAction func setReminderDatePickerToSpecificTime(_ sender: UIButton) {
        guard let absOffsetFromDepartureTime = getTimeOffsetForDatePickerButton(button: sender) else {
            return
        }
        
        let newDate = route.times.departureTime.addingTimeInterval(-absOffsetFromDepartureTime)
        reminderDatePicker.setDate(newDate, animated: true)
    }
    
    // MARK: - Reminder
    
    @IBAction func setReminderButtonClicked(_ sender: CustomButton) {
        let appName = Bundle.main.infoDictionary![kCFBundleNameKey as String] as! String
        let calendar = Calendar.current
        let minutesBetweenReminderAndDeparture = calendar.dateComponents([.minute], from: reminderDatePicker.date, to: route.times.departureTime).minute!
        
        UNUserNotificationCenter.current().requestAuthorization(options: [.alert, .sound]) { granted, error in
            DispatchQueue.main.async {
                // GUARD: Allowed to display Notifications
                guard granted == true, error == nil else {
                    self.displayInfoAlert(title: "Not allowed to show Notifications", message: "Please go to your device settings and allow \(appName) to display Notifications if you want to set a reminder for this route.")
                    return
                }
                // GUARD: Is Notification time in the future
                guard Date() < self.reminderDatePicker.date else {
                    self.displayInfoAlert(title: "Reminder needs to be in the future", message: "Please adjust your selected time.")
                    return
                }
                // GUARD: Is Notification at least one minute before departure
                guard minutesBetweenReminderAndDeparture > 0 else {
                    self.displayInfoAlert(title: "Reminder needs to be before your departure time", message: "Please adjust your selected time.")
                    return
                }
                
                self.createReminder(fireDate: self.reminderDatePicker.date, minutesBetweenReminderAndDeparture: minutesBetweenReminderAndDeparture)
            }
        }
    }
    
    private func createReminder(fireDate: Date, minutesBetweenReminderAndDeparture: Int) {
        // Create Reminder
        let reminderText = String(format: "You have to leave in %d minutes to arrive at \"%@\" at %@ on %@",
                                  minutesBetweenReminderAndDeparture,
                                  TripDetails.shared.destination!.description,
                                  DateHelper.humanReadableTime(date: reminderDatePicker.date),
                                  DateHelper.humanReadableDate(date: reminderDatePicker.date))
        
        let reminderContent = UNMutableNotificationContent()
        reminderContent.title = "Reminder"
        reminderContent.body = reminderText
        reminderContent.sound = UNNotificationSound.default()
        reminderContent.categoryIdentifier = Constants.reminder.contentCategoryIdentifier
        
        let reminderDateComponents = NSCalendar.current.dateComponents([.second, .minute, .hour, .day, .month, .year, .timeZone], from: fireDate)
        let trigger = UNCalendarNotificationTrigger(dateMatching: reminderDateComponents,
                                                    repeats: false)
        
        let reminderRequest = UNNotificationRequest(
            identifier: Constants.reminder.identifier,
            content: reminderContent,
            trigger: trigger
        )
        
        UNUserNotificationCenter.current().add(
            reminderRequest, withCompletionHandler: nil)
        
        // Show Reminder Information
        let reminderInformationText = String(format: "Reminder set for %@ on %@\n(%d minutes before departure)",
                                             DateHelper.humanReadableTime(date: fireDate),
                                             DateHelper.humanReadableDate(date: fireDate),
                                             minutesBetweenReminderAndDeparture)
        
        reminderInformationLabel.text = reminderInformationText
        reminderOverlay.isHidden = false
        reminderSetView.isHidden = false

        reminderFireDate = fireDate
        reminderCountdown = Timer.scheduledTimer(timeInterval: 1.0, target:self, selector: #selector(refreshTimer), userInfo: nil, repeats: true)
        refreshUI()
    }
    
    func refreshTimer() {
        guard let reminderFireDate = reminderFireDate else {
            return
        }
        guard reminderFireDate > Date() else {
            deleteReminder()
            return
        }
        reminderCountdownLabel.text = DateHelper.humanReadableTime(seconds: Int(reminderFireDate.timeIntervalSince(Date())))
    }
    
    @IBAction func deleteReminder() {
        reminderCountdown?.invalidate()
        reminderFireDate = nil
        self.reminderOverlay.isHidden = true
        self.reminderSetView.isHidden = true
        
        UNUserNotificationCenter.current().removePendingNotificationRequests(withIdentifiers: [Constants.reminder.identifier])
    }
    
    // MARK: - Display Directions In Google Maps
    
    @IBAction func displayDirectionsInGoogleMaps(_ sender: Any) {
        GoogleDirectionsClient.displayDirectionsInGoogleMaps(originCoordinatesString: TripDetails.shared.originCoordinatesString!, destination: TripDetails.shared.destination!, tripType: TripDetails.shared.tripType!)
    }
    
    // MARK: - Helper methods
    
    private func displayInfoAlert(title: String, message: String) {
        let notificationsNotAvailableAlert = UIAlertController.init(title: title, message: message, preferredStyle: .alert)
        notificationsNotAvailableAlert.addAction(UIAlertAction(title: "Dismiss", style: .default, handler: nil))
        
        DispatchQueue.main.async {
            self.present(notificationsNotAvailableAlert, animated: true)
        }
    }
    
    private func getTimeOffsetForDatePickerButton(button: UIButton) -> TimeInterval? {
        switch button.tag {
        case 0: // 5min before
            return 60.0 * 5.0
        case 1: // 15min before
            return 60.0 * 15.0
        case 2: // 30min before
            return 60.0 * 30.0
        default:
            return nil
        }
    }
}
