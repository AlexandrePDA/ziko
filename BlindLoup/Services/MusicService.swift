import Foundation

// MARK: - Errors

enum MusicServiceError: LocalizedError {
    case emptyResults
    case networkUnavailable
    case parsingFailed
    case invalidURL

    var errorDescription: String? {
        switch self {
        case .emptyResults:       return "Aucun résultat trouvé."
        case .networkUnavailable: return "Connexion réseau indisponible."
        case .parsingFailed:      return "Impossible de lire la réponse du serveur."
        case .invalidURL:         return "URL invalide."
        }
    }
}

// MARK: - iTunes Search API DTOs

private struct iTunesSearchResponse: Codable {
    let results: [iTunesTrack]
}

private struct iTunesTrack: Codable {
    let trackId: Int
    let trackName: String
    let artistName: String
    let artworkUrl100: String?
    let previewUrl: String?
}

// MARK: - Service

final class MusicService {
    static let shared = MusicService()

    private let session: URLSession
    private let decoder = JSONDecoder()

    private init() {
        let config = URLSessionConfiguration.default
        config.timeoutIntervalForRequest = 10
        self.session = URLSession(configuration: config)
    }

    /// Recherche dans le catalogue iTunes (extraits 30s, aucun compte requis).
    func searchTracks(query: String) async throws -> [Track] {
        guard !query.isBlank else { throw MusicServiceError.emptyResults }
        guard let url = makeSearchURL(query: query.trimmed) else { throw MusicServiceError.invalidURL }

        let (data, response) = try await fetchData(from: url)

        guard (response as? HTTPURLResponse)?.statusCode == 200 else {
            throw MusicServiceError.networkUnavailable
        }

        let tracks = try decode(data).results.compactMap(mapTrack)
        guard !tracks.isEmpty else { throw MusicServiceError.emptyResults }
        return tracks
    }

    // MARK: - Private

    private func fetchData(from url: URL) async throws -> (Data, URLResponse) {
        do {
            return try await session.data(from: url)
        } catch {
            throw MusicServiceError.networkUnavailable
        }
    }

    private func decode(_ data: Data) throws -> iTunesSearchResponse {
        do {
            return try decoder.decode(iTunesSearchResponse.self, from: data)
        } catch {
            throw MusicServiceError.parsingFailed
        }
    }

    private func makeSearchURL(query: String) -> URL? {
        var components = URLComponents(string: "https://itunes.apple.com/search")
        components?.queryItems = [
            URLQueryItem(name: "term",   value: query),
            URLQueryItem(name: "media",  value: "music"),
            URLQueryItem(name: "entity", value: "song"),
            URLQueryItem(name: "limit",  value: "25"),
        ]
        return components?.url
    }

    private func mapTrack(_ t: iTunesTrack) -> Track? {
        guard let previewString = t.previewUrl, let previewURL = URL(string: previewString) else { return nil }
        let coverURL = t.artworkUrl100.flatMap {
            URL(string: $0.replacingOccurrences(of: "100x100", with: "300x300"))
        }
        return Track(
            id: String(t.trackId),
            title: t.trackName,
            artist: t.artistName,
            previewURL: previewURL,
            albumCoverURL: coverURL
        )
    }
}
