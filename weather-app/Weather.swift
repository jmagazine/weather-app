//
//  Weather.swift
//  weather-app
//
//  Created by Josh Magazine on 7/2/23.
//

import Foundation

struct Weather {
    var locationName: String?
    var temperature: Double?
    var description: String?
    var iconSrc: URL?
    var high: Double?
    var low: Double?
    
    init(locationName: String?, temperature: Double?, description: String?, iconSrc: URL?, high: Double?, low: Double?) {
        self.locationName = locationName
        self.temperature = temperature
        self.description = description
        self.iconSrc = iconSrc
        self.high = high
        self.low = low
        
    }

}

/// Returns a weather object of the current weather of the specified city and state
func getWeather(lat: Double, lon: Double, completion: @escaping (Weather?) -> Void) {
    let apiKey = "f56a11e1e4d7f2ce750d6186ea2c7b7f"
    let urlString = "https://api.openweathermap.org/data/2.5/weather?lat=\(lat)&lon=\(lon)&appid=\(apiKey)"
    
    guard let url = URL(string: urlString) else {
        print("Weather Error: Invalid URL")
        completion(nil)
        return
    }
    
    let session = URLSession.shared
    let task = session.dataTask(with: url) { (data, response, error) in
        if let error = error {
            print("Error: \(error)")
            completion(nil)
            return
        }
        
        if let data = data {
            do {
                if let json = try JSONSerialization.jsonObject(with: data) as? [String: Any] {
                    // parse through json
                    if let main = json["main"] as? [String: Any],
                       let temp = main["temp"] as? Double,
                       let high = main["temp_max"] as? Double,
                       let low = main["temp_min"] as? Double,
                       let weatherArray = json["weather"] as? [[String: Any]],
                       let description = weatherArray[0]["description"] as? String,
                       let iconSrc = weatherArray[0]["icon"] as? String,
                       let locationName = json["name"] as? String{
                        // create weather struct
                        let weather = Weather(locationName: locationName, temperature: temp, description: description, iconSrc:
                                                URL(string:"https://openweathermap.org/img/wn/\(iconSrc)@2x.png"), high: high, low: low)
                        completion(weather)
                    } else {
                        completion(nil)
                    }
                }
            } catch {
                print("Error parsing JSON: \(error)")
                completion(nil)
            }
        }

    }
    
    // Start the API request
    task.resume()
}
