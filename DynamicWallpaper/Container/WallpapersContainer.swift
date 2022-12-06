//
// Created by Kensuke Kubo on 2022/12/07.
//

import SwiftUI

class WallpapersContainer: ObservableObject {
    @Published var value: [Wallpaper] = []

    func build() {
        for wallpaper in loadWallpapers() {
            value.append(wallpaper)
        }

        if value.isEmpty {
            value.append(
                    Wallpaper(
                            "Clock",
                            webUrl: "https://ken109.github.io/wallpaper?disable-spotify",
                            position: Position(.fullscreen)
                    )
            )
            saveWallpapers(wallpapers: value)
        }
    }

    func save() {
        objectWillChange.send()
        saveWallpapers(wallpapers: value)
    }

    func add(_ wallpaper: Wallpaper) {
        value.append(wallpaper)
        saveWallpapers(wallpapers: value)
    }

    func remove(_ wallpaper: Wallpaper) {
        wallpaper.close()
        value.removeAll {
            $0.id == wallpaper.id
        }
        saveWallpapers(wallpapers: value)
    }

    func update(_ wallpaper: Wallpaper) {
        value.removeAll {
            $0.id == wallpaper.id
        }
        value.append(wallpaper)
        saveWallpapers(wallpapers: value)
    }

    private func saveWallpapers(wallpapers: [Wallpaper]) {
        let jsonEncoder = JSONEncoder()
        guard let data = try? jsonEncoder.encode(wallpapers) else {
            print("Failed to encode wallpapers")
            return
        }
        UserDefaults.standard.set(data, forKey: "wallpapers")
    }

    private func loadWallpapers() -> [Wallpaper] {
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
