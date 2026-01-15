import XCTest
@testable import MapExplorerCore

final class MapExplorerCoreTests: XCTestCase {
    func testDefaultDatasetLoads() throws {
        let dataset = try PlaceDataStore().loadDefaultDataset()
        XCTAssertEqual(dataset.places.count, 400)
        XCTAssertEqual(dataset.routes.count, 1520)
    }

    func testSearchFindsCentralPark() throws {
        let dataset = try PlaceDataStore().loadDefaultDataset()
        let index = PlaceIndex(places: dataset.places)
        let results = index.search(query: "Central Park", limit: 5)
        XCTAssertFalse(results.isEmpty)
        XCTAssertEqual(results.first?.place.name, "Central Park")
    }

    func testSearchByCategoryTag() throws {
        let dataset = try PlaceDataStore().loadDefaultDataset()
        let index = PlaceIndex(places: dataset.places)
        let results = index.search(query: "harbor", limit: 10)
        XCTAssertTrue(results.contains { $0.place.name == "North Harbor" })
    }

    func testPlaceLookupThrows() throws {
        let dataset = try PlaceDataStore().loadDefaultDataset()
        let service = MapExplorerService(dataset: dataset)
        XCTAssertThrowsError(try service.place(named: "Not A Place"))
    }

    func testRouteBetweenKnownPlaces() throws {
        let dataset = try PlaceDataStore().loadDefaultDataset()
        let service = MapExplorerService(dataset: dataset)
        let route = try service.route(from: "Central Park", to: "Old Town Station")
        XCTAssertFalse(route.steps.isEmpty)
        XCTAssertEqual(route.origin.name, "Central Park")
        XCTAssertEqual(route.destination.name, "Old Town Station")
        XCTAssertGreaterThan(route.totalDistanceKm, 0)
    }

    func testRouteNotFoundThrows() throws {
        var dataset = try PlaceDataStore().loadDefaultDataset()
        dataset = PlaceDataset(places: dataset.places, routes: [])
        let planner = RoutePlanner(dataset: dataset)
        let origin = dataset.places.first!
        let destination = dataset.places.last!
        XCTAssertThrowsError(try planner.shortestRoute(from: origin, to: destination))
    }

    func testFormatterOutputsJSON() throws {
        let dataset = try PlaceDataStore().loadDefaultDataset()
        let service = MapExplorerService(dataset: dataset)
        let place = try service.place(named: "Civic Center")
        let formatter = OutputFormatter()
        let jsonOutput = try formatter.formatPlace(place, format: .json)
        XCTAssertTrue(jsonOutput.contains("Civic Center"))
        XCTAssertTrue(jsonOutput.contains("latitude"))
    }

    func testFormatterOutputsTable() throws {
        let dataset = try PlaceDataStore().loadDefaultDataset()
        let service = MapExplorerService(dataset: dataset)
        let results = service.searchPlaces(query: "market", limit: 3)
        let formatter = OutputFormatter()
        let output = try formatter.formatSearchResults(results, format: .table)
        XCTAssertTrue(output.contains("Found"))
    }
}
