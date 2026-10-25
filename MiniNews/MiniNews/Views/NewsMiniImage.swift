import SwiftUI

struct NewsMiniImage: View {
    let article: Article

    var body: some View {
        AsyncImage(url: article.image.flatMap(URL.init(string:))) { phase in
            if let image = phase.image {
                image.resizable().scaledToFill()
            } else {
                Rectangle().fill(Color(.tertiarySystemFill))
                    .overlay {
                        Image(systemName: "newspaper")
                            .font(.largeTitle.weight(.ultraLight))
                            .foregroundStyle(.secondary)
                    }
            }
        }
        .accessibilityHidden(true)
    }
}
