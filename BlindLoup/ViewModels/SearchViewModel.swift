import Foundation
import Observation

enum SearchState: Equatable {
    case idle
    case loading
    case loaded([Track])
    case error(String)

    static func == (lhs: SearchState, rhs: SearchState) -> Bool {
        switch (lhs, rhs) {
        case (.idle, .idle), (.loading, .loading): return true
        case (.loaded(let a), .loaded(let b)):     return a.map(\.id) == b.map(\.id)
        case (.error(let a), .error(let b)):       return a == b
        default: return false
        }
    }
}

@Observable
final class SearchViewModel {
    var searchText: String = "" {
        didSet { scheduleSearch() }
    }
    var state: SearchState = .idle

    private var debounceTask: Task<Void, Never>?
    private let service: DeezerService

    init(service: DeezerService = .shared) {
        self.service = service
    }

    private func scheduleSearch() {
        debounceTask?.cancel()
        let query = searchText
        guard !query.trimmingCharacters(in: .whitespaces).isEmpty else {
            state = .idle
            return
        }
        debounceTask = Task { [weak self] in
            do {
                try await Task.sleep(for: .milliseconds(500))
                guard !Task.isCancelled else { return }
                await self?.performSearch(query: query)
            } catch {
                // Task cancelled — no-op
            }
        }
    }

    @MainActor
    private func performSearch(query: String) async {
        state = .loading
        do {
            let tracks = try await service.searchTracks(query: query)
            guard searchText == query else { return }
            state = .loaded(tracks)
        } catch let error as DeezerError {
            guard searchText == query else { return }
            state = .error(error.localizedDescription)
        } catch {
            guard searchText == query else { return }
            state = .error("Erreur inconnue.")
        }
    }

    func clearSearch() {
        debounceTask?.cancel()
        searchText = ""
        // state is reset to .idle via searchText didSet → scheduleSearch()
    }
}
