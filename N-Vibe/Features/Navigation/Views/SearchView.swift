//
//  SearchView.swift
//  N-Vibe
//
//  Created by Issam Abo Alshamlat on 12/10/24.
//

import UIKit
import SnapKit
import MapboxGeocoder

protocol SearchViewDelegate: AnyObject {
    func didTapFindRoute(startAddress: String, destinationAddress: String)
    func didSelectStartCoordinate(coordinate: CLLocationCoordinate2D)
    func didSelectEndCoordinate(coordinate: CLLocationCoordinate2D)
    func didStartTyping()
}

class SearchView: UIView {
    private let startTextField: UITextField = {
        let textField = UITextField()
        textField.set(placeholder: .startingAddress, color: .darkGray)
        textField.borderStyle = .roundedRect
        textField.backgroundColor = .white
        textField.textColor = .black
        
        // Add left icon
        let iconView = UIImageView(image: UIImage(systemName: "mappin.and.ellipse"))
        iconView.tintColor = .darkGray
        iconView.contentMode = .scaleAspectFit
        iconView.frame = CGRect(x: 0, y: 0, width: 24, height: 24)
        
        let leftView = UIView(frame: CGRect(x: 0, y: 0, width: 36, height: 24))
        leftView.addSubview(iconView)
        iconView.center = leftView.center
        
        textField.leftView = leftView
        textField.leftViewMode = .always
        
        return textField
    }()
    
    private let destinationTextField: UITextField = {
        let textField = UITextField()
        textField.set(placeholder: .destinationAddress, color: .darkGray)
        textField.borderStyle = .roundedRect
        textField.backgroundColor = .white
        textField.textColor = .black
        
        // Add left icon
        let iconView = UIImageView(image: UIImage(systemName: "flag"))
        iconView.tintColor = .darkGray
        iconView.contentMode = .scaleAspectFit
        iconView.frame = CGRect(x: 0, y: 0, width: 24, height: 24)
        
        let leftView = UIView(frame: CGRect(x: 0, y: 0, width: 36, height: 24))
        leftView.addSubview(iconView)
        iconView.center = leftView.center
        
        textField.leftView = leftView
        textField.leftViewMode = .always
        
        return textField
    }()
    
    private let findRouteButton: UIButton = {
        let button = UIButton(type: .system)
        button.setTitle(.findRoute, for: .normal)
        button.backgroundColor = .systemBlue
        button.setTitleColor(.white, for: .normal)
        button.layer.cornerRadius = 8
        return button
    }()
    
    private let tableView = UITableView()
    private var searchResults: [GeocodedPlacemark] = []
    private let geocoder = Geocoder(accessToken: Constants.accessToken)
    weak var delegate: SearchViewDelegate?

    override init(frame: CGRect) {
        super.init(frame: frame)
        setupUI()
        findRouteButton.addTarget(self, action: #selector(findRouteTapped), for: .touchUpInside)
        startTextField.delegate = self
        destinationTextField.delegate = self
    }
    
    required init?(coder: NSCoder) {
        super.init(coder: coder)
        setupUI()
    }
    
    private func setupUI() {
        addSubview(startTextField)
        addSubview(destinationTextField)
        addSubview(findRouteButton)
        addSubview(tableView)

        startTextField.snp.makeConstraints { make in
            make.top.equalToSuperview()
            make.leading.trailing.equalToSuperview().inset(16)
            make.height.equalTo(44)
        }

        destinationTextField.snp.makeConstraints { make in
            make.top.equalTo(startTextField.snp.bottom).offset(8)
            make.leading.trailing.equalToSuperview().inset(16)
            make.height.equalTo(44)
        }

        findRouteButton.snp.makeConstraints { make in
            make.top.equalTo(destinationTextField.snp.bottom).offset(16)
            make.centerX.equalToSuperview()
            make.width.equalTo(120)
            make.height.equalTo(44)
        }

        tableView.snp.makeConstraints { make in
            make.top.equalTo(findRouteButton.snp.bottom).offset(8)
            make.leading.trailing.equalToSuperview()
            make.height.equalTo(0)
        }

        tableView.backgroundColor = .white
        tableView.isHidden = true
        tableView.delegate = self
        tableView.dataSource = self
    }
    
    @objc private func findRouteTapped() {
        let startAddress = startTextField.text ?? ""
        let destinationAddress = destinationTextField.text ?? ""
        delegate?.didTapFindRoute(startAddress: startAddress, destinationAddress: destinationAddress)
    }
    
    func setUserLocation() {
        startTextField.text = .currentLocation
    }
    
    private func fetchSuggestions(for query: String) {
        guard !query.isEmpty else {
            searchResults = []
            tableView.isHidden = true
            return
        }

        geocoder.geocode(ForwardGeocodeOptions(query: query)) { [weak self] (placemarks, queryString, error) in
            guard let self = self else { return }
            
            if let error = error {
                print("Geocoding error: \(error)")
                self.searchResults = []
                self.tableView.isHidden = true
                return
            }
            
            if let placemarks = placemarks {
                self.searchResults = placemarks
                self.tableView.reloadData()
                self.tableView.isHidden = self.searchResults.isEmpty
                self.tableView.snp.updateConstraints { make in
                    make.height.equalTo(250)
                }
            } else {
                self.searchResults = []
                self.tableView.isHidden = true
            }
        }
    }
}

// MARK: - UITextFieldDelegate
extension SearchView: UITextFieldDelegate {
    func textField(_ textField: UITextField, shouldChangeCharactersIn range: NSRange, replacementString string: String) -> Bool {
        let query = (textField.text as NSString?)?.replacingCharacters(in: range, with: string) ?? ""
        if query.count > 3 {
            delegate?.didStartTyping()
            fetchSuggestions(for: query)
        }
        
        return true
    }
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        // Dismiss the keyboard
        textField.resignFirstResponder()
        return true
    }
}

// MARK: - UITableViewDelegate
extension SearchView: UITableViewDelegate {
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let selectedPlace = searchResults[indexPath.row]
        guard let coordinate = selectedPlace.location?.coordinate else { return }

        if startTextField.isFirstResponder {
            startTextField.text = selectedPlace.name
            delegate?.didSelectStartCoordinate(coordinate: coordinate)
        } else if destinationTextField.isFirstResponder {
            destinationTextField.text = selectedPlace.name
            delegate?.didSelectEndCoordinate(coordinate: coordinate)
        }

        tableView.isHidden = true
        endEditing(true) // Dismiss keyboard
    }
}

// MARK: - UITableViewDataSource
extension SearchView: UITableViewDataSource {
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return searchResults.count
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = UITableViewCell()
        cell.backgroundColor = .white
        cell.textLabel?.textColor = .darkGray
        cell.textLabel?.text = searchResults[indexPath.row].qualifiedName
        return cell
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 50
    }
}
