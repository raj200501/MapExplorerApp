import Foundation

public struct Place: Codable, Hashable, Sendable, Identifiable {
    public let id: String
    public let name: String
    public let category: String
    public let description: String
    public let coordinate: Coordinate
    public let tags: [String]

    public init(
        id: String,
        name: String,
        category: String,
        description: String,
        coordinate: Coordinate,
        tags: [String]
    ) {
        self.id = id
        self.name = name
        self.category = category
        self.description = description
        self.coordinate = coordinate
        self.tags = tags
    }
}

public struct PlaceSummary: Hashable, Sendable {
    public let place: Place
    public let score: Double
}
