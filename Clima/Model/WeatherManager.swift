//
//  WeatherManager.swift
//  Clima
//
//  Created by Utkarsh Gupta on 30/08/24.
//  Copyright © 2024 App Brewery. All rights reserved.
//

import Foundation

protocol WeatherManagerDelegate {
    func didUpdateWeather(_ weatherManager: WeatherManager, weather: WeatherModel) -> Void
}

struct WeatherManager {
    var uri = "https://api.openweathermap.org/data/2.5/weather?appid=1b4a6937735b53571059866960b78141&units=metric"
    var delegate: WeatherManagerDelegate?
    
    func fetchWeather(cityName: String) {
        let uriString = "\(uri)&q=\(cityName)"
        makeRequest(with: uriString)
    }
    
    func makeRequest(with uriString: String) {
        if let url = URL(string: uriString) {
            let session = URLSession(configuration: .default)
            let task = session.dataTask(with: url) {
                (data, response, error) in
                if(error != nil) {
                    print(error!)
                    return
                }
                if let safeData = data {
                    if let weather = parseData(safeData) {
                        delegate?.didUpdateWeather(self, weather: weather)
                    }
                }
            }
            task.resume()
        }
    }
    
    // _ before name makes it a non named parameter
    func parseData(_ weatherData: Data) -> WeatherModel? {
        // Automatically decodes using the same struct as the JSON
        let decoder = JSONDecoder()
        do {
            let decodedData = try decoder.decode(WeatherData.self, from: weatherData)
            let weather = WeatherModel(conditionID: decodedData.weather[0].id, temperature: decodedData.main.temp, cityName: decodedData.name)
            return weather
        } catch {
            print(error)
            return nil
        }
    }
}
