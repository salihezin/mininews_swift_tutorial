import SwiftUI

struct ListCardComponent: View {
    var article: Article
    let isEven: Bool = true

    var body: some View {
        VStack(alignment: .leading, spacing: 4) {
            Text(article.title)
                .font(.headline)
                .foregroundStyle(.primary)
                .multilineTextAlignment(.leading)
                .lineLimit(nil)
                .fixedSize(horizontal: false, vertical: true)
            Spacer()
            HStack {
                Text(formatNewsDate(article.publishedAt))
                    .font(.caption)
                Spacer()
                Text(article.source.name)
                    .font(.caption)
            }
        }
    }
}
