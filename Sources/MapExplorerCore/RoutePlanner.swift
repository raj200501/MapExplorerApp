import Foundation

public final class RoutePlanner: Sendable {
    private struct Edge {
        let to: String
        let distanceKm: Double
    }

    private let placeById: [String: Place]
    private let adjacency: [String: [Edge]]

    public init(dataset: PlaceDataset) {
        self.placeById = Dictionary(uniqueKeysWithValues: dataset.places.map { ($0.id, $0) })
        var adjacency: [String: [Edge]] = [:]
        for route in dataset.routes {
            let fromPlace = placeById[route.from]
            let toPlace = placeById[route.to]
            let distance = route.distanceKm
                ?? fromPlace?.coordinate.distanceKilometers(to: toPlace?.coordinate ?? Coordinate(latitude: 0, longitude: 0))
                ?? 0
            let edge = Edge(to: route.to, distanceKm: distance)
            adjacency[route.from, default: []].append(edge)
        }
        self.adjacency = adjacency
    }

    public func shortestRoute(from origin: Place, to destination: Place) throws -> Route {
        let originId = origin.id
        let destinationId = destination.id

        var distances: [String: Double] = [originId: 0]
        var previous: [String: String] = [:]
        var visited: Set<String> = []

        while visited.count < placeById.count {
            guard let current = distances
                .filter({ !visited.contains($0.key) })
                .min(by: { $0.value < $1.value })?.key else {
                break
            }

            if current == destinationId {
                break
            }

            visited.insert(current)
            let edges = adjacency[current, default: []]
            for edge in edges {
                let newDistance = (distances[current] ?? 0) + edge.distanceKm
                if newDistance < (distances[edge.to] ?? .infinity) {
                    distances[edge.to] = newDistance
                    previous[edge.to] = current
                }
            }
        }

        guard let _ = distances[destinationId] else {
            throw MapExplorerError.routeNotFound(origin.name, destination.name)
        }

        let pathIds = buildPath(destinationId: destinationId, previous: previous)
        let steps = buildSteps(pathIds: pathIds)
        return Route(origin: origin, destination: destination, steps: steps)
    }

    private func buildPath(destinationId: String, previous: [String: String]) -> [String] {
        var path: [String] = [destinationId]
        var current = destinationId
        while let prev = previous[current] {
            path.append(prev)
            current = prev
        }
        return path.reversed()
    }

    private func buildSteps(pathIds: [String]) -> [RouteStep] {
        guard pathIds.count >= 2 else { return [] }
        var steps: [RouteStep] = []
        for index in 0..<(pathIds.count - 1) {
            let fromId = pathIds[index]
            let toId = pathIds[index + 1]
            guard let fromPlace = placeById[fromId], let toPlace = placeById[toId] else {
                continue
            }
            let distance = fromPlace.coordinate.distanceKilometers(to: toPlace.coordinate)
            steps.append(RouteStep(from: fromPlace, to: toPlace, distanceKm: distance))
        }
        return steps
    }
}
