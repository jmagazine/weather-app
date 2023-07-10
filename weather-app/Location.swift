//
//  Location.swift
//  weather-app
//
//  Created by Josh Magazine on 7/6/23.
//

import Foundation
import CoreLocation

struct Location{
    let result_type:String
    let suburb: String?
    let city: String?
    let county:String?
    let state: String?
    let country: String
    let lat:Double
    let lon:Double
}

func convertToLocation(location: CLLocation) -> Location{
    let unknown = "unknown"
    return Location(result_type: "CLLocation", suburb: unknown, city: unknown, county: unknown, state: unknown, country: unknown, lat: location.coordinate.latitude, lon: location.coordinate.longitude)
}

struct GeoLocation: Decodable {
    let type: String
    let features: [Feature]
}

struct Feature: Decodable {
    let type: String
    let properties: Properties
}

struct Properties: Decodable {
    let result_type:String
    let suburb: String?
    let city: String?
    let state: String?
    let county:String?
    let country:String
    let lat:Double
    let lon: Double
}



func getLocations(text: String, completion: @escaping ([Location]?) -> Void){
    if let apiKey = ProcessInfo.processInfo.environment["weathersearchapikey"]{
        
        let q = text.split(separator: " ").joined(separator: "-")
        
        let urlString = "https://api.geoapify.com/v1/geocode/autocomplete?apiKey=\(apiKey)&text=\(q)"
        
        guard let url = URL(string: urlString) else{
            print("Location error: Invalid url")
            completion(nil)
            return
        }
        
        let session = URLSession.shared
        
        // perform get request
        let task = session.dataTask(with: url){(data, resoponse, error) in
            if let error = error{
                print("Error: \(error)")
                completion(nil)
            }
            
            if let data = data{
                do{
                    
                    // parse through data
                    let gl = try JSONDecoder().decode(GeoLocation.self, from: data)
                    var locations = []
                    for feature in gl.features{
                        // get location
                        let location = Location(result_type: feature.properties.result_type,
                                                suburb: feature.properties.suburb ?? nil,
                                                city:feature.properties.city ?? nil,
                                                county: feature.properties.county ?? nil,
                                                state: feature.properties.state ?? nil,
                                                country:feature.properties.country,
                                                lat:feature.properties.lat,
                                                lon: feature.properties.lon)
                        locations.append(location)
                    }
                    completion(locations as? [Location])
                    return
                } catch {
                    print("Error parsing json: \(error)")
                    completion(nil)
                    return
                    
                }
            }
        }
        // start call
        task.resume()
    }else{
        print("Could not find api key, aborting...")
        return
    }
}
