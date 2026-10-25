import Foundation

let apiKey = "552e8e7858fd91a78ba2bd23827dd082"

struct NewsService {
    var session: URLSession = .shared
    var cacheDirectory: URL = URL.cachesDirectory.appending(path: "MiniNews", directoryHint: .isDirectory)
    private static let cacheLifetime: TimeInterval = 15 * 60

    static func responseError(statusCode: Int) -> NewsServiceError {
        switch statusCode {
        case 400: return .invalidRequest
        case 401: return .invalidAPIKey
        case 403: return .quotaExceeded
        case 429: return .rateLimited
        default: return .server(statusCode)
        }
    }

    private func cacheURL(for category: String) -> URL {
        let filename = Data(category.utf8).base64EncodedString()
            .replacingOccurrences(of: "/", with: "_")
        return cacheDirectory.appendingPathComponent(filename + ".json")
    }

    func cachedNews(category: String?) -> [Article]? {
        guard let data = try? Data(contentsOf: cacheURL(for: category ?? "Beşiktaş")) else {
            return nil
        }
        return try? JSONDecoder().decode(NewsResult.self, from: data).articles
    }

    func fetchNews(category: String?) async throws -> [Article] {
        let cacheURL = cacheURL(for: category ?? "Beşiktaş")
        if let attributes = try? FileManager.default.attributesOfItem(atPath: cacheURL.path),
           let modified = attributes[.modificationDate] as? Date,
           Date().timeIntervalSince(modified) < Self.cacheLifetime,
           let articles = cachedNews(category: category) {
            return articles
        }
        var components = URLComponents(string: "https://gnews.io/api/v4/search")!

        components.queryItems = [
            URLQueryItem(name: "q", value: category ?? "Beşiktaş"),
            URLQueryItem(name: "lang", value: "tr"),
            URLQueryItem(name: "max", value: "10"),
            URLQueryItem(name: "apikey", value: apiKey)
        ]
        
        guard let url = components.url else {
            throw URLError(.badURL)
        }

        let (data, response) = try await session.data(from: url)

        try Task.checkCancellation()
        guard let httpResponse = response as? HTTPURLResponse else {
            throw URLError(.badServerResponse)
        }
        guard (200...299).contains(httpResponse.statusCode) else {
            throw Self.responseError(statusCode: httpResponse.statusCode)
        }

        let newsResult = try JSONDecoder().decode(
            NewsResult.self,
            from: data
        )
        try? FileManager.default.createDirectory(
            at: cacheURL.deletingLastPathComponent(), withIntermediateDirectories: true
        )
        try? data.write(to: cacheURL, options: .atomic)
        return newsResult.articles
    }
}

enum NewsServiceError: LocalizedError {
    case invalidRequest, invalidAPIKey, quotaExceeded, rateLimited
    case server(Int)

    var errorDescription: String? {
        switch self {
        case .invalidRequest:
            return "Haber isteği geçersiz. API ayarlarını kontrol edin."
        case .invalidAPIKey:
            return "Haber servisi API anahtarı geçersiz. Geçerli bir GNews anahtarı gerekli."
        case .quotaExceeded:
            return "GNews günlük haber kotası doldu. Kota Türkiye saatiyle 03.00’te yenilenir. Daha erken erişim için GNews planını yükseltmeniz gerekir."
        case .rateLimited:
            return "Çok sık haber istendi. Lütfen birkaç saniye sonra tekrar deneyin."
        case .server(let status):
            return "Haber servisine şu anda erişilemiyor (HTTP \(status)). Lütfen daha sonra tekrar deneyin."
        }
    }
}
