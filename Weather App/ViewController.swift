//
//  ViewController.swift
//  Weather App
//
//  Created by Toni Silventoinen on 07/10/2019.
//  Copyright © 2019 Toni Silventoinen. All rights reserved.
//

// 595ce348cb8653bad98c0db2b8593046
// http://api.openweathermap.org/data/2.5/forecast?id=524901&APPID=595ce348cb8653bad98c0db2b8593046


import UIKit
import CoreLocation

class ViewController: UIViewController, CLLocationManagerDelegate {

    @IBOutlet weak var cityLabel: UILabel!
    @IBOutlet weak var tempLabel: UILabel!
    @IBOutlet weak var informationLabel: UILabel!
    @IBOutlet weak var currentImageView: UIImageView!
    
    var selectedCity: String = "Use GPS"
    var currentWeatherData: CurrentWeatherData?
    var indicator: UIActivityIndicatorView!
    var manager: CLLocationManager?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        manager = CLLocationManager()
        manager?.delegate = self
        
        indicator = UIActivityIndicatorView(style: .gray)
        indicator.center = currentImageView.center
        self.currentImageView.addSubview(indicator)
        
        indicator.startAnimating()
    }

    override func viewWillAppear(_ animated: Bool) {
        self.load()
        // Do any additional setup after loading the view, typically from a nib.
        if (self.selectedCity == "Use GPS") {
            self.getCityGPS()
        } else {
            fetchUrl(city: self.selectedCity)
        }
    }
    
    func fetchUrl(city : String) {
        let formatedCity = city.lowercased()
            .replacingOccurrences(of: " ", with: "+")
            .replacingOccurrences(of: "ö", with: "o")
            .replacingOccurrences(of: "ä", with: "a")
        let url = "https://api.openweathermap.org/data/2.5/weather?q=" + formatedCity + "&APPID=595ce348cb8653bad98c0db2b8593046"
        
        let config = URLSessionConfiguration.default
        
        let session = URLSession(configuration: config)
        
        if let url : URL = URL(string: url) {
            let task = session.dataTask(with: url, completionHandler: doneFetching);
            
            // Starts the task, spawns a new thread and calls the callback function
            task.resume();
            
        } else {
            NSLog("invalid url")
        }
    }
    
    func fetchImg(url : String) {
        
        let config = URLSessionConfiguration.default
        
        let session = URLSession(configuration: config)
        
        if let url : URL = URL(string: url) {
            let task = session.dataTask(with: url, completionHandler: doneFetching);
            
            // Starts the task, spawns a new thread and calls the callback function
            task.resume();
            
        } else {
            NSLog("invalid url")
        }
    }
    
    func doneFetching(data: Data?, response: URLResponse?, error: Error?) {
        if let resstr = String(data: data!, encoding: String.Encoding.utf8) {
            let decoder = JSONDecoder()
            do {
                currentWeatherData = try decoder.decode(CurrentWeatherData.self, from: data!)
                NSLog(resstr)
                NSLog("cwd: \(String(describing: self.currentWeatherData))")
                
                fetchImg(url: "https://openweathermap.org/img/wn/"+(self.currentWeatherData?.weather.first?.icon)!+"@2x.png")
                
            } catch {
                print("error trying to convert data to JSON")
                print(error)
            }
            self.updateUI()
            self.save()

        } else if let icon = UIImage(data: data!) {
            // Execute stuff in UI thread
            DispatchQueue.main.async(execute: {() in
                self.indicator.stopAnimating()
                self.currentImageView.image = icon
            })
        }
    }
    
    func save() {
        NSLog("cities Save")
        // Creates or loads default object
        let defaultDB = UserDefaults.standard
        defaultDB.set(selectedCity, forKey: "selectedCity")
        defaultDB.synchronize()
        
    }
    
    func load() {
        let defaultDB = UserDefaults.standard
        if let city = defaultDB.string(forKey: "selectedCity") {
            self.selectedCity = city
        }
    }
    
    func updateUI() {
        // Execute stuff in UI thread
        DispatchQueue.main.async(execute: {() in
            //if let city = self.currentWeatherData?.name {
                self.cityLabel.text = self.selectedCity
            //}
            if let temp = self.currentWeatherData?.main.temp {
                self.tempLabel.text = String(format: "%.1f", temp-273.15) + " °C"
            }
            if let info = self.currentWeatherData?.weather.first?.description {
                self.informationLabel.text = info
            }
        })
    }
    
    func getCityGPS() {
        manager?.startUpdatingLocation()
        manager?.requestAlwaysAuthorization()
    }
    
    func fetchLocation(location: CLLocation) {
        let clg = CLGeocoder()
        
        clg.reverseGeocodeLocation(location, completionHandler: { (placemarks, error) in
            self.selectedCity = (placemarks?.first?.locality) ?? "not found"
            self.fetchUrl(city: self.selectedCity)
        })
        
    }
    
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]){
        let loc = locations.last
        //NSLog("locationManager: \(loc)")
        fetchLocation(location: loc!)
        
        self.manager?.stopUpdatingLocation()
        
    }
}

