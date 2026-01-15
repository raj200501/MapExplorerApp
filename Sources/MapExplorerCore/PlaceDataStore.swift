import Foundation

public final class PlaceDataStore: Sendable {
    public static let shared = PlaceDataStore()

    private let decoder: JSONDecoder

    public init(decoder: JSONDecoder = JSONDecoder()) {
        self.decoder = decoder
    }

    public func loadDefaultDataset() throws -> PlaceDataset {
        guard let url = Bundle.module.url(forResource: "places", withExtension: "json") else {
            throw MapExplorerError.dataNotFound("Default places.json was not bundled with the package.")
        }
        return try loadDataset(from: url)
    }

    public func loadDataset(from url: URL) throws -> PlaceDataset {
        let data = try Data(contentsOf: url)
        let dataset = try decoder.decode(PlaceDataset.self, from: data)
        try validate(dataset: dataset)
        return dataset
    }

    public func validate(dataset: PlaceDataset) throws {
        let placeIds = Set(dataset.places.map { $0.id })
        if placeIds.count != dataset.places.count {
            throw MapExplorerError.invalidData("Duplicate place identifiers found.")
        }

        if dataset.places.isEmpty {
            throw MapExplorerError.invalidData("Dataset must include at least one place.")
        }

        for route in dataset.routes {
            guard placeIds.contains(route.from) else {
                throw MapExplorerError.invalidData("Route references unknown origin id: \(route.from)")
            }
            guard placeIds.contains(route.to) else {
                throw MapExplorerError.invalidData("Route references unknown destination id: \(route.to)")
            }
        }
    }
}
