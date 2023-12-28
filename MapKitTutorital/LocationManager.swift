//
//  LocationManager.swift
//  NearMe
//
//  Created by Mohammad Azam on 8/13/23.
//

import Foundation
import MapKit
import Observation


enum LocationError: LocalizedError {
    case authorizationDenied
    case authorizationRestricted
    case unknownLocation
    case accessDenied
    case network
    case operationFailed
    
    var errorDescription: String? {
        switch self {
            case .authorizationDenied:
                return NSLocalizedString("Location access denied.", comment: "")
            case .authorizationRestricted:
                return NSLocalizedString("Location access restricted.", comment: "")
            case .unknownLocation:
                return NSLocalizedString("Unknown location.", comment: "")
            case .accessDenied:
                return NSLocalizedString("Access denied.", comment: "")
            case .network:
                return NSLocalizedString("Network failed.", comment: "")
            case .operationFailed:
                return NSLocalizedString("Operation failed.", comment: "")
        }
    }
}

struct LocationEvent: Identifiable {
    
    let id = UUID()
    let identifier: String
}

@Observable
class LocationManager: NSObject, CLLocationManagerDelegate {
    
    let manager = CLLocationManager()
    static let shared = LocationManager()
    var error: LocationError? = nil
    
    var region: MKCoordinateRegion = MKCoordinateRegion()
    // only start monitoring when we have a region we want to monitor
    var monitor: CLMonitor?
    // Don't have it until we
    var locationEvent: LocationEvent?
    
    private override init() {
        super.init()
        manager.desiredAccuracy = kCLLocationAccuracyBest
        self.manager.delegate = self
    }
    
    func startMonitoringRegion() async {
        // THINGS YOU CAN DO
        /// "You've arrived at your destinatiion", "You are now leaving the Area"
        ///  "You're less than 50 ft from a  mystery.  Unlock Mystery
        ///   "Youre less than 100 ft from a deal.  See Deal.
        
        
        
        print("Region monitor beginning")
        monitor = await CLMonitor("RegionMonitor")
        // Add Events associated to certain regions to the monitor
        await monitor?.add(CLMonitor.CircularGeographicCondition.cupertinoVillage, identifier: "cupertinoVillage", assuming: .unsatisfied)
        await monitor?.add(CLMonitor.CircularGeographicCondition.appleCampus, identifier: "appleCampus", assuming: .unsatisfied)
        
        Task {
            for try await event in await monitor!.events {
                switch event.state {
                case .satisfied:
                    print("satisfied")
                    guard let lastEvent = await monitor!.record(for: event.identifier)?.lastEvent else { continue }
                    locationEvent = LocationEvent(identifier: lastEvent.identifier)
                case .unsatisfied:
                    print("unsatisfied")
                case .unknown:
                    print("unknown")
                @unknown default:
                    print("unknown default")
                }
            }
        }
    }
    
   
}



extension LocationManager {
    
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        locations.last.map {
            region = MKCoordinateRegion(center: CLLocationCoordinate2D(latitude: $0.coordinate.latitude, longitude: $0.coordinate.longitude),
                                                    span: MKCoordinateSpan(latitudeDelta: 0.05, longitudeDelta: 0.05))
        }
    }
    
    func locationManagerDidChangeAuthorization(_ manager: CLLocationManager) {
        switch manager.authorizationStatus {
            case .notDetermined:
                manager.requestWhenInUseAuthorization()
            case .authorizedAlways, .authorizedWhenInUse:
                manager.requestLocation()
            case .denied:
                error = .authorizationDenied
            case .restricted:
                error = .authorizationRestricted
            @unknown default:
                break
        }
    }
    
    func locationManager(_ manager: CLLocationManager, didFailWithError error: Error) {
        
        if let clError = error as? CLError {
            switch clError.code {
                case .locationUnknown:
                    self.error = .unknownLocation
                case .denied:
                    self.error = .accessDenied
                case .network:
                    self.error = .network
                default:
                    self.error = .operationFailed
            }
        }
        
    }
    
}
