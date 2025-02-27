//
//  NFTDenemesiApp.swift
//  NFTDenemesi
//
//  Created by Şahin Karahan on 19.02.2025.
//

import SwiftUI

@main
struct NFTDenemesiApp: App {
    // OpenSea API v2 için API anahtarı
    private let openSeaService = OpenSeaService(apiKey: "71f8cda569a143f3bf7b0b1f9dd40b8c")
    
    var body: some Scene {
        WindowGroup {
            CollectionsView(service: openSeaService)
        }
    }
}
