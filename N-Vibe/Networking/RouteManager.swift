//
//  RouteManager.swift
//  N-Vibe
//
//  Created by Issam Abo Alshamlat on 12/10/24.
//

import Foundation
import MapboxDirections
import CoreLocation
import MapboxMaps
import MapboxNavigation
import MapboxCoreNavigation
import Combine

class RouteManager {
    @Published private(set) var startCoordinates: CLLocationCoordinate2D?
    @Published private(set) var endCoordinates: CLLocationCoordinate2D?
    @Published private(set) var route: Route?
    
    private let directions = Directions.shared
    private var routeOptions: NavigationRouteOptions? = nil
    private var routeResponse: RouteResponse? = nil
    private var cancellables = Set<AnyCancellable>()
    
    
    func setCoordinates(start: CLLocationCoordinate2D?, end: CLLocationCoordinate2D?, mapView: MapView) {
        if let start = start {
            startCoordinates = start
        }
        if let end = end {
            endCoordinates = end
        }
        MapService().addPinsToMap(startCoordinates: startCoordinates, endCoordinates: endCoordinates, on: mapView)
    }
}

extension RouteManager {
    func calculateRoute() -> AnyPublisher<Route?, Never> {
        guard let startCoordinates = startCoordinates, let endCoordinates = endCoordinates else {
            return Just(nil).eraseToAnyPublisher()
        }
        
        SpinnerManager.shared.show()
        let origin = Waypoint(coordinate: startCoordinates, coordinateAccuracy: -1, name: "Start")
        let destination = Waypoint(coordinate: endCoordinates, coordinateAccuracy: -1, name: "Finish")
        
        let routeOptions = NavigationRouteOptions(waypoints: [origin, destination], profileIdentifier: .walking)
        routeOptions.includesAlternativeRoutes = true
        
        return Future { [weak self] promise in
            guard let self = self else { return }
            
            self.directions.calculate(routeOptions) { [weak self] (session, result) in
                SpinnerManager.shared.hide()
                guard let self = self else {return}
                switch result {
                case .failure(let error):
                    print("Error calculating route: \(error.localizedDescription)")
                    promise(.success(nil))
                case .success(let response):
                    if let route = response.routes?.first {
                        self.route = route
                        self.routeResponse = response
                        self.routeOptions = routeOptions
                        promise(.success(route))
                    } else {
                        promise(.success(nil))
                    }
                }
            }
        }
        .eraseToAnyPublisher()
    }
    
    func drawRoute(on mapView: MapView, route: Route) {
        MapService.addRouteLayer(to: mapView, route: route)
    }
    
    func startNavigation(vc: UIViewController) {
        guard let routeResponse = routeResponse, let routeOptions = routeOptions else {return}
        
        var navigationViewController = NavigationViewController(
            for: routeResponse,
            routeIndex: 0,
            routeOptions: routeOptions
        )
        
        vc.present(navigationViewController, animated: true) {
            // Ensure that navigation service stops when the controller is dismissed
            navigationViewController.navigationService?.stop()
        }
    }
}
