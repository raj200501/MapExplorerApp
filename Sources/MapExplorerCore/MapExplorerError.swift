import Foundation

public enum MapExplorerError: Error, LocalizedError, Sendable {
    case dataNotFound(String)
    case invalidData(String)
    case placeNotFound(String)
    case routeNotFound(String, String)

    public var errorDescription: String? {
        switch self {
        case .dataNotFound(let message):
            return "Data not found: \(message)"
        case .invalidData(let message):
            return "Invalid data: \(message)"
        case .placeNotFound(let name):
            return "No place named '\(name)' was found in the dataset."
        case .routeNotFound(let origin, let destination):
            return "No route from '\(origin)' to '\(destination)' was found."
        }
    }
}
