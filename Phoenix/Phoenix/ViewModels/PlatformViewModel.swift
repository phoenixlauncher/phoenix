//
//  PlatformViewModel.swift
//  Phoenix
//
//  Created by jxhug on 5/20/24.
//

import Foundation

@MainActor
class PlatformViewModel: ObservableObject {
    @Published var platforms: [Platform] = []
    
    init() {
        platforms = loadPlatforms()
    }
    
    func loadPlatforms() -> [Platform] {
        let res = loadPlatformsFromJSON()
        return res
    }
    
    func savePlatforms() {
        print("Saving platforms")
        saveJSONData(to: "platforms", with: convertPlatformsToJSONString(platforms))
    }
}
