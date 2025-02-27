import SwiftUI
import Kingfisher

struct NFTDetailView: View {
    let collection: NFTCollection
    @StateObject private var viewModel: NFTDetailViewModel
    
    init(collection: NFTCollection, service: OpenSeaServiceProtocol = OpenSeaService(apiKey: "71f8cda569a143f3bf7b0b1f9dd40b8c")) {
        self.collection = collection
        _viewModel = StateObject(wrappedValue: NFTDetailViewModel(collection: collection, service: service))
    }
    
    var body: some View {
        ScrollView {
            VStack {
                if let bannerUrl = collection.bannerImageUrl, let url = URL(string: bannerUrl) {
                    KFImage(url)
                        .resizable()
                        .placeholder {
                            Color.gray.opacity(0.2)
                        }
                        .aspectRatio(contentMode: .fill)
                        .frame(height: 200)
                        .clipShape(.rect(cornerRadius: 12))
                        .padding(.horizontal)
                }
                
                VStack(alignment: .leading, spacing: 16) {
                    Text(collection.name)
                        .font(.title)
                        .bold()
                    
                    if let description = collection.description {
                        Text(description)
                            .font(.body)
                            .foregroundStyle(.secondary)
                    }
                    
                    HStack(spacing: 20) {
                        VStack {
                            Text("\(collection.ownerCount)")
                                .font(.headline)
                            Text("Sahipler")
                                .font(.caption)
                                .foregroundStyle(.secondary)
                        }
                        
                        VStack {
                            Text("\(collection.totalSupply)")
                                .font(.headline)
                            Text("Toplam NFT")
                                .font(.caption)
                                .foregroundStyle(.secondary)
                        }
                        
                        if let tokens = collection.paymentTokens {
                            VStack {
                                Text("\(tokens.count)")
                                    .font(.headline)
                                Text("Token")
                                    .font(.caption)
                                    .foregroundStyle(.secondary)
                            }
                        }
                    }
                }
                .padding()
                
                LazyVGrid(columns: [
                    GridItem(.flexible()),
                    GridItem(.flexible())
                ], spacing: 16) {
                    ForEach(viewModel.nfts) { nft in
                        NFTItemView(nft: nft)
                            .onAppear {
                                viewModel.loadMoreNFTsIfNeeded(currentNFT: nft)
                            }
                    }
                    
                    if viewModel.isLoading {
                        Section(footer: ProgressView().scaleEffect(1.5)) {
                            EmptyView()
                        }
                    }
                }
                .padding()
            }
        }
        .navigationBarTitleDisplayMode(.inline)
        .alert("Hata", isPresented: .constant(viewModel.error != nil)) {
            Button("Tamam", role: .cancel) {}
            Button("Tekrar Dene") {
                viewModel.retry()
            }
        } message: {
            Text(viewModel.error?.localizedDescription ?? "")
        }
        .task {
            await viewModel.fetchNFTs()
        }
    }
}

struct NFTItemView: View {
    let nft: NFTAsset
    
    var imageUrl: URL? {
        if let urlString = nft.displayImageUrl ?? nft.imageUrl ?? nft.metadata?.imageUrl {
            print("Debug - Found image URL: \(urlString)")
            return URL(string: urlString)
        }
        print("Debug - No image URL found for NFT: \(nft.id)")
        return nil
    }
    
    var body: some View {
        VStack {
            Group {
                if let url = imageUrl {
                    KFImage(url)
                        .resizable()
                        .placeholder {
                            Color.gray.opacity(0.2)
                        }
                        .aspectRatio(contentMode: .fill)
                        .frame(height: 180)
                        .clipShape(.rect(cornerRadius: 12))
                        .onAppear {
                            print("Debug - Loading image from URL: \(url)")
                        }
                } else {
                    RoundedRectangle(cornerRadius: 12)
                        .fill(Color.gray.opacity(0.2))
                        .frame(height: 180)
                }
            }
            
            VStack(alignment: .leading, spacing: 4) {
                Text(nft.name ?? "Unnamed NFT")
                    .font(.headline)
                    .lineLimit(1)
                    .onAppear {
                        print("Debug - NFT Name: \(nft.name ?? "Unnamed")")
                    }
                
                if let description = nft.description {
                    Text(description)
                        .font(.caption)
                        .foregroundStyle(.secondary)
                        .lineLimit(2)
                }
                
                HStack {
                    Text("Token ID: \(nft.tokenId)")
                        .font(.caption)
                        .padding(.horizontal, 8)
                        .padding(.vertical, 4)
                        .background(Color.blue.opacity(0.1))
                        .clipShape(.rect(cornerRadius: 8))
                    
                    if let standard = nft.tokenStandard {
                        Text(standard)
                            .font(.caption)
                            .padding(.horizontal, 8)
                            .padding(.vertical, 4)
                            .background(Color.green.opacity(0.1))
                            .clipShape(.rect(cornerRadius: 8))
                    }
                }
                
                if let url = URL(string: nft.permalink) {
                    Link(destination: url) {
                        Text("OpenSea'de Görüntüle")
                            .font(.caption)
                            .foregroundStyle(.blue)
                    }
                }
            }
            .padding(.horizontal, 8)
            .padding(.vertical, 4)
        }
        .background(Color.gray.opacity(0.1))
        .clipShape(.rect(cornerRadius: 12))
        .onAppear {
            print("Debug - NFT Details:")
            print("ID: \(nft.id)")
            print("Token ID: \(nft.tokenId)")
            print("Contract: \(nft.contract)")
            print("Image URL: \(nft.imageUrl ?? "nil")")
            print("Display Image URL: \(nft.displayImageUrl ?? "nil")")
            print("Metadata Image URL: \(nft.metadata?.imageUrl ?? "nil")")
        }
    }
}

#Preview {
    NFTDetailView(collection: NFTCollection(
        id: "test-collection",
        name: "Test Collection",
        description: "Test Description",
        imageUrl: nil,
        bannerImageUrl: nil,
        owner: "0x123...",
        safelistStatus: "not_requested",
        category: "",
        isDisabled: false,
        isNsfw: false,
        traitOffersEnabled: false,
        collectionOffersEnabled: true,
        openseaUrl: "https://opensea.io/collection/test-collection",
        projectUrl: nil,
        wikiUrl: nil,
        discordUrl: nil,
        telegramUrl: nil,
        twitterUsername: nil,
        instagramUsername: nil,
        contracts: [
            ContractInfo(
                address: "0x123...",
                chain: "ethereum"
            )
        ],
        totalSupply: 1000,
        totalOwners: 500
    ))
} 
