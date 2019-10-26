//
//  FiveDaysTableViewCell.swift
//  Weather App
//
//  Created by Toni Silventoinen on 10/10/2019.
//  Copyright © 2019 Toni Silventoinen. All rights reserved.
//

import Foundation
import UIKit

class FiveDaysTableViewCell: UITableViewCell {
    
    @IBOutlet weak var iconUIImageView: UIImageView!
    @IBOutlet weak var iconImageView: UIView!
    @IBOutlet weak var weatherlabel: UILabel!
    @IBOutlet weak var timeLabel: UILabel!
    
    func setFiveDay(weatherList: WeatherList) {
        
        let txt = weatherList.weather.first?.main ?? ""
        let temp = String(format: "%.1f", weatherList.main.temp-273.15) + " °C"
        weatherlabel.text = "\(txt) \(temp)"
        timeLabel.text = weatherList.dt_txt
        
        if let id = weatherList.weather.first?.icon {
            if let file = self.loadCustomObjectFromFile(filename: id) {
                NSLog("found img: \(id)")
                if let img = file[id] {
                    if (img != nil) {
                        iconUIImageView.image = img
                    } else {
                        NSLog("waiting...")
                    }
                }
            } else {
                NSLog("fetch img: \(id)")
                //self.saveCustomObjectToFile(filename: id, obj: [id:nil])
                self.fetchImg(id: id)
            }
        }
    }
    
    func fetchImg(id: String) {
        let url = "https://openweathermap.org/img/wn/"+id+".png"
        let config = URLSessionConfiguration.default
        let session = URLSession(configuration: config)
        
        if let url : URL = URL(string: url) {
            let task = session.dataTask(with: url, completionHandler: { data, response, error in
                if let img = UIImage(data: data!) {
                    DispatchQueue.main.async(execute: {() in
                        self.iconUIImageView.image = img
                    })
                    self.saveCustomObjectToFile(filename: id, obj: [id:img])
                }
            })
            // Starts the task, spawns a new thread and calls the callback function
            task.resume();
        } else {
            NSLog("invalid url")
        }
    }
    
    func saveCustomObjectToFile(filename: String, obj: [String : UIImage?]) {
        NSLog("save icon: \(filename)")
        let pathWithFileName = self.giveDirectory(filename: filename)
        
        do {
            let data = try NSKeyedArchiver.archivedData(withRootObject: obj, requiringSecureCoding: false)
            try data.write(to: URL(fileURLWithPath: pathWithFileName))
        } catch {
            NSLog("error in saving")
        }
        
    }
    
    func loadCustomObjectFromFile(filename: String) -> [String : UIImage?]? {
        NSLog("load icons")
        let pathWithFileName = self.giveDirectory(filename: filename)
        do {
            let data = try Data(contentsOf: URL(fileURLWithPath: pathWithFileName))
            let p = try NSKeyedUnarchiver.unarchiveTopLevelObjectWithData(data) as! [String : UIImage?]
            
            return p
        } catch {
            NSLog("could not load: \(filename)")
        }
        return nil
    }
    
    
    
    func giveDirectory(filename: String) -> String {
        
        // Searches file system for a path that meets the criteria given by the
        // arguments. On iOS the last two arguments are always the same! (Mac OS X has several
        // more options)
        //
        // Returns array of strings, in iOS only one string in the array.
        let documentDirectories =
            NSSearchPathForDirectoriesInDomains(FileManager.SearchPathDirectory.documentDirectory,
                                                FileManager.SearchPathDomainMask.userDomainMask, true)
        
        // Fetch the only document directory found in the array
        let documentDirectory = documentDirectories[0]
        let pathWithFileName = "\(documentDirectory)/icon_\(filename).png"
        
        return pathWithFileName
    }
}
