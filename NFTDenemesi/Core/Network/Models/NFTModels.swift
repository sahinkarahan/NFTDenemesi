import Foundation

struct NFTCollection: Identifiable, Codable {
    let id: String
    let name: String
    let description: String?  // Optional
    let imageUrl: String?     // Optional
    let bannerImageUrl: String?  // Optional
    let owner: String
    let safelistStatus: String
    let category: String
    let isDisabled: Bool
    let isNsfw: Bool
    let traitOffersEnabled: Bool
    let collectionOffersEnabled: Bool
    let openseaUrl: String
    let projectUrl: String?   // Optional
    let wikiUrl: String?      // Optional
    let discordUrl: String?   // Optional
    let telegramUrl: String?  // Optional
    let twitterUsername: String?  // Optional
    let instagramUsername: String?  // Optional
    let contracts: [ContractInfo]
    let totalSupply: Int?     // Toplam NFT sayısı
    let totalOwners: Int?     // Toplam sahip sayısı
    
    // UI için computed properties
    var ownerCount: Int { totalOwners ?? 0 }
    var totalNFTs: Int { totalSupply ?? 0 }
    var createdDate: String { "" }
    var paymentTokens: [PaymentToken]? { nil }
    
    enum CodingKeys: String, CodingKey {
        case id = "collection"
        case name
        case description
        case imageUrl = "image_url"
        case bannerImageUrl = "banner_image_url"
        case owner
        case safelistStatus = "safelist_status"
        case category
        case isDisabled = "is_disabled"
        case isNsfw = "is_nsfw"
        case traitOffersEnabled = "trait_offers_enabled"
        case collectionOffersEnabled = "collection_offers_enabled"
        case openseaUrl = "opensea_url"
        case projectUrl = "project_url"
        case wikiUrl = "wiki_url"
        case discordUrl = "discord_url"
        case telegramUrl = "telegram_url"
        case twitterUsername = "twitter_username"
        case instagramUsername = "instagram_username"
        case contracts
        case totalSupply = "total_supply"
        case totalOwners = "total_owners"
    }
}

struct ContractInfo: Codable {
    let address: String
    let chain: String
}

struct PaymentToken: Codable {
    let symbol: String
    let address: String?
    let name: String
    let decimals: Int
}

struct NFTAsset: Identifiable, Codable {
    let id: String
    let name: String?
    let description: String?
    let imageUrl: String?
    let displayImageUrl: String?
    let animationUrl: String?
    let collection: String
    let identifier: String
    let contract: String
    let metadata: NFTMetadata?
    let tokenStandard: String?
    let isDisabled: Bool
    let isNsfw: Bool
    
    // Computed properties
    var tokenId: String { identifier }
    var permalink: String {
        "https://opensea.io/assets/ethereum/\(contract)/\(identifier)"
    }
    
    enum CodingKeys: String, CodingKey {
        case id = "nft_id"
        case name
        case description
        case imageUrl = "image_url"
        case displayImageUrl = "display_image_url"
        case animationUrl = "animation_url"
        case collection
        case identifier
        case contract
        case metadata
        case tokenStandard = "token_standard"
        case isDisabled = "is_disabled"
        case isNsfw = "is_nsfw"
    }
    
    init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        let identifier = try container.decode(String.self, forKey: .identifier)
        self.id = identifier
        self.identifier = identifier
        
        self.name = try container.decodeIfPresent(String.self, forKey: .name)
        self.description = try container.decodeIfPresent(String.self, forKey: .description)
        self.imageUrl = try container.decodeIfPresent(String.self, forKey: .imageUrl)
        self.displayImageUrl = try container.decodeIfPresent(String.self, forKey: .displayImageUrl)
        self.animationUrl = try container.decodeIfPresent(String.self, forKey: .animationUrl)
        self.collection = try container.decode(String.self, forKey: .collection)
        self.contract = try container.decode(String.self, forKey: .contract)
        self.metadata = try container.decodeIfPresent(NFTMetadata.self, forKey: .metadata)
        self.tokenStandard = try container.decodeIfPresent(String.self, forKey: .tokenStandard)
        self.isDisabled = try container.decode(Bool.self, forKey: .isDisabled)
        self.isNsfw = try container.decode(Bool.self, forKey: .isNsfw)
    }
}

struct NFTMetadata: Codable {
    let imageUrl: String?
    let animationUrl: String?
    let youtubeUrl: String?
    let backgroundColor: String?
    let name: String?
    let description: String?
    let externalUrl: String?
    let attributes: [NFTAttribute]?
    
    enum CodingKeys: String, CodingKey {
        case imageUrl = "image"
        case animationUrl = "animation_url"
        case youtubeUrl = "youtube_url"
        case backgroundColor = "background_color"
        case name
        case description
        case externalUrl = "external_url"
        case attributes = "traits"
    }
}

struct NFTAttribute: Codable {
    let traitType: String
    let value: String
    let displayType: String?
    
    enum CodingKeys: String, CodingKey {
        case traitType = "trait_type"
        case value
        case displayType = "display_type"
    }
}

struct NFTResponse: Codable {
    let nfts: [NFTAsset]
    let next: String?
    
    enum CodingKeys: String, CodingKey {
        case nfts = "nfts"
        case next = "next"
    }
}

struct CollectionResponse: Codable {
    let collections: [NFTCollection]
} 