import Foundation

enum DeezerError: LocalizedError {
    case networkUnavailable
    case parsingFailed
    case emptyResults
    case invalidURL

    var errorDescription: String? {
        switch self {
        case .networkUnavailable: return "Connexion réseau indisponible."
        case .parsingFailed:      return "Impossible de lire la réponse du serveur."
        case .emptyResults:       return "Aucun résultat trouvé."
        case .invalidURL:         return "URL invalide."
        }
    }
}

// MARK: - Codable DTOs

private struct DeezerSearchResponse: Codable {
    let data: [DeezerTrack]
}

private struct DeezerTrack: Codable {
    let id: Int
    let title: String
    let preview: String
    let artist: DeezerArtist
    let album: DeezerAlbum
}

private struct DeezerArtist: Codable {
    let name: String
}

private struct DeezerAlbum: Codable {
    let coverMedium: String

    enum CodingKeys: String, CodingKey {
        case coverMedium = "cover_medium"
    }
}

// MARK: - Service

final class DeezerService {
    static let shared = DeezerService()

    private let session: URLSession
    private let decoder = JSONDecoder()

    private init() {
        let config = URLSessionConfiguration.default
        config.timeoutIntervalForRequest = 10
        self.session = URLSession(configuration: config)
    }

    func searchTracks(query: String) async throws -> [Track] {
        guard !query.trimmingCharacters(in: .whitespaces).isEmpty else {
            throw DeezerError.emptyResults
        }
        guard let url = URL.deezerSearch(query: query) else {
            throw DeezerError.invalidURL
        }

        let data: Data
        let response: URLResponse
        do {
            (data, response) = try await session.data(from: url)
        } catch {
            throw DeezerError.networkUnavailable
        }

        guard (response as? HTTPURLResponse)?.statusCode == 200 else {
            throw DeezerError.networkUnavailable
        }

        let decoded: DeezerSearchResponse
        do {
            decoded = try decoder.decode(DeezerSearchResponse.self, from: data)
        } catch {
            throw DeezerError.parsingFailed
        }

        guard !decoded.data.isEmpty else {
            throw DeezerError.emptyResults
        }

        return decoded.data.map { mapTrack($0) }
    }

    private func mapTrack(_ dt: DeezerTrack) -> Track {
        Track(
            id: dt.id,
            title: dt.title,
            artist: dt.artist.name,
            previewURL: URL(string: dt.preview),
            albumCoverURL: URL(string: dt.album.coverMedium)
        )
    }
}
