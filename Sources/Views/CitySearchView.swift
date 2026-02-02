import SwiftUI
import MapKit

/// UI for searching and selecting a city.
struct CitySearchView: View {
    @EnvironmentObject var appState: AppState
    @Environment(\.dismiss) private var dismiss
    @State private var query: String = ""
    @State private var isSearching = false

    let onSelect: (LocationSelection) -> Void

    var body: some View {
        VStack(alignment: .leading, spacing: 24) {
            Text("Search City")
                .font(.title2)
                .bold()

            VStack(alignment: .leading, spacing: 8) {
                HStack {
                    TextField("City or country", text: $query)
                        .submitLabel(.search)
                        .onSubmit {
                            Task { await performSearch() }
                        }

                    if isSearching {
                        ProgressView()
                            .padding(.leading, 10)
                    }
                }
                .padding(12)
                .background(Color.white.opacity(0.08), in: RoundedRectangle(cornerRadius: 14, style: .continuous))
            }

            let results: [CitySearchResult] = appState.citySearchService.results
            ScrollView {
                LazyVStack(spacing: 16) {
                    ForEach(results) { result in
                        Button {
                            select(result: result)
                        } label: {
                            HStack {
                                VStack(alignment: .leading, spacing: 4) {
                                    Text(result.title)
                                        .font(.headline)
                                        .foregroundStyle(.primary)
                                    if !result.subtitle.isEmpty {
                                        Text(result.subtitle)
                                            .font(.subheadline)
                                            .foregroundStyle(.secondary)
                                    }
                                }
                                Spacer()
                            }
                            .padding()
                        }
                        .buttonStyle(.bordered)
                    }
                }
                .padding(.horizontal, 20)
                .padding(.bottom, 20)
            }
        }
        .padding(40)
        .background(Color.black.ignoresSafeArea())
    }

    private func select(result: CitySearchResult) {
        let name = [result.title, result.subtitle].filter { !$0.isEmpty }.joined(separator: ", ")
        let selection = LocationSelection(
            name: name,
            latitude: result.coordinate.latitude,
            longitude: result.coordinate.longitude,
            isCurrentLocation: false,
            timeZoneIdentifier: nil
        )
        onSelect(selection)
        // Dismiss the current view so selection returns to the previous screen.
        // This handles both NavigationLink pop and fullScreenCover dismissal used in onboarding.
        dismiss()
    }

    /// Runs the async search and updates loading state.
    private func performSearch() async {
        guard !query.isEmpty else { return }
        isSearching = true
        await appState.citySearchService.search(query: query)
        isSearching = false
    }
}

#Preview {
    CitySearchView(onSelect: { _ in })
        .environmentObject(AppState())
}
