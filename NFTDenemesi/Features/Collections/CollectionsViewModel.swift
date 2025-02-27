import Foundation
import OSLog

@MainActor
final class CollectionsViewModel: ObservableObject {
    @Published private(set) var collections: [NFTCollection] = []
    @Published private(set) var error: OpenSeaError?
    @Published private(set) var isLoading = false
    
    private let service: OpenSeaServiceProtocol
    private let logger = Logger(subsystem: "com.NFTDenemesi", category: "CollectionsViewModel")
    
    init(service: OpenSeaServiceProtocol) {
        self.service = service
    }
    
    func fetchCollections() {
        isLoading = true
        error = nil
        collections = []
        
        Task {
            do {
                logger.info("Koleksiyonlar yükleniyor...")
                collections = try await service.fetchCollections()
                logger.info("Koleksiyonlar başarıyla yüklendi. Toplam: \(self.collections.count)")
            } catch let error as OpenSeaError {
                logger.error("OpenSea hatası: \(error.localizedDescription)")
                self.error = error
            } catch {
                logger.error("Bilinmeyen hata: \(error.localizedDescription)")
                self.error = .unknown(error.localizedDescription)
            }
            isLoading = false
        }
    }
    
    func retry() {
        fetchCollections()
    }
} 