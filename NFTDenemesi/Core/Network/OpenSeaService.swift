import Foundation
import Alamofire

enum OpenSeaError: LocalizedError {
    case invalidURL
    case decodingError(String)
    case networkError(String)
    case serverError(Int, String)
    case unauthorized
    case rateLimited
    case unknown(String)
    
    var errorDescription: String? {
        switch self {
        case .invalidURL:
            return "Geçersiz URL"
        case .decodingError(let message):
            return "Veri çözümleme hatası: \(message)"
        case .networkError(let message):
            return "Ağ hatası: \(message)"
        case .serverError(let code, let message):
            return "Sunucu hatası (\(code)): \(message)"
        case .unauthorized:
            return "API anahtarı geçersiz veya yetkisiz erişim"
        case .rateLimited:
            return "API istek limiti aşıldı"
        case .unknown(let message):
            return "Bilinmeyen hata: \(message)"
        }
    }
}

protocol OpenSeaServiceProtocol {
    func fetchCollections() async throws -> [NFTCollection]
    func fetchNFTs(forCollection collectionId: String, offset: Int, limit: Int) async throws -> [NFTAsset]
}

final class OpenSeaService: OpenSeaServiceProtocol {
    private let baseURL = "https://api.opensea.io/api/v2"
    private let apiKey: String
    private let cache = NSCache<NSString, CachedResponse>()
    
    init(apiKey: String) {
        self.apiKey = apiKey.replacingOccurrences(of: "Bearer ", with: "")
        cache.countLimit = 100 // Cache limiti
    }
    
    private var headers: HTTPHeaders {
        [
            "X-API-KEY": apiKey,
            "Accept": "application/json"
        ]
    }
    
    // Cache için yardımcı sınıf
    private class CachedResponse {
        let data: Any
        let timestamp: Date
        
        init(data: Any) {
            self.data = data
            self.timestamp = Date()
        }
        
        var isValid: Bool {
            return Date().timeIntervalSince(timestamp) < 300 // 5 dakika cache süresi
        }
    }
    
    func fetchCollections() async throws -> [NFTCollection] {
        let url = "\(baseURL)/collections"
        let parameters: [String: Any] = [
            "chain": "ethereum",
            "include_hidden": false,
            "has_nfts": true,
            "limit": 100,
            "order_by": "seven_day_volume",
            "order_direction": "desc"
        ]
        
        do {
            let request = AF.request(url, 
                                   method: .get,
                                   parameters: parameters,
                                   headers: headers)
            
            print("Debug - Collections Request URL: \(url)")
            print("Debug - Collections Headers: \(headers)")
            print("Debug - Collections Parameters: \(parameters)")
            
            let response = try await request
                .validate()
                .serializingDecodable(CollectionResponse.self)
                .value
            
            print("Debug - Successfully fetched \(response.collections.count) collections")
            return response.collections
        } catch {
            print("Debug - Error: \(error)")
            throw error
        }
    }
    
    func fetchNFTs(forCollection collectionId: String, offset: Int, limit: Int) async throws -> [NFTAsset] {
        print("Debug - Fetching NFTs for collection: \(collectionId), offset: \(offset), limit: \(limit)")
        
        let collection = try await fetchCollection(slug: collectionId)
        guard let contract = collection.contracts.first else {
            print("Debug - No contract found for collection")
            throw OpenSeaError.unknown("Koleksiyon için contract bulunamadı")
        }
        
        // Cache key oluştur (sayfa bazlı)
        let cacheKey = "nfts_\(collectionId)_\(offset)_\(limit)" as NSString
        
        // Cache'den kontrol et
        if let cached = cache.object(forKey: cacheKey), cached.isValid {
            print("Debug - Using cached NFTs for page at offset \(offset)")
            return cached.data as! [NFTAsset]
        }
        
        print("Debug - Found contract: \(contract.address)")
        
        let parameters: [String: Any] = [
            "limit": limit,
            "offset": offset,
            "include_orders": false,
            "order_by": "pk",
            "order_direction": "desc"
        ]
        
        let url = "\(baseURL)/chain/ethereum/contract/\(contract.address)/nfts"
        let request = AF.request(url,
                               method: .get,
                               parameters: parameters,
                               headers: headers)
        
        print("Debug - NFTs Request URL: \(url)")
        print("Debug - NFTs Parameters: \(parameters)")
        
        let response = try await request
            .validate()
            .serializingDecodable(NFTResponse.self)
            .value
        
        // Sonuçları cache'e kaydet
        cache.setObject(CachedResponse(data: response.nfts), forKey: cacheKey)
        
        print("Debug - Successfully fetched \(response.nfts.count) NFTs")
        return response.nfts
    }
    
    private func fetchCollection(slug: String) async throws -> NFTCollection {
        // Cache key oluştur
        let cacheKey = "collection_\(slug)" as NSString
        
        // Cache'den kontrol et
        if let cached = cache.object(forKey: cacheKey), cached.isValid {
            print("Debug - Using cached collection for \(slug)")
            return cached.data as! NFTCollection
        }
        
        let url = "\(baseURL)/collections/\(slug)"
        
        print("Debug - Collection Request URL: \(url)")
        print("Debug - Collection Headers: \(headers)")
        
        do {
            let request = AF.request(url,
                                   method: .get,
                                   headers: headers)
            
            let response = try await request
                .validate()
                .serializingDecodable(NFTCollection.self)
                .value
            
            // Sonucu cache'e kaydet
            cache.setObject(CachedResponse(data: response), forKey: cacheKey)
            
            return response
        } catch {
            print("Debug - Collection Error: \(error)")
            throw error
        }
    }
}

 
