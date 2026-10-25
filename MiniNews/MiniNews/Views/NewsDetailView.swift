import SwiftUI

struct NewsDetailView: View {
    let article: Article

    private var articleURL: URL? {
        guard let url = URL(string: article.url),
              ["https", "http"].contains(url.scheme?.lowercased() ?? "") else { return nil }
        return url
    }

    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 0) {
                NewsMiniImage(article: article)
                    .frame(height: 300)
                    .frame(maxWidth: .infinity)
                    .clipped()

                VStack(alignment: .leading, spacing: 24) {
                    VStack(alignment: .leading, spacing: 16) {
                        Text(article.source.name.uppercased())
                            .font(.system(size: 11, weight: .bold))
                            .tracking(2)
                            .foregroundStyle(.pink)
                        Text(article.title)
                            .font(.system(.largeTitle, design: .serif, weight: .semibold))
                            .fixedSize(horizontal: false, vertical: true)
                            .textSelection(.enabled)
                        Label(formatNewsDate(article.publishedAt), systemImage: "clock")
                            .font(.caption)
                            .foregroundStyle(.secondary)
                    }

                    Divider()

                    if let description = article.description, !description.isEmpty {
                        Text(description)
                            .font(.title3.weight(.medium))
                            .lineSpacing(6)
                            .textSelection(.enabled)
                    }
                    if let content = article.content, !content.isEmpty, content != article.description {
                        Text(content)
                            .font(.body)
                            .foregroundStyle(.secondary)
                            .lineSpacing(8)
                            .textSelection(.enabled)
                    }

                    VStack(alignment: .leading, spacing: 14) {
                        Label("Kaynağından oku", systemImage: "newspaper")
                            .font(.headline)
                        Text("Haberin tamamına ve tüm ayrıntılara \(article.source.name) üzerinden ulaşabilirsin.")
                            .font(.subheadline)
                            .foregroundStyle(.secondary)
                        if let url = articleURL {
                            Link(destination: url) {
                                HStack {
                                    Text("Haberin tamamını oku")
                                    Spacer()
                                    Image(systemName: "arrow.up.right")
                                }
                                .font(.subheadline.weight(.semibold))
                                .foregroundStyle(.white)
                                .padding(16)
                                .background(Color.pink, in: RoundedRectangle(cornerRadius: 14))
                            }
                        }
                    }
                    .padding(20)
                    .background(Color(.tertiarySystemGroupedBackground), in: RoundedRectangle(cornerRadius: 20))
                }
                .padding(24)
                .background(Color(.systemGroupedBackground), in: UnevenRoundedRectangle(topLeadingRadius: 28, topTrailingRadius: 28))
                .padding(.top, -24)
            }
        }
        .background(Color(.systemGroupedBackground))
        .navigationTitle("Haber")
        .navigationBarTitleDisplayMode(.inline)
        .toolbar(.visible, for: .navigationBar)
        .toolbar {
            if let url = articleURL {
                ToolbarItem(placement: .topBarTrailing) {
                    ShareLink(item: url) {
                        Image(systemName: "square.and.arrow.up")
                    }
                    .accessibilityLabel("Haberi paylaş")
                }
            }
        }
        .tint(.pink)
    }
}
