import Foundation

extension String {
    /// Chaîne sans espaces en début/fin.
    var trimmed: String { trimmingCharacters(in: .whitespaces) }

    /// `true` si la chaîne est vide ou ne contient que des espaces.
    var isBlank: Bool { trimmed.isEmpty }
}
