import Foundation

struct NewsResult: Decodable {
    let totalArticles: Int
    let articles: [Article]

}

struct Article: Decodable, Identifiable {
    let id: String
    let title: String
    let description: String?
    let content: String?
    let url: String
    let image: String?
    let publishedAt: String
    let lang: String
    let source: Source
}

struct Source: Decodable {
    let id: String
    let name: String
    let url: String
    let country: String
}