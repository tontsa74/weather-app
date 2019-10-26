//
//  CurrentWeatherData.swift
//  Weather App
//
//  Created by Toni Silventoinen on 07/10/2019.
//  Copyright © 2019 Toni Silventoinen. All rights reserved.
//

import Foundation

struct CurrentWeatherData: Codable {
    var name: String
    var main: Main
    var weather: [Weather]
}

struct Main: Codable {
    var temp: Double
}


