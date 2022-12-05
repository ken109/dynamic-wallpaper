//
// Created by Kensuke Kubo on 2022/12/02.
//

import Foundation

class WallpaperStore {
    public static let shared = WallpaperStore()

    private init() {
    }

    func saveWallpapers(wallpapers: [Wallpaper]) {
        let jsonEncoder = JSONEncoder()
        guard let data = try? jsonEncoder.encode(wallpapers) else {
            print("Failed to encode wallpapers")
            return
        }
        UserDefaults.standard.set(data, forKey: "wallpapers")
    }

    func loadWallpapers() -> [Wallpaper] {
        let jsonDecoder = JSONDecoder()
        guard let data = UserDefaults.standard.data(forKey: "wallpapers") else {
            print("Failed to load wallpapers")
            return []
        }

        guard let wallpapers = try? jsonDecoder.decode([Wallpaper].self, from: data) else {
            print("Failed to decode wallpapers")
            return []
        }
        return wallpapers
    }
}
