import Foundation
import CoreLocation

class LocationService: NSObject, CLLocationManagerDelegate {

    static let shared = LocationService()
    private let locationManager = CLLocationManager()

    override private init() {
        super.init()
        locationManager.delegate = self
        locationManager.requestWhenInUseAuthorization()
    }

    func startUpdatingLocation() {
        locationManager.startUpdatingLocation()
    }

    func stopUpdatingLocation() {
        locationManager.stopUpdatingLocation()
    }

    func getCurrentLocation() -> CLLocationCoordinate2D? {
        return locationManager.location?.coordinate
    }
}
