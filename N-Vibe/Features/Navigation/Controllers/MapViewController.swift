//
//  ViewController.swift
//  N-Vibe
//
//  Created by Issam Abo Alshamlat on 12/9/24.
//

import UIKit
import MapboxMaps
import SnapKit
import MapboxDirections
import Combine

class MapViewController: UIViewController {
    private var mapView: MapView!
    private let mapService = MapService.self
    private let routeManager = RouteManager()
    private var searchView: SearchView!
    private let locationService = LocationService()
    private var isNightMode = false
    private var cancellables = Set<AnyCancellable>()
    
    private let navigationButton = FloatingButton(type: .navigation)
    private let currentLocationButton = FloatingButton(type: .currentLocation)
    private let toggleStyleButton = ToggleStyleButton()
    private let routeInfoView = RouteInfoView()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        navigationController?.setNavigationBarHidden(true, animated: true)
        
        setupMapView()
        setupSearchView()
        setupLocationService()
        setupNavigationButton()
        setupCurrentLocationButton()
        setupToggleStyleButton()
        subscribeToRouteManager()
        setupRouteInfoView()
    }
}

// MARK: - UI Setup
private extension MapViewController {
    private func setupMapView() {
        mapView = mapService.createMapView(frame: .zero)
        view.addSubview(mapView)
        
        mapView.snp.makeConstraints { make in
            make.edges.equalToSuperview()
        }
    }
    
    private func setupNavigationButton() {
        navigationButton.addTarget(self, action: #selector(startNavigation), for: .touchUpInside)
        
        view.addSubview(navigationButton)
        navigationButton.snp.makeConstraints { make in
            make.bottom.equalTo(view.safeAreaLayoutGuide.snp.bottom).offset(-20)
            make.trailing.equalTo(view.safeAreaLayoutGuide.snp.trailing).offset(-20)
            make.width.equalTo(0)
            make.height.equalTo(60)
        }
    }
    
    private func setupCurrentLocationButton() {
        currentLocationButton.addTarget(self, action: #selector(didTapCurrentLocationButton), for: .touchUpInside)
        
        view.addSubview(currentLocationButton)
        currentLocationButton.snp.makeConstraints { make in
            make.bottom.equalTo(view.safeAreaLayoutGuide.snp.bottom).offset(-20)
            make.trailing.equalTo(navigationButton.snp.leading).offset(-20)
            make.width.height.equalTo(60)
        }
    }
    
    private func setupSearchView() {
        searchView = SearchView()
        searchView.delegate = self
        view.addSubview(searchView)
        
        searchView.snp.makeConstraints { make in
            make.leading.trailing.equalToSuperview()
            make.top.equalTo(view.safeAreaLayoutGuide.snp.top)
            make.height.equalTo(150)
        }
    }
    
    private func setupLocationService() {
        locationService.delegate = self
        locationService.requestLocation()
    }
    
    private func setupToggleStyleButton() {
        toggleStyleButton.addTarget(self, action: #selector(toggleMapStyle), for: .touchUpInside)
        
        view.addSubview(toggleStyleButton)
        toggleStyleButton.snp.makeConstraints { make in
            make.leading.equalTo(view.safeAreaLayoutGuide.snp.leading).offset(20)
            make.centerY.equalTo(navigationButton)
            make.width.equalTo(120)
            make.height.equalTo(40)
        }
    }
    
    private func setupRouteInfoView() {
        view.addSubview(routeInfoView)
        routeInfoView.snp.makeConstraints { make in
            make.bottom.equalTo(view.safeAreaLayoutGuide.snp.bottom).offset(-90)
            make.leading.trailing.equalToSuperview().inset(16)
            make.height.equalTo(100)
        }
    }
}

// MARK: - Actions
extension MapViewController {
    @objc private func startNavigation() {
        routeManager.startNavigation(vc: self)
    }
    
    @objc private func toggleMapStyle() {
        isNightMode.toggle()
        
        let styleURL: StyleURI = isNightMode ? .dark : .streets
        let currentRoute = routeManager.route // Store the current route
        
        mapView.mapboxMap.loadStyleURI(styleURL) { [weak self] _ in
            guard let self = self, let currentRoute = currentRoute else { return }
            // Re-add the route to the map after the style has loaded
            self.mapService.addRouteLayer(to: self.mapView, route: currentRoute)
        }
        
        let buttonTitle = isNightMode ? String.dayMode : .nightMode
        toggleStyleButton.setTitle(buttonTitle, for: .normal)
    }
    
    @objc private func didTapCurrentLocationButton() {
        guard let currentLocation = locationService.currentLocation else {
            print("Current location not available")
            return
        }
        
        let userCoordinate = CLLocationCoordinate2D(
            latitude: currentLocation.coordinate.latitude,
            longitude: currentLocation.coordinate.longitude
        )
        
        // Animate camera to user's current location
        let cameraOptions = CameraOptions(center: userCoordinate, zoom: 14)
        mapView.camera.ease(to: cameraOptions, duration: 2.0)
        
        // Prompt the user to set as start coordinate
        let alertController = UIAlertController(
            title: "Set Start Location",
            message: "Would you like to set this location as the start coordinate?",
            preferredStyle: .alert
        )
        
        alertController.addAction(UIAlertAction(title: "Yes", style: .default) { _ in
            self.routeManager.setCoordinates(start: userCoordinate, end: nil, mapView: self.mapView)
            self.searchView.setUserLocation()
            print("Start coordinate set to: \(userCoordinate)")
        })
        
        alertController.addAction(UIAlertAction(title: "No", style: .cancel, handler: nil))
        
        present(alertController, animated: true, completion: nil)
    }
    
    private func subscribeToRouteManager() {
        routeManager.$route
            .receive(on: DispatchQueue.main)
            .sink { [weak self] route in
                guard let self = self, let route = route else { return }
                self.handleRoute(route: route)
            }
            .store(in: &cancellables)
    }
    
    private func handleRoute(route: Route) {
        mapService.addRouteLayer(to: mapView, route: route)
        mapService.adjustCamera(toFitRoute: route, on: mapView)

        updateRouteInfo(distance: route.distance, duration: route.expectedTravelTime)

        navigationButton.isHidden = false
        routeInfoView.isHidden = false
        navigationButton.snp.updateConstraints { make in
            make.width.equalTo(60)
        }
    }
    
    private func updateRouteInfo(distance: CLLocationDistance, duration: TimeInterval) {
        routeInfoView.updateDistance(distance)
        routeInfoView.updateDuration(duration)
    }
    
    private func formatTime(_ duration: TimeInterval) -> String {
        let hours = Int(duration) / 3600
        let minutes = (Int(duration) % 3600) / 60
        if hours > 0 {
            return "\(hours) hrs \(minutes) mins"
        } else {
            return "\(minutes) mins"
        }
    }
}

extension MapViewController: SearchViewDelegate {
    func didTapFindRoute(startAddress: String, destinationAddress: String) {
        routeManager.calculateRoute()
            .receive(on: DispatchQueue.main)
            .sink { [weak self] route in
                guard let self = self, let route = route else {
                    self?.showError(message: "Unable to calculate route. Please check the addresses and try again.")
                    return
                }
                self.routeManager.drawRoute(on: self.mapView, route: route)
                self.navigationButton.isHidden = false
                self.navigationButton.snp.updateConstraints { make in
                    make.width.equalTo(60)
                }
            }
            .store(in: &cancellables)
    }
    
    func didSelectStartCoordinate(coordinate: CLLocationCoordinate2D) {
        searchView.snp.updateConstraints { make in
            make.height.equalTo(150)
        }
        routeManager.setCoordinates(start: coordinate, end: nil, mapView: mapView)
    }
    
    func didSelectEndCoordinate(coordinate: CLLocationCoordinate2D) {
        searchView.snp.updateConstraints { make in
            make.height.equalTo(150)
        }
        routeManager.setCoordinates(start: nil, end: coordinate, mapView: mapView)
    }
    
    func didStartTyping() {
        navigationButton.isHidden = true
        navigationButton.snp.updateConstraints { make in
            make.width.equalTo(0)
        }
        
        searchView.snp.updateConstraints { make in
            make.height.equalTo(400)
        }
    }
}

extension MapViewController: LocationManagerDelegate {
    func didUpdateLocation(_ location: CLLocation) {
        let userCoordinate = CLLocationCoordinate2D(latitude: location.coordinate.latitude, longitude: location.coordinate.longitude)
        let cameraOptions = CameraOptions(center: userCoordinate, zoom: 14)
        mapView.mapboxMap.setCamera(to: cameraOptions)
    }
    
    func didFailWithError(_ error: Error) {
        print("Failed to get user location: \(error.localizedDescription)")
    }
}
