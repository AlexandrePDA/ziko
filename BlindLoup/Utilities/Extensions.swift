import Foundation

extension URL {
    static func deezerSearch(query: String) -> URL? {
        var components = URLComponents(string: "https://api.deezer.com/search")
        components?.queryItems = [URLQueryItem(name: "q", value: query)]
        return components?.url
    }
}
