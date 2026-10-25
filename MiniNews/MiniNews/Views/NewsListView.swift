import SwiftUI

struct NewsListView: View {
    @State private var viewModel = NewsViewModel()
    @State private var activeStoryStore = ActiveStoryStore()
    @State private var refreshID = UUID()

    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 26) {
                header
                    .padding(.horizontal, 24)

                ScrollView(.horizontal, showsIndicators: false) {
                    HStack(alignment: .top, spacing: 12) {
                        ForEach(storyImages, id: \.name) { story in
                            Button {
                                activeStoryStore.setActiveStory(story.name)
                            } label: {
                                StoryView(
                                    imageUrl: story.url, name: story.name,
                                    active: activeStoryStore.isActiveStory(story.name),
                                    visited: activeStoryStore.hasVisited(story.name)
                                )
                            }
                            .buttonStyle(.plain)
                            .accessibilityAddTraits(activeStoryStore.isActiveStory(story.name) ? .isSelected : [])
                        }
                    }
                    .padding(.horizontal, 24)
                }

                VStack(alignment: .leading, spacing: 18) {
                    HStack(alignment: .firstTextBaseline) {
                        VStack(alignment: .leading, spacing: 5) {
                            Text("GÜNDEMİNDE")
                                .font(.system(size: 10, weight: .bold))
                                .tracking(2)
                                .foregroundStyle(.secondary)
                            Text(activeStoryStore.activeStory)
                                .font(.system(.title, design: .serif, weight: .semibold))
                        }
                        Spacer()
                        if viewModel.isLoading {
                            ProgressView()
                        } else if !viewModel.articles.isEmpty {
                            Text("\(viewModel.articles.count) haber")
                                .font(.caption)
                                .foregroundStyle(.secondary)
                        }
                    }

                    if let error = viewModel.errorMessage {
                        errorNotice(error)
                    }
                    if !viewModel.isLoading && viewModel.errorMessage == nil && viewModel.articles.isEmpty {
                        ContentUnavailableView("Henüz haber yok", systemImage: "newspaper", description: Text("Başka bir konu seçebilir veya daha sonra tekrar bakabilirsin."))
                    }
                    LazyVStack(spacing: 16) {
                        ForEach(Array(viewModel.articles.enumerated()), id: \.element.id) { index, article in
                            NavigationLink {
                                NewsDetailView(article: article)
                            } label: {
                                ListCardContainer(article: article, featured: index == 0)
                            }
                            .buttonStyle(.plain)
                        }
                    }
                }
                .padding(.horizontal, 24)
            }
            .padding(.top, 16)
            .padding(.bottom, 32)
        }
        .background(Color(.systemGroupedBackground))
        .toolbar(.hidden, for: .navigationBar)
        .task(id: activeStoryStore.activeStory + refreshID.uuidString) {
            await viewModel.fetchNews(category: activeStoryStore.activeStory)
        }
        .refreshable {
            await viewModel.fetchNews(category: activeStoryStore.activeStory)
        }
    }

    private var header: some View {
        HStack(alignment: .center) {
            VStack(alignment: .leading, spacing: 6) {
                Text(Date.now.formatted(.dateTime.day().month(.wide).locale(Locale(identifier: "tr_TR"))).uppercased())
                    .font(.system(size: 10, weight: .semibold))
                    .tracking(2)
                    .foregroundStyle(.secondary)
                HStack(alignment: .firstTextBaseline, spacing: 0) {
                    Text("mini").fontWeight(.regular)
                    Text("news").fontWeight(.bold)
                    Text(".").foregroundStyle(.pink).fontWeight(.bold)
                }
                .font(.system(size: 36, design: .serif))
                Text("Sahadan, senin gündemine.")
                    .font(.subheadline)
                    .foregroundStyle(.secondary)
            }
            Spacer()
            Image(systemName: "sportscourt")
                .font(.title3)
                .foregroundStyle(.pink)
                .frame(width: 48, height: 48)
                .background(.pink.opacity(0.08), in: Circle())
                .accessibilityHidden(true)
        }
    }

    private func errorNotice(_ message: String) -> some View {
        VStack(alignment: .leading, spacing: 12) {
            Label("Haberler güncellenemedi", systemImage: "wifi.exclamationmark")
                .font(.subheadline.weight(.semibold))
            Text(message).font(.footnote).foregroundStyle(.secondary)
            if !viewModel.articles.isEmpty {
                Text("Kaydedilmiş haberler gösteriliyor.").font(.caption).foregroundStyle(.secondary)
            }
            Button("Tekrar dene", systemImage: "arrow.clockwise") {
                refreshID = UUID()
            }
            .font(.footnote.weight(.semibold))
            .tint(.pink)
            .disabled(viewModel.isLoading)
        }
        .frame(maxWidth: .infinity, alignment: .leading)
        .padding(20)
        .background(Color(.secondarySystemGroupedBackground), in: RoundedRectangle(cornerRadius: 20))
    }
}
