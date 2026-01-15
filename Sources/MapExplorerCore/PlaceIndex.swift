import Foundation

public final class PlaceIndex: Sendable {
    private let places: [Place]
    private let normalizedIndex: [String: [Place]]

    public init(places: [Place]) {
        self.places = places
        self.normalizedIndex = Dictionary(grouping: places) { place in
            place.name.lowercased()
        }
    }

    public func search(query: String, limit: Int = 10) -> [PlaceSummary] {
        let normalized = query.trimmingCharacters(in: .whitespacesAndNewlines).lowercased()
        guard !normalized.isEmpty else { return [] }

        var results: [PlaceSummary] = []
        for place in places {
            let score = scoreMatch(query: normalized, place: place)
            if score > 0 {
                results.append(PlaceSummary(place: place, score: score))
            }
        }

        return results
            .sorted { $0.score > $1.score }
            .prefix(max(limit, 1))
            .map { $0 }
    }

    public func place(named name: String) -> Place? {
        let normalized = name.trimmingCharacters(in: .whitespacesAndNewlines).lowercased()
        if let exact = normalizedIndex[normalized]?.first {
            return exact
        }
        return places.first { place in
            place.name.lowercased().contains(normalized)
        }
    }

    private func scoreMatch(query: String, place: Place) -> Double {
        let name = place.name.lowercased()
        let category = place.category.lowercased()
        let tags = place.tags.map { $0.lowercased() }

        var score = 0.0
        if name == query {
            score += 10
        }
        if name.contains(query) {
            score += 5
        }
        if category.contains(query) {
            score += 3
        }
        if tags.contains(where: { $0.contains(query) }) {
            score += 2
        }
        return score
    }
}
