import Foundation

public struct RouteEdge: Codable, Hashable, Sendable {
    public let from: String
    public let to: String
    public let distanceKm: Double?

    public init(from: String, to: String, distanceKm: Double?) {
        self.from = from
        self.to = to
        self.distanceKm = distanceKm
    }
}

public struct PlaceDataset: Codable, Sendable {
    public let places: [Place]
    public let routes: [RouteEdge]

    public init(places: [Place], routes: [RouteEdge]) {
        self.places = places
        self.routes = routes
    }
}
