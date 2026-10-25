import SwiftUI

struct StoryView: View {
    let imageUrl: String
    let name: String
    let active: Bool
    let visited: Bool

    var body: some View {
        VStack(spacing: 9) {
            AsyncImage(url: URL(string: imageUrl)) { phase in
                if let image = phase.image {
                    image.resizable().scaledToFill()
                } else {
                    Circle().fill(Color(.secondarySystemGroupedBackground))
                        .overlay {
                            Image(systemName: "person.fill")
                                .foregroundStyle(.secondary)
                        }
                }
            }
            .frame(width: 62, height: 62)
            .clipShape(Circle())
            .padding(5)
            .overlay {
                Circle().strokeBorder(visited ? Color.gray.opacity(0.45) : .pink, lineWidth: 2)
            }

            Text(name)
                .font(.caption2.weight(active ? .bold : .medium))
                .foregroundStyle(active ? Color.primary : .secondary)
                .lineLimit(2)
                .multilineTextAlignment(.center)
                .frame(height: 28, alignment: .top)
            Capsule().fill(active ? Color.primary : .clear)
                .frame(width: 16, height: 3)
        }
        .frame(width: 80)
        .accessibilityElement(children: .ignore)
        .accessibilityLabel(name)
        .accessibilityValue(active ? "Seçili" : visited ? "Daha önce görüntülendi" : "Henüz görüntülenmedi")
    }
}
