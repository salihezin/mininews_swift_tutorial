import SwiftUI

struct ListCardContainer: View {
    let article: Article
    var featured = false

    var body: some View {
        Group {
            if featured {
                VStack(alignment: .leading, spacing: 0) {
                    NewsMiniImage(article: article)
                        .frame(height: 220)
                        .clipped()
                    VStack(alignment: .leading, spacing: 12) {
                        Text("ÖNE ÇIKAN")
                            .font(.system(size: 10, weight: .bold, design: .rounded))
                            .tracking(2)
                            .foregroundStyle(.pink)
                        Text(article.title)
                            .font(.system(.title2, design: .serif, weight: .semibold))
                            .fixedSize(horizontal: false, vertical: true)
                        if let description = article.description, !description.isEmpty {
                            Text(description)
                                .font(.subheadline)
                                .foregroundStyle(.secondary)
                                .lineLimit(3)
                        }
                        metadata
                    }
                    .padding(20)
                }
            } else {
                HStack(alignment: .top, spacing: 16) {
                    VStack(alignment: .leading, spacing: 12) {
                        Text(article.title)
                            .font(.system(.headline, design: .serif))
                            .lineLimit(4)
                            .fixedSize(horizontal: false, vertical: true)
                        metadata
                    }
                    Spacer(minLength: 0)
                    NewsMiniImage(article: article)
                        .frame(width: 88, height: 100)
                        .clipShape(RoundedRectangle(cornerRadius: 14))
                }
                .padding(18)
            }
        }
        .frame(maxWidth: .infinity, alignment: .leading)
        .background(Color(.secondarySystemGroupedBackground))
        .clipShape(RoundedRectangle(cornerRadius: 24))
        .overlay {
            RoundedRectangle(cornerRadius: 24)
                .strokeBorder(Color.primary.opacity(0.05))
        }
        .foregroundStyle(.primary)
        .multilineTextAlignment(.leading)
    }

    private var metadata: some View {
        HStack(alignment: .firstTextBaseline, spacing: 8) {
            Text(article.source.name).fontWeight(.semibold)
            Spacer(minLength: 4)
            Text(formatNewsDate(article.publishedAt))
        }
        .font(.caption2)
        .foregroundStyle(.secondary)
    }
}
