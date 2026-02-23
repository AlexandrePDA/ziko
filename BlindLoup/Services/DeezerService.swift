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
    let cover_medium: String
}

// MARK: - Service

final class DeezerService {
    static let shared = DeezerService()

    private let session: URLSession

    init() {
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
        do {
            let (responseData, response) = try await session.data(from: url)
            guard (response as? HTTPURLResponse)?.statusCode == 200 else {
                throw DeezerError.networkUnavailable
            }
            data = responseData
        } catch is DeezerError {
            throw DeezerError.networkUnavailable
        } catch {
            throw DeezerError.networkUnavailable
        }

        let decoded: DeezerSearchResponse
        do {
            decoded = try JSONDecoder().decode(DeezerSearchResponse.self, from: data)
        } catch {
            throw DeezerError.parsingFailed
        }

        guard !decoded.data.isEmpty else {
            throw DeezerError.emptyResults
        }

        return decoded.data.map { dt in
            Track(
                id: dt.id,
                title: dt.title,
                artist: dt.artist.name,
                previewURL: URL(string: dt.preview),
                albumCoverURL: URL(string: dt.album.cover_medium)
            )
        }
    }
}
