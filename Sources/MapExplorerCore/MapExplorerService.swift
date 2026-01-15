import Foundation

public final class MapExplorerService: Sendable {
    public let dataset: PlaceDataset
    public let index: PlaceIndex
    public let planner: RoutePlanner

    public init(dataset: PlaceDataset) {
        self.dataset = dataset
        self.index = PlaceIndex(places: dataset.places)
        self.planner = RoutePlanner(dataset: dataset)
    }

    public static func load(from url: URL?) throws -> MapExplorerService {
        let store = PlaceDataStore()
        let dataset: PlaceDataset
        if let url {
            dataset = try store.loadDataset(from: url)
        } else {
            dataset = try store.loadDefaultDataset()
        }
        return MapExplorerService(dataset: dataset)
    }

    public func searchPlaces(query: String, limit: Int) -> [PlaceSummary] {
        index.search(query: query, limit: limit)
    }

    public func place(named name: String) throws -> Place {
        if let place = index.place(named: name) {
            return place
        }
        throw MapExplorerError.placeNotFound(name)
    }

    public func route(from originName: String, to destinationName: String) throws -> Route {
        let origin = try place(named: originName)
        let destination = try place(named: destinationName)
        return try planner.shortestRoute(from: origin, to: destination)
    }
}
