import Foundation
import MapKit

struct CitySearchResult: Identifiable, Hashable {
    let id = UUID()
    let title: String
    let subtitle: String
    let coordinate: CLLocationCoordinate2D

    static func == (lhs: CitySearchResult, rhs: CitySearchResult) -> Bool {
        lhs.title == rhs.title &&
            lhs.subtitle == rhs.subtitle &&
            lhs.coordinate.latitude == rhs.coordinate.latitude &&
            lhs.coordinate.longitude == rhs.coordinate.longitude
    }

    func hash(into hasher: inout Hasher) {
        hasher.combine(title)
        hasher.combine(subtitle)
        hasher.combine(coordinate.latitude)
        hasher.combine(coordinate.longitude)
    }
}

@MainActor
final class CitySearchService: ObservableObject {
    @Published var results: [CitySearchResult] = []

    func search(query: String) async {
        guard !query.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty else {
            results = []
            return
        }

        let request = MKLocalSearch.Request()
        request.naturalLanguageQuery = query
        request.resultTypes = .address

        do {
            let response = try await MKLocalSearch(request: request).start()
            results = response.mapItems.compactMap { item in
                let coordinate = item.location.coordinate
                let title = item.name ?? "Unknown"
                let subtitle = item.addressRepresentations?.fullAddress(includingRegion: true, singleLine: true) ?? ""
                return CitySearchResult(title: title, subtitle: subtitle, coordinate: coordinate)
            }
        } catch {
            results = []
        }
    }
}
