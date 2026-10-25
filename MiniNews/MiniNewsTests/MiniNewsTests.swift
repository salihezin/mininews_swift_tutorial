//
//  MiniNewsTests.swift
//  MiniNewsTests
//
//  Created by Salih Ezin on 24.10.2026.
//

import Testing
import Foundation
@testable import MiniNews

@MainActor
struct MiniNewsTests {
    @Test func selectingStoriesKeepsVisitedRingsGray() throws {
        let suite = "MiniNewsTests.\(UUID().uuidString)"
        let defaults = try #require(UserDefaults(suiteName: suite))
        defer { defaults.removePersistentDomain(forName: suite) }
        let store = ActiveStoryStore(defaults: defaults)
        #expect(store.activeStory == "Beşiktaş")
        #expect(store.hasVisited("Beşiktaş"))
        #expect(!store.hasVisited("Vlahovic"))
        store.setActiveStory("Vlahovic")
        #expect(store.activeStory == "Vlahovic")
        #expect(store.hasVisited("Beşiktaş"))
        #expect(store.hasVisited("Vlahovic"))
        #expect(!store.hasVisited("Orkun Kökçü"))
        #expect(ActiveStoryStore(defaults: defaults).hasVisited("Vlahovic"))
    }

    @Test func selectingTopicLoadsItsNewsAndClearsPreviousResultsOnFailure() async throws {
        let service = makeService()
        defer { try? FileManager.default.removeItem(at: service.cacheDirectory) }
        let model = NewsViewModel(service: service)
        await model.fetchNews(category: "Beşiktaş")
        #expect(model.articles.first?.title == "Beşiktaş")
        await model.fetchNews(category: "Vlahovic")
        #expect(model.articles.first?.title == "Vlahovic")
        await model.fetchNews(category: "quota-test")
        #expect(model.articles.isEmpty)
        #expect(model.errorMessage != nil)
    }
    private func makeService() -> NewsService {
        let configuration = URLSessionConfiguration.ephemeral
        configuration.protocolClasses = [NewsStubProtocol.self]
        return NewsService(
            session: URLSession(configuration: configuration),
            cacheDirectory: FileManager.default.temporaryDirectory.appendingPathComponent(UUID().uuidString)
        )
    }

    @Test func quotaResponseHasActionableError() async throws {
        let service = makeService()
        do {
            _ = try await service.fetchNews(category: "quota-test")
            Issue.record("Expected the daily quota error")
        } catch NewsServiceError.quotaExceeded {
            #expect(NewsServiceError.quotaExceeded.localizedDescription.contains("03.00"))
        }
    }

    @Test func successfulNewsIsReusedWithoutNetwork() async throws {
        let service = makeService()
        defer { try? FileManager.default.removeItem(at: service.cacheDirectory) }
        let articles = try await service.fetchNews(category: "cache-test")
        #expect(articles.count == 1)
        service.session.invalidateAndCancel()
        let cached = try await service.fetchNews(category: "cache-test")
        #expect(cached.first?.id == articles.first?.id)
        #expect(service.cachedNews(category: "another-topic") == nil)
    }

    @Test func expiredCacheRemainsAvailableWhenQuotaIsExceeded() async throws {
        let service = makeService()
        defer { try? FileManager.default.removeItem(at: service.cacheDirectory) }
        _ = try await service.fetchNews(category: "cache-test")
        let original = service.cacheDirectory.appendingPathComponent(Data("cache-test".utf8).base64EncodedString() + ".json")
        let quotaCache = service.cacheDirectory.appendingPathComponent(Data("quota-test".utf8).base64EncodedString() + ".json")
        try FileManager.default.copyItem(at: original, to: quotaCache)
        try FileManager.default.setAttributes([.modificationDate: Date.distantPast], ofItemAtPath: quotaCache.path)
        do {
            _ = try await service.fetchNews(category: "quota-test")
            Issue.record("Expired cache should trigger a refresh")
        } catch NewsServiceError.quotaExceeded {
            #expect(service.cachedNews(category: "quota-test")?.count == 1)
        }
    }
}

private final class NewsStubProtocol: URLProtocol, @unchecked Sendable {
    override class func canInit(with request: URLRequest) -> Bool { true }
    override class func canonicalRequest(for request: URLRequest) -> URLRequest { request }

    override func startLoading() {
        let url = request.url!
        let quota = URLComponents(url: url, resolvingAgainstBaseURL: false)?
            .queryItems?.contains { $0.name == "q" && $0.value == "quota-test" } == true
        let topic = URLComponents(url: url, resolvingAgainstBaseURL: false)?.queryItems?.first { $0.name == "q" }?.value ?? "Test"
        let body = quota ? #"{"errors":["Daily quota exceeded"]}"# : #"{"totalArticles":1,"articles":[{"id":"article-1","title":"\#(topic)","description":null,"content":null,"url":"https://example.com/news","image":null,"publishedAt":"2026-10-25T00:00:00Z","lang":"tr","source":{"id":"source-1","name":"Test","url":"https://example.com","country":"tr"}}]}"#
        let response = HTTPURLResponse(url: url, statusCode: quota ? 403 : 200, httpVersion: nil, headerFields: nil)!
        client?.urlProtocol(self, didReceive: response, cacheStoragePolicy: .notAllowed)
        client?.urlProtocol(self, didLoad: Data(body.utf8))
        client?.urlProtocolDidFinishLoading(self)
    }

    override func stopLoading() {}
}
