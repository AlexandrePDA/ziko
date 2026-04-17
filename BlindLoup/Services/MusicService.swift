import Foundation
import MusicKit

// MARK: - Errors

enum MusicServiceError: LocalizedError {
    case emptyResults
    case networkUnavailable
    case authorizationDenied

    var errorDescription: String? {
        switch self {
        case .emptyResults:        return "Aucun résultat trouvé."
        case .networkUnavailable:  return "Connexion réseau indisponible."
        case .authorizationDenied: return "Accès à Apple Music refusé. Active-le dans les Réglages."
        }
    }
}

// MARK: - Service

final class MusicService {
    static let shared = MusicService()
    private init() {}

    func searchTracks(query: String) async throws -> [Track] {
        guard !query.isBlank else { throw MusicServiceError.emptyResults }

        let status = await MusicAuthorization.request()
        guard status == .authorized else { throw MusicServiceError.authorizationDenied }

        var request = MusicCatalogSearchRequest(term: query.trimmed, types: [Song.self])
        request.limit = 25

        do {
            let response = try await request.response()
            let tracks = response.songs.compactMap(mapSong)
            guard !tracks.isEmpty else { throw MusicServiceError.emptyResults }
            return tracks
        } catch let error as MusicServiceError {
            throw error
        } catch {
            #if DEBUG
            print("MusicKit error: \(error)")
            #endif
            throw MusicServiceError.networkUnavailable
        }
    }

    // MARK: - Private

    private func mapSong(_ song: Song) -> Track? {
        guard let previewURL = song.previewAssets?.first?.url else { return nil }
        let coverURL = song.artwork?.url(width: 300, height: 300)
        return Track(
            id: song.id.rawValue,
            title: song.title,
            artist: song.artistName,
            previewURL: previewURL,
            albumCoverURL: coverURL
        )
    }
}
