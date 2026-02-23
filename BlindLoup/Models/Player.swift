import Foundation

struct Player: Identifiable, Codable {
    let id: UUID
    var name: String
    var score: Int = 0
    var colorIndex: Int = 0
    var selectedTracks: [Track] = []

    init(id: UUID = UUID(), name: String, colorIndex: Int = 0) {
        self.id = id
        self.name = name
        self.colorIndex = colorIndex
    }
}
