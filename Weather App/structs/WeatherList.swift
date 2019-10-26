//
//  WeatherList.swift
//  Weather App
//
//  Created by Toni Silventoinen on 17/10/2019.
//  Copyright © 2019 Toni Silventoinen. All rights reserved.
//

import Foundation

struct WeatherList: Codable {
    var weather: [Weather]
    var dt_txt: String
    var main: Main
}
