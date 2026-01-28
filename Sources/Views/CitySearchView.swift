import SwiftUI

/// UI for searching and selecting a city.
struct CitySearchView: View {
    @EnvironmentObject var appState: AppState
    @State private var query: String = ""
    @State private var isSearching = false

    let onSelect: (LocationSelection) -> Void

    var body: some View {
        VStack(alignment: .leading, spacing: 16) {
            Text("Search City")
                .font(.title2)
                .bold()

            TextField("City or country", text: $query)
                .onSubmit {
                    Task { await performSearch() }
                }

            if isSearching {
                ProgressView()
            }

            List(appState.citySearchService.results, id: \.id) { result in
                Button {
                    let name = [result.title, result.subtitle].filter { !$0.isEmpty }.joined(separator: ", ")
                    let selection = LocationSelection(
                        name: name,
                        latitude: result.coordinate.latitude,
                        longitude: result.coordinate.longitude,
                        isCurrentLocation: false
                    )
                    onSelect(selection)
                } label: {
                    VStack(alignment: .leading) {
                        Text(result.title)
                        if !result.subtitle.isEmpty {
                            Text(result.subtitle)
                        }
                    }
                }
            }
        }
        .padding(32)
    }

    /// Runs the async search and updates loading state.
    private func performSearch() async {
        isSearching = true
        await appState.citySearchService.search(query: query)
        isSearching = false
    }
}

#Preview {
    CitySearchView(onSelect: { _ in })
        .environmentObject(AppState())
}
