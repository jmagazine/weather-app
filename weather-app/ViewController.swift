//
//  ViewController.swift
//  weather-app
//
//  Created by Josh Magazine on 7/1/23.
//

import UIKit
import CoreLocation
import MapKit

class ViewController: UIViewController, CLLocationManagerDelegate{
    var weather: Weather?
    var locations: [Location] = []
    let subView = UIView();
    let weatherIcon = UIImageView();
    let locationLabel = UILabel();
    let searchTextField = UITextField();
    let searchIcon = UIImageView();
    let searchBarContainer = UIView();
    let timeLabel = UILabel();
    let locationManager = CLLocationManager();
    let temperatureLabel = UILabel();
    let highLowLabel = UILabel();
    let descriptionLabel = UILabel();
    let searchOptionsTableView = UITableView();
    let reuseIdentifier = "searchOptionsReuseIdentifier"
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
        view.backgroundColor = UIColor(red: 80/255, green: 115/255, blue: 240/255, alpha:0.72)

        enableLocationServices()
        setupConstraints();
        
    }
    
    func configureView(){
        searchTextField.placeholder = "Enter a location"
        searchTextField.backgroundColor = .red;
        searchTextField.translatesAutoresizingMaskIntoConstraints = false;
        searchTextField.backgroundColor = searchBarContainer.backgroundColor;
        searchTextField.font = UIFont(name: "Arial", size: 25)
        searchTextField.returnKeyType = .search
        searchTextField.enablesReturnKeyAutomatically = true
        searchTextField.addTarget(self, action: #selector(searchTextFieldDidChange(_:)), for: .editingChanged)
        searchTextField.delegate = self
        searchBarContainer.layer.cornerRadius = 25;
        searchBarContainer.layer.shadowColor = UIColor.black.cgColor
        searchBarContainer.layer.shadowOpacity = 0.5
        searchBarContainer.layer.shadowOffset = CGSize(width: 2, height: 2)
        searchBarContainer.layer.shadowRadius = 4
        searchBarContainer.layer.masksToBounds = false
        searchBarContainer.backgroundColor = UIColor(red: 217/255, green: 217/255, blue: 217/255, alpha: 1)
        searchBarContainer.translatesAutoresizingMaskIntoConstraints = false;
        searchBarContainer.addSubview(searchTextField);
        searchIcon.image = UIImage(named: "searchIcon");
        searchIcon.translatesAutoresizingMaskIntoConstraints = false;
        searchOptionsTableView.translatesAutoresizingMaskIntoConstraints = false
        searchOptionsTableView.dataSource = self
        searchOptionsTableView.delegate = self
        searchOptionsTableView.backgroundColor = .none
        searchOptionsTableView.register(searchOptionsTableViewCell.self, forCellReuseIdentifier: reuseIdentifier)
        searchOptionsTableView.clipsToBounds = true
        searchOptionsTableView.rowHeight = 48
        searchOptionsTableView.layer.cornerRadius = searchBarContainer.layer.cornerRadius
        searchBarContainer.addSubview(searchIcon)
        
        view.addSubview(searchBarContainer)
        
        locationLabel.font = .monospacedDigitSystemFont(ofSize: 45, weight: .bold)
        locationLabel.textColor = .lightGray
        locationLabel.translatesAutoresizingMaskIntoConstraints = false;
        subView.addSubview(locationLabel);
        
        descriptionLabel.translatesAutoresizingMaskIntoConstraints = false;
        descriptionLabel.font = .monospacedDigitSystemFont(ofSize: 18, weight: .light)
        descriptionLabel.textColor = .lightGray
        subView.addSubview(descriptionLabel);
        weatherIcon.translatesAutoresizingMaskIntoConstraints = false
        subView.addSubview(weatherIcon);
        locationManager.delegate = self;
        
        temperatureLabel.text = "\(String(describing: toCelcius(degrees:weather?.temperature ?? 0))) ° C"
        temperatureLabel.translatesAutoresizingMaskIntoConstraints  = false
        temperatureLabel.font = .monospacedDigitSystemFont(ofSize: 36, weight: .semibold)
        temperatureLabel.textColor = .lightGray
        subView.addSubview(temperatureLabel)
        
        highLowLabel.translatesAutoresizingMaskIntoConstraints = false;
        highLowLabel.font = .systemFont(ofSize: 20)
        highLowLabel.textColor = .lightGray
        subView.addSubview(highLowLabel)
        
        
        timeLabel.translatesAutoresizingMaskIntoConstraints = false;
        timeLabel.font = .systemFont(ofSize: 15)
        timeLabel.textColor = .lightGray
        updateTime()
        subView.addSubview(timeLabel)
        Timer.scheduledTimer(timeInterval: 1.0, target: self, selector: #selector(updateTime), userInfo: nil, repeats: true)
        
        
        subView.translatesAutoresizingMaskIntoConstraints = false
        
        view.addSubview(subView)
        view.addSubview(searchOptionsTableView)
    }
    
    func getData(from url: URL, completion: @escaping (Data?, URLResponse?, Error?) -> ()) {
        URLSession.shared.dataTask(with: url, completionHandler: completion).resume()
    }
    
    func enableLocationServices(){
        switch locationManager.authorizationStatus{
            
        case .notDetermined:
            print("authorizationStatus is not determined")
            locationManager.requestAlwaysAuthorization()
            break
        case .restricted, .denied:
            print("authorizationStatus is restricted/denied")
            break
        case .authorizedWhenInUse:
            print("authorizationStatus is authorizedWhenInUse")
            break
        case .authorizedAlways:
            print("authorizationStatus is authorizedAlways")
            locationManager.desiredAccuracy = kCLLocationAccuracyBest
            locationManager.pausesLocationUpdatesAutomatically = true
            locationManager.activityType = CLActivityType.automotiveNavigation
            print("good to proceed with startLocationService ...")
            self.startLocationService()
            break
        @unknown default:
            fatalError()
        }
    }
    
    func startLocationService(){
        print("startLocationService")
        if(CLLocationManager.isMonitoringAvailable(for: CLCircularRegion.self)) {
            if(locationManager.authorizationStatus == .authorizedAlways || locationManager.authorizationStatus == .authorizedWhenInUse ){
                print("always auth allowed - on to requestLocation and start region monitoring...")
                locationManager.requestLocation()
            }
        }
    }
    
    func toCelcius(degrees: Double) -> Double{
        return degrees-273.15
    }
    
    
    // returns
    func toFahrenheit(degrees: Double) -> Double {
        return toCelcius(degrees:degrees) * 9/5 + 32
    }
    
    @objc func searchTextFieldDidChange(_ textField: UITextField) {
        // Show or hide the search options table view based on the text field's content
        if textField.text?.isEmpty ?? true {
            searchOptionsTableView.isHidden = true
            searchOptionsTableView.backgroundColor = .clear
        } else {
            searchOptionsTableView.isHidden = false
            searchOptionsTableView.backgroundColor = UIColor(red: 217/255, green: 217/255, blue: 217/255, alpha: 0.1)
        }
    }
    
    @objc func updateTime() {
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "h:mm a"
        let currentTime = dateFormatter.string(from: Date())
        timeLabel.text = currentTime
    }
    
    func locationManager(_ manager: CLLocationManager, didFailWithError error: Error) {
        print("Location manager failed with error: \(error.localizedDescription)")
    }
    
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        if let location = locations.last{
            updateWeather(location: convertToLocation(location: location))
        }
        
    }
    
    func setupConstraints() {
        NSLayoutConstraint.activate([
            subView.leadingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.leadingAnchor),
            subView.trailingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.trailingAnchor),
        ])
        // searchBarContainer constraints
        NSLayoutConstraint.activate([
            searchBarContainer.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: 10),
            searchBarContainer.leadingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.leadingAnchor, constant: 10),
            searchBarContainer.trailingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.trailingAnchor, constant: -10),
            searchBarContainer.heightAnchor.constraint(equalToConstant: 75)
        ])
        
        // searchText constaints
        NSLayoutConstraint.activate([
            searchTextField.centerYAnchor.constraint(equalTo: searchBarContainer.centerYAnchor),
            searchTextField.leadingAnchor.constraint(equalTo: searchBarContainer.leadingAnchor, constant: 20),
            searchTextField.trailingAnchor.constraint(equalTo: searchIcon.leadingAnchor, constant: -20),
        ])
        
        // searchIcon constraints
        NSLayoutConstraint.activate([
            searchIcon.widthAnchor.constraint(equalToConstant:30),
            searchIcon.heightAnchor.constraint(equalToConstant:30),
            searchIcon.centerYAnchor.constraint(equalTo: searchBarContainer.centerYAnchor),
            searchIcon.trailingAnchor.constraint(equalTo: searchBarContainer.trailingAnchor, constant: -10)])
        
        // searchOptionsTableView constraints
        NSLayoutConstraint.activate([
            searchOptionsTableView.topAnchor.constraint(equalTo: searchBarContainer.bottomAnchor),
            searchOptionsTableView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            searchOptionsTableView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            searchOptionsTableView.bottomAnchor.constraint(equalTo: view.bottomAnchor),
        ])
        // locationName constraints
        NSLayoutConstraint.activate([
            locationLabel.centerXAnchor.constraint(equalTo: searchBarContainer.centerXAnchor),
            locationLabel.topAnchor.constraint(equalTo:searchBarContainer.bottomAnchor, constant: 10)])
        
        // temperatureLabel constraints
        NSLayoutConstraint.activate([
            temperatureLabel.centerXAnchor.constraint(equalTo: view.safeAreaLayoutGuide.centerXAnchor),
            temperatureLabel.topAnchor.constraint(equalTo: locationLabel.bottomAnchor, constant: 10)])
        
        // highLowText constraints
        NSLayoutConstraint.activate([
            highLowLabel.centerXAnchor.constraint(equalTo: view.safeAreaLayoutGuide.centerXAnchor),
            highLowLabel.topAnchor.constraint(equalTo: temperatureLabel.bottomAnchor, constant: 10),
            
        ])
        
        // timeText constraints
        NSLayoutConstraint.activate([
            timeLabel.centerXAnchor.constraint(equalTo: view.safeAreaLayoutGuide.centerXAnchor),
            timeLabel.topAnchor.constraint(equalTo: highLowLabel.bottomAnchor, constant: 10)])
        
        // descriptionLabel constraints
            NSLayoutConstraint.activate([
                descriptionLabel.centerXAnchor.constraint(equalTo: view.safeAreaLayoutGuide.centerXAnchor),
                descriptionLabel.topAnchor.constraint(equalTo:timeLabel.bottomAnchor, constant: 10)
            ])
        
        // weatherEmoji constraints
            NSLayoutConstraint.activate([
                weatherIcon.centerXAnchor.constraint(equalTo: view.safeAreaLayoutGuide.centerXAnchor),
                weatherIcon.topAnchor.constraint(equalTo:descriptionLabel.bottomAnchor, constant: -10),
                weatherIcon.widthAnchor.constraint(equalToConstant: 100),
                weatherIcon.heightAnchor.constraint(equalToConstant: 100),
            ])
        
    }
    func handleSelection(){
        searchTextField.text = ""
        searchOptionsTableView.isHidden = true
    }
    
    
    func updateWeather(location:Location ) {
        getWeather(lat: location.lat, lon: location.lon) { weather in
            DispatchQueue.main.async {
                
                if let weather = weather{
                    self.weather = weather
                    self.locationLabel.text = weather.locationName
                    self.temperatureLabel.text = String(format: "%.0f", self.toFahrenheit(degrees: weather.temperature!)) + "°F"
                    self.descriptionLabel.text = weather.description
                    if let low = weather.low, let high = weather.high {
                        self.highLowLabel.text = "Low: \(String(format: "%.0f", self.toFahrenheit(degrees: low))) °F | High: \(String(format: "%.0f", self.toFahrenheit(degrees: high))) °F"
                    }
                    
                    if let iconSrc = weather.iconSrc{
                        self.getData(from: iconSrc){data, response, error in
                            DispatchQueue.main.async {
                                if let data = data, error == nil{
                                    self.weatherIcon.image = UIImage(data: data)
                                }
                            }
                        }
                    }
                }
            }
            
        }
    }
    
    
    
    
    
    
    
    
    
    
    
    
    
}
    
    
    
    
    extension ViewController: UITableViewDelegate{
        func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
            return UITableView.automaticDimension
        }
        
        func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
            updateWeather(location: locations[indexPath.row])
            handleSelection()
            
        }
    }

extension ViewController: UITableViewDataSource{
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        // line added to prevent index out of range error due to asynchronous work
        if locations.count > indexPath.row{
            if let cell = tableView.dequeueReusableCell(withIdentifier: reuseIdentifier,
                                                        for: indexPath) as? searchOptionsTableViewCell{
                cell.configure(location:locations[indexPath.row])
                return cell
            }
        }
        return searchOptionsTableViewCell();
    }
        
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return locations.count
    }
}

extension ViewController: UITextFieldDelegate{
    func textFieldDidChangeSelection(_ textField: UITextField) {
        if searchTextField.text == ""{
            searchOptionsTableView.isHidden = true;
            searchOptionsTableView.backgroundColor = .none
        }else{
            getLocations(text: textField.text!){ locations in
                if let newLocations = locations{
                    self.locations = newLocations.filter{location in
                       let validResults = ["city", "state", "suburb", "county"]
                        return validResults.contains(location.result_type)
                    }
                }
            }
                
            searchOptionsTableView.isHidden = false;
            searchOptionsTableView.backgroundColor = UIColor(red: 217/255, green: 217/255, blue: 217/255, alpha: 0.1)
            searchOptionsTableView.reloadData()
            }
        }
        func textFieldShouldReturn(_ textField: UITextField) -> Bool {
            textField.resignFirstResponder() // Dismiss the keyboard
            handleSelection()
            return true
        }
    }

