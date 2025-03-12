//
//  WeatherManager.swift
//  Clima
//
//  Created by Vincenzo Sorano on 3/11/25.
//  Copyright © 2025 App Brewery. All rights reserved.
//

import Foundation
import CoreLocation

protocol WeatherManagerDelegate{
    func didUpdateWeather(_ weatherManger:WeatherManager, weather: WeatherModel)
    func didFailWithError(error: Error)
}

struct WeatherManager{
    let weatherURL = "https://api.openweathermap.org/data/2.5/weather?appid=4fc09fdbf5440906bea0adad1fb618fd&units=metric"
    
    var delegate: WeatherManagerDelegate?
    
    
    func fetchWeather(city: String)
    {
        let urlString = "\(weatherURL)&q=\(city)"
        performRequest(with: urlString)
    }
    
    func fetchWeather(latitude: CLLocationDegrees, longitude: CLLocationDegrees)
    {
        let urlString = "\(weatherURL)&lat=\(latitude)&lon=\(longitude)"
        performRequest(with: urlString)
    }
    func performRequest(with urlString: String)
    {
        //1.) create a url
        if let url = URL(string: urlString)
        {
            //2. create a url session
            let session = URLSession(configuration: .default)
            
            //3.) give the session a task
            let task = session.dataTask(with: url) { (data, response, error) in      if error != nil
                {
                self.delegate?.didFailWithError(error: error!)
                return
                }
                
                if let safeData = data
                {
                    if let weather = self.parseJSON(safeData){
                        //left off here
                        self.delegate?.didUpdateWeather(self, weather: weather)
                        
                    }
                }}
            
            //4.) start the task
            task.resume()
            
        }
        
    }
    
    func parseJSON(_ weatherData: Data) -> WeatherModel?
    {
        let decoder = JSONDecoder()
        do{
            let decodedData = try decoder.decode(WeatherData.self, from: weatherData)
            let id = decodedData.weather[0].id
            let temp = decodedData.main.temp
            let name = decodedData.name
            
            let weather = WeatherModel(conditionId: id, cityName: name, temperature: temp)
            return weather
            
        } catch {
            delegate?.didFailWithError(error: error)
            return nil
        }
    }
    
}




