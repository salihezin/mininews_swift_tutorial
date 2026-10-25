import Foundation
internal import Combine

@MainActor
@Observable
class NewsViewModel {
    var articles: [Article] = []
    var isLoading = false
    var errorMessage: String? = nil
    private var requestID = UUID()
    private let service: NewsService

    init(service: NewsService = NewsService()) {
        self.service = service
    }

    func fetchNews(category: String?) async {
        let currentRequestID = UUID()
        requestID = currentRequestID
        isLoading = true
        errorMessage = nil
        articles = service.cachedNews(category: category) ?? []

        defer {
            if requestID == currentRequestID {
                isLoading = false
            }
        }

        do {
            let fetchedArticles = try await service.fetchNews(category: category)
            guard requestID == currentRequestID, !Task.isCancelled else { return }
            articles = fetchedArticles
        } catch {
            guard requestID == currentRequestID, !Task.isCancelled,
                  !(error is CancellationError),
                  (error as? URLError)?.code != .cancelled else { return }
            if error is NewsServiceError {
                errorMessage = error.localizedDescription
            } else if error is DecodingError {
                errorMessage = "Haber servisinin yanıtı okunamadı. Lütfen daha sonra tekrar deneyin."
            } else {
                errorMessage = "Haberler yüklenemedi. İnternet bağlantınızı kontrol edip tekrar deneyin."
            }
        }
    }
}
