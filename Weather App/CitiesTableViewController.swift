//
//  CitiesTableViewController.swift
//  Weather App
//
//  Created by Toni Silventoinen on 10/10/2019.
//  Copyright © 2019 Toni Silventoinen. All rights reserved.
//

import Foundation

import UIKit
import CoreLocation

class CitiesTableViewController: UITableViewController, CLLocationManagerDelegate {
    
    @IBOutlet weak var addTextField: UITextField!
    
    @IBAction func editButton(_ sender: UIButton) {
        tableView.isEditing.toggle()
        
        if (tableView.isEditing) {
            sender.setTitle("✅", for: .normal)
        } else {
            sender.setTitle("Edit", for: .normal)
        }
    }
    
    @IBAction func addButton(_ sender: Any) {
        addNewCity()
        
    }
    
    var manager: CLLocationManager?
    var indicator: UIActivityIndicatorView!
    
    var cities = ["Use GPS", "Helsinki", "Tampere", "Turku"]
    var selectedCity: String?
    
    override func viewWillAppear(_ animated: Bool) {
        self.load()
    }
    
    override func viewDidLoad() {
        
        manager = CLLocationManager()
        manager?.delegate = self
        
    }
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        NSLog("table \(cities[indexPath.row])")
        
        if (cities[indexPath.row] == "Use GPS") {
            getCityGPS()
        } else {
            self.selectedCity = cities[indexPath.row]
        }
        
        self.save()
    }
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return self.cities.count
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "city", for: indexPath)
        
        cell.textLabel?.text = self.cities[indexPath.row]
        
        
        return cell
    }
    
    
    override func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCell.EditingStyle, forRowAt indexPath: IndexPath) {
        if editingStyle == .delete {
            cities.remove(at: indexPath.row)
            
            tableView.beginUpdates()
            tableView.deleteRows(at: [indexPath], with: .automatic)
            tableView.endUpdates()
            self.save()
        }
    }
    
    override func tableView(_ tableView: UITableView, canEditRowAt indexPath: IndexPath) -> Bool {
        if (cities[indexPath.row] != "Use GPS") {
            return true
        }
        return false
    }
    
    override func tableView(_ tableView: UITableView, canMoveRowAt indexPath: IndexPath) -> Bool {
        if (cities[indexPath.row] != "Use GPS") {
            return true
        }
        return false
    }
    
    override func tableView(_ tableView: UITableView, moveRowAt sourceIndexPath: IndexPath, to destinationIndexPath: IndexPath) {
        let itemToMove = cities[sourceIndexPath.row]
        cities.remove(at: sourceIndexPath.row)
        cities.insert(itemToMove, at: destinationIndexPath.row)
        
        self.save()
    }
    
    func save() {
        NSLog("cities Save")
        // Creates or loads default object
        let defaultDB = UserDefaults.standard
        defaultDB.set(selectedCity, forKey: "selectedCity")
        defaultDB.set(cities, forKey: "cities")
        defaultDB.synchronize()
        
    }
    
    func load() {
        let defaultDB = UserDefaults.standard
        if let city = defaultDB.string(forKey: "selectedCity") {
            self.selectedCity = city
        }
        if let c = defaultDB.array(forKey: "cities") {
            self.cities = c as! [String]
        }
    }
    
    func addNewCity() {
        if let city = addTextField.text {
            if (city == "") {
                return
            }
            if (!cities.contains(city)) {
                cities.append(city)
                
                let indexPath = IndexPath(row: cities.count - 1, section: 0)
                tableView.beginUpdates()
                tableView.insertRows(at: [indexPath], with: .automatic)
                tableView.endUpdates()
                
                tableView.selectRow(at: indexPath, animated: true, scrollPosition: UITableView.ScrollPosition.bottom)
                self.tableView(tableView, didSelectRowAt: indexPath)
            } else {
                if let rowIndex = cities.firstIndex(of: city) {
                    let indexPath = IndexPath(row: rowIndex, section: 0)
                    tableView.selectRow(at: indexPath, animated: true, scrollPosition: .bottom)
                    self.tableView(tableView, didSelectRowAt: indexPath)
                }
            }
            
            // close keyboard
            view.endEditing(true)
            
            addTextField.text = ""
        }
    }
    
    func getCityGPS() {
        indicator = UIActivityIndicatorView(style: .gray)
        self.addTextField.rightViewMode = .always
        self.addTextField.rightView = indicator
        self.addTextField.addSubview(indicator)
        
        indicator.startAnimating()
        manager?.startUpdatingLocation()
        manager?.requestAlwaysAuthorization()
    }
    
    func fetchLocation(location: CLLocation) {
        let clg = CLGeocoder()
        
        clg.reverseGeocodeLocation(location, completionHandler: { (placemarks, error) in
            self.addTextField.text = (placemarks?.first?.locality) ?? "not found"
            self.addNewCity()
        })
        
        indicator.stopAnimating()
    }
    
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]){
        let loc = locations.last
        //NSLog("locationManager: \(loc)")
        fetchLocation(location: loc!)
        
        self.manager?.stopUpdatingLocation()
        
    }
}

