import Foundation

public struct RouteStep: Hashable, Sendable {
    public let from: Place
    public let to: Place
    public let distanceKm: Double

    public init(from: Place, to: Place, distanceKm: Double) {
        self.from = from
        self.to = to
        self.distanceKm = distanceKm
    }
}

public struct Route: Hashable, Sendable {
    public let origin: Place
    public let destination: Place
    public let steps: [RouteStep]
    public let totalDistanceKm: Double

    public init(origin: Place, destination: Place, steps: [RouteStep]) {
        self.origin = origin
        self.destination = destination
        self.steps = steps
        self.totalDistanceKm = steps.reduce(0) { $0 + $1.distanceKm }
    }
}
