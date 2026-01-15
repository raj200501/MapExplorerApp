import Foundation
import MapExplorerCore

struct CommandLineError: Error, CustomStringConvertible {
    let description: String
}

struct CommandLineOptions {
    let command: String
    let arguments: [String]
}

enum CLICommand: String {
    case search
    case route
    case show
    case validate
    case help
}

struct CLI {
    private let outputFormatter = OutputFormatter()

    func run() throws {
        let options = parseCommandLine()
        let command = CLICommand(rawValue: options.command) ?? .help
        switch command {
        case .search:
            try runSearch(arguments: options.arguments)
        case .route:
            try runRoute(arguments: options.arguments)
        case .show:
            try runShow(arguments: options.arguments)
        case .validate:
            try runValidate(arguments: options.arguments)
        case .help:
            print(helpText())
        }
    }

    private func runSearch(arguments: [String]) throws {
        let parser = ArgumentParser(arguments: arguments)
        let query = try parser.requireValue(for: "query")
        let limit = parser.value(for: "limit").flatMap(Int.init) ?? 10
        let format = OutputFormat(rawValue: parser.value(for: "format") ?? "table") ?? .table
        let dataURL = parser.value(for: "data").map { URL(fileURLWithPath: $0) }

        let service = try MapExplorerService.load(from: dataURL)
        let results = service.searchPlaces(query: query, limit: limit)
        let output = try outputFormatter.formatSearchResults(results, format: format)
        print(output)
    }

    private func runRoute(arguments: [String]) throws {
        let parser = ArgumentParser(arguments: arguments)
        let origin = try parser.requireValue(for: "from")
        let destination = try parser.requireValue(for: "to")
        let format = OutputFormat(rawValue: parser.value(for: "format") ?? "table") ?? .table
        let dataURL = parser.value(for: "data").map { URL(fileURLWithPath: $0) }

        let service = try MapExplorerService.load(from: dataURL)
        let route = try service.route(from: origin, to: destination)
        let output = try outputFormatter.formatRoute(route, format: format)
        print(output)
    }

    private func runShow(arguments: [String]) throws {
        let parser = ArgumentParser(arguments: arguments)
        let name = try parser.requireValue(for: "name")
        let format = OutputFormat(rawValue: parser.value(for: "format") ?? "table") ?? .table
        let dataURL = parser.value(for: "data").map { URL(fileURLWithPath: $0) }

        let service = try MapExplorerService.load(from: dataURL)
        let place = try service.place(named: name)
        let output = try outputFormatter.formatPlace(place, format: format)
        print(output)
    }

    private func runValidate(arguments: [String]) throws {
        let parser = ArgumentParser(arguments: arguments)
        let dataPath = parser.value(for: "data")
        let dataURL = dataPath.map { URL(fileURLWithPath: $0) }
        _ = try MapExplorerService.load(from: dataURL)
        print("Dataset validated successfully.")
    }

    private func parseCommandLine() -> CommandLineOptions {
        var args = CommandLine.arguments.dropFirst()
        let command = args.first ?? "help"
        if !args.isEmpty {
            args = args.dropFirst()
        }
        return CommandLineOptions(command: command, arguments: Array(args))
    }

    private func helpText() -> String {
        return """
        Map Explorer CLI

        Usage:
          map-explorer search --query <text> [--limit <n>] [--format table|json] [--data <path>]
          map-explorer route --from <place> --to <place> [--format table|json] [--data <path>]
          map-explorer show --name <place> [--format table|json] [--data <path>]
          map-explorer validate [--data <path>]

        Examples:
          map-explorer search --query park --limit 5
          map-explorer route --from "Central Park" --to "Old Town Station"
          map-explorer show --name "Civic Center"
        """
    }
}

final class ArgumentParser {
    private let arguments: [String]

    init(arguments: [String]) {
        self.arguments = arguments
    }

    func value(for key: String) -> String? {
        guard let index = arguments.firstIndex(of: "--\(key)") else {
            return nil
        }
        let valueIndex = arguments.index(after: index)
        guard valueIndex < arguments.endIndex else {
            return nil
        }
        return arguments[valueIndex]
    }

    func requireValue(for key: String) throws -> String {
        guard let value = value(for: key) else {
            throw CommandLineError(description: "Missing required argument --\(key).")
        }
        return value
    }
}

let cli = CLI()

do {
    try cli.run()
} catch {
    FileHandle.standardError.write(Data("Error: \(error.localizedDescription)\n".utf8))
    exit(1)
}
