//
//  FiveDaysViewController.swift
//  Weather App
//
//  Created by Toni Silventoinen on 17/10/2019.
//  Copyright © 2019 Toni Silventoinen. All rights reserved.
//https://api.openweathermap.org/data/2.5/forecast?q=tampere&APPID=595ce348cb8653bad98c0db2b8593046

import Foundation
import UIKit

class FiveDaysViewController: UIViewController, UITableViewDataSource, UITableViewDelegate {

    @IBOutlet weak var tableView: UITableView!
    
    var selectedCity: String = ""
    var forecastData: ForecastData?
    var weatherList: [WeatherList] = []
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        tableView.delegate = self
        tableView.dataSource = self
    }
    
    override func viewWillAppear(_ animated: Bool) {
        self.load()
        // Do any additional setup after loading the view, typically from a nib.
        fetchUrl(city: self.selectedCity)
    }

    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return weatherList.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "FiveDaysCell") as! FiveDaysTableViewCell
        
        cell.setFiveDay(weatherList: self.weatherList[indexPath.row])
        
        return cell
    }
    
    func fetchUrl(city : String) {
        let formatedCity = city.lowercased()
            .replacingOccurrences(of: " ", with: "+")
            .replacingOccurrences(of: "ö", with: "o")
            .replacingOccurrences(of: "ä", with: "a")
        let url = "https://api.openweathermap.org/data/2.5/forecast?q=" + formatedCity + "&APPID=595ce348cb8653bad98c0db2b8593046"
        
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
        let decoder = JSONDecoder()
        do {
            forecastData = try decoder.decode(ForecastData.self, from: data!)
            
            self.weatherList = forecastData?.list ?? []
            
        } catch {
            print("error trying to convert data to JSON")
            print(error)
        }
        self.updateUI()
    }
    
    func updateUI() {
        // Execute stuff in UI thread
        DispatchQueue.main.async(execute: {() in
            self.tableView.reloadData()
        })
    }
    
    func load() {
        let defaultDB = UserDefaults.standard
        if let city = defaultDB.string(forKey: "selectedCity") {
            self.selectedCity = city
        }
    }
}
