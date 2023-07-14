//
//  searchOptionsTableViewCell.swift
//  weather-app
//
//  Created by Josh Magazine on 7/5/23.
//

import UIKit

class searchOptionsTableViewCell: UITableViewCell {
    let nameLabel = UILabel();
    let stateNameToCode: [String: String] = [
        "Alabama": "AL",
        "Alaska": "AK",
        "Arizona": "AZ",
        "Arkansas": "AR",
        "California": "CA",
        "Colorado": "CO",
        "Connecticut": "CT",
        "Delaware": "DE",
        "Florida": "FL",
        "Georgia": "GA",
        "Hawaii": "HI",
        "Idaho": "ID",
        "Illinois": "IL",
        "Indiana": "IN",
        "Iowa": "IA",
        "Kansas": "KS",
        "Kentucky": "KY",
        "Louisiana": "LA",
        "Maine": "ME",
        "Maryland": "MD",
        "Massachusetts": "MA",
        "Michigan": "MI",
        "Minnesota": "MN",
        "Mississippi": "MS",
        "Missouri": "MO",
        "Montana": "MT",
        "Nebraska": "NE",
        "Nevada": "NV",
        "New Hampshire": "NH",
        "New Jersey": "NJ",
        "New Mexico": "NM",
        "New York": "NY",
        "North Carolina": "NC",
        "North Dakota": "ND",
        "Ohio": "OH",
        "Oklahoma": "OK",
        "Oregon": "OR",
        "Pennsylvania": "PA",
        "Rhode Island": "RI",
        "South Carolina": "SC",
        "South Dakota": "SD",
        "Tennessee": "TN",
        "Texas": "TX",
        "Utah": "UT",
        "Vermont": "VT",
        "Virginia": "VA",
        "Washington": "WA",
        "West Virginia": "WV",
        "Wisconsin": "WI",
        "Wyoming": "WY"
    ]
    
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        nameLabel.translatesAutoresizingMaskIntoConstraints = false
        nameLabel.font = .italicSystemFont(ofSize: 20)
        nameLabel.textAlignment = .left
        nameLabel.textColor = .white
        contentView.backgroundColor = .black
        contentView.addSubview(nameLabel)
        
        setupConstraints()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    
    func setupConstraints(){
        NSLayoutConstraint.activate([
            nameLabel.centerYAnchor.constraint(equalTo: contentView.centerYAnchor),
            nameLabel.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 10),
            nameLabel.trailingAnchor.constraint(equalTo: contentView.trailingAnchor),            
        ])
        
        
    }
    
    func configure(location: Location){
        var text = ""
        if let suburb = location.suburb{
            text += suburb + ", "
        }
        if let city = location.city{
            text += city + ", "
        }
        
        if let county = location.county{
                text += county + ", "
            }
        
        if let state = location.state {
            text += (stateNameToCode[state] ?? "") + ", "
        }
        
        text += location.country
        
        nameLabel.text = text
    }
}

protocol TableViewDismissDelegate {
    func dismissViewController()
}

extension ViewController: TableViewDismissDelegate {
    func dismissViewController() {
        self.dismiss(animated: true, completion: nil)
    }
}
