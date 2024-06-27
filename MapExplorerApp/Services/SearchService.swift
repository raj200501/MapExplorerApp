import Foundation
import MapKit

class SearchService {

    static let shared = SearchService()

    private init() {}

    func searchForPlace(query: String, completion: @escaping (MKMapItem?) -> Void) {
        let searchRequest = MKLocalSearch.Request()
        searchRequest.naturalLanguageQuery = query
        let search = MKLocalSearch(request: searchRequest)
        search.start { response, error in
            guard let response = response else {
                completion(nil)
                return
            }
            completion(response.mapItems.first)
        }
    }
}
