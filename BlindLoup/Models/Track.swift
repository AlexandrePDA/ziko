import Foundation

struct Track: Identifiable, Codable, Equatable {
    let id: Int
    let title: String
    let artist: String
    let previewURL: URL?
    let albumCoverURL: URL?
    var ownerID: UUID

    init(id: Int, title: String, artist: String, previewURL: URL?, albumCoverURL: URL?, ownerID: UUID = UUID()) {
        self.id = id
        self.title = title
        self.artist = artist
        self.previewURL = previewURL
        self.albumCoverURL = albumCoverURL
        self.ownerID = ownerID
    }

    static func == (lhs: Track, rhs: Track) -> Bool {
        lhs.id == rhs.id
    }
}
