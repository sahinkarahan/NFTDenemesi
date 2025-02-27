import SwiftUI
import Kingfisher

struct CollectionsView: View {
    @StateObject private var viewModel: CollectionsViewModel
    @State private var showError = false
    
    init(service: OpenSeaServiceProtocol) {
        _viewModel = StateObject(wrappedValue: CollectionsViewModel(service: service))
    }
    
    var body: some View {
        NavigationStack {
            ZStack {
                if viewModel.isLoading {
                    ProgressView()
                        .scaleEffect(1.5)
                } else if viewModel.error != nil {
                    VStack(spacing: 16) {
                        Image(systemName: "exclamationmark.triangle.fill")
                            .font(.system(size: 50))
                            .foregroundStyle(.red)
                        
                        Text(viewModel.error?.localizedDescription ?? "")
                            .multilineTextAlignment(.center)
                            .foregroundStyle(.secondary)
                        
                        Button(action: {
                            viewModel.retry()
                        }) {
                            Label("Tekrar Dene", systemImage: "arrow.clockwise")
                                .font(.headline)
                        }
                        .buttonStyle(.bordered)
                    }
                    .padding()
                } else if viewModel.collections.isEmpty {
                    ContentUnavailableView(
                        "Koleksiyon Bulunamadı",
                        systemImage: "photo.on.rectangle.angled",
                        description: Text("Henüz hiç NFT koleksiyonu yok.")
                    )
                } else {
                    List(viewModel.collections) { collection in
                        NavigationLink(destination: NFTDetailView(collection: collection)) {
                            CollectionRowView(collection: collection)
                        }
                    }
                    .listStyle(.plain)
                    .refreshable {
                        await viewModel.fetchCollections()
                    }
                }
            }
            .navigationTitle("NFT Koleksiyonları")
        }
        .task {
            await viewModel.fetchCollections()
        }
    }
}

struct CollectionRowView: View {
    let collection: NFTCollection
    
    var body: some View {
        HStack(spacing: 12) {
            if let imageUrl = collection.imageUrl, let url = URL(string: imageUrl) {
                KFImage(url)
                    .resizable()
                    .placeholder {
                        Color.gray.opacity(0.2)
                    }
                    .aspectRatio(contentMode: .fill)
                    .frame(width: 60, height: 60)
                    .clipShape(.rect(cornerRadius: 8))
            } else {
                RoundedRectangle(cornerRadius: 8)
                    .fill(Color.gray.opacity(0.2))
                    .frame(width: 60, height: 60)
            }
            
            VStack(alignment: .leading, spacing: 4) {
                Text(collection.name)
                    .font(.headline)
                
                if let description = collection.description {
                    Text(description)
                        .font(.subheadline)
                        .foregroundStyle(.secondary)
                        .lineLimit(2)
                }
                
                HStack {
                    Label("\(collection.ownerCount)", systemImage: "person.fill")
                    Label("\(collection.totalNFTs)", systemImage: "photo.fill")
                }
                .font(.caption)
                .foregroundStyle(.secondary)
            }
        }
        .padding(.vertical, 8)
    }
}

#Preview {
    CollectionsView(service: OpenSeaService(apiKey: "YOUR_API_KEY"))
} 