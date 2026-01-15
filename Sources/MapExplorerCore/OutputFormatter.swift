import Foundation

public enum OutputFormat: String, Sendable {
    case table
    case json
}

public struct OutputFormatter {
    public init() {}

    public func formatSearchResults(_ results: [PlaceSummary], format: OutputFormat) throws -> String {
        switch format {
        case .table:
            return formatTable(results: results)
        case .json:
            let payload = results.map { summary in
                [
                    "id": summary.place.id,
                    "name": summary.place.name,
                    "category": summary.place.category,
                    "description": summary.place.description,
                    "latitude": summary.place.coordinate.latitude,
                    "longitude": summary.place.coordinate.longitude,
                    "score": summary.score,
                    "tags": summary.place.tags
                ] as [String: Any]
            }
            return try formatJSON(payload)
        }
    }

    public func formatRoute(_ route: Route, format: OutputFormat) throws -> String {
        switch format {
        case .table:
            var lines: [String] = []
            lines.append("Route from \(route.origin.name) to \(route.destination.name)")
            lines.append(String(format: "Total distance: %.2f km", route.totalDistanceKm))
            lines.append("Steps:")
            for (index, step) in route.steps.enumerated() {
                let line = String(format: "%d. %@ -> %@ (%.2f km)",
                                  index + 1,
                                  step.from.name,
                                  step.to.name,
                                  step.distanceKm)
                lines.append(line)
            }
            return lines.joined(separator: "\n")
        case .json:
            let payload: [String: Any] = [
                "origin": route.origin.name,
                "destination": route.destination.name,
                "totalDistanceKm": route.totalDistanceKm,
                "steps": route.steps.map { step in
                    [
                        "from": step.from.name,
                        "to": step.to.name,
                        "distanceKm": step.distanceKm
                    ]
                }
            ]
            return try formatJSON(payload)
        }
    }

    public func formatPlace(_ place: Place, format: OutputFormat) throws -> String {
        switch format {
        case .table:
            return [
                "Name: \(place.name)",
                "Category: \(place.category)",
                "Description: \(place.description)",
                "Coordinate: \(place.coordinate.formatted())",
                "Tags: \(place.tags.joined(separator: ", "))"
            ].joined(separator: "\n")
        case .json:
            let payload: [String: Any] = [
                "id": place.id,
                "name": place.name,
                "category": place.category,
                "description": place.description,
                "latitude": place.coordinate.latitude,
                "longitude": place.coordinate.longitude,
                "tags": place.tags
            ]
            return try formatJSON(payload)
        }
    }

    private func formatTable(results: [PlaceSummary]) -> String {
        var lines: [String] = []
        lines.append("Found \(results.count) places")
        for (index, summary) in results.enumerated() {
            let place = summary.place
            let line = String(format: "%d. %@ (%@) - %@", index + 1, place.name, place.category, place.coordinate.formatted())
            lines.append(line)
        }
        return lines.joined(separator: "\n")
    }

    private func formatJSON(_ payload: Any) throws -> String {
        let data = try JSONSerialization.data(withJSONObject: payload, options: [.prettyPrinted, .sortedKeys])
        guard let string = String(data: data, encoding: .utf8) else {
            throw MapExplorerError.invalidData("Failed to serialize JSON output.")
        }
        return string
    }
}
