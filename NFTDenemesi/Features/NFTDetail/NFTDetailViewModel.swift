import Foundation

@MainActor
final class NFTDetailViewModel: ObservableObject {
    @Published private(set) var nfts: [NFTAsset] = []
    @Published private(set) var error: OpenSeaError?
    @Published private(set) var isLoading = false
    @Published private(set) var hasMoreNFTs = true
    
    private let collection: NFTCollection
    private let service: OpenSeaServiceProtocol
    private var currentOffset = 0
    private let pageSize = 20
    private var loadingTask: Task<Void, Never>?
    private var isFetching = false
    
    init(collection: NFTCollection, service: OpenSeaServiceProtocol) {
        self.collection = collection
        self.service = service
    }
    
    func fetchNFTs() {
        guard !isLoading else { return }
        
        // İlk yükleme
        isLoading = true
        error = nil
        nfts = []
        currentOffset = 0
        hasMoreNFTs = true
        
        loadNextPage()
    }
    
    func loadMoreNFTsIfNeeded(currentNFT nft: NFTAsset) {
        guard !isFetching && hasMoreNFTs,
              let index = nfts.firstIndex(where: { $0.id == nft.id }),
              index >= nfts.count - 5 else {
            return
        }
        
        loadNextPage()
    }
    
    private func loadNextPage() {
        guard !isFetching else { return }
        isFetching = true
        
        loadingTask?.cancel()
        loadingTask = Task {
            do {
                print("Debug - ViewModel: Fetching NFTs from offset \(currentOffset)")
                let newNFTs = try await service.fetchNFTs(forCollection: collection.id, offset: currentOffset, limit: pageSize)
                
                guard !Task.isCancelled else { return }
                
                // Yeni NFT'leri ekle
                nfts.append(contentsOf: newNFTs)
                
                // Daha fazla NFT var mı kontrol et
                hasMoreNFTs = newNFTs.count == pageSize
                
                // Offset'i güncelle
                currentOffset += pageSize
                
                print("Debug - ViewModel: Successfully fetched \(newNFTs.count) NFTs, total: \(nfts.count)")
            } catch let error as OpenSeaError {
                if !Task.isCancelled {
                    print("Debug - ViewModel: OpenSea error: \(error.localizedDescription)")
                    self.error = error
                }
            } catch {
                if !Task.isCancelled {
                    print("Debug - ViewModel: Unknown error: \(error.localizedDescription)")
                    self.error = .networkError(error.localizedDescription)
                }
            }
            
            if !Task.isCancelled {
                isLoading = false
                isFetching = false
            }
        }
    }
    
    func retry() {
        loadingTask?.cancel()
        fetchNFTs()
    }
    
    deinit {
        loadingTask?.cancel()
    }
} 
