//
//  DynamicWallpaperApp.swift
//  DynamicWallpaper
//
//  Created by Kensuke Kubo on 2022/11/30.
//

import SwiftUI

@main
struct DynamicWallpaperApp: App {
    @State var built: Bool = false
    @State var wallpapers: [Wallpaper] = []

    var body: some Scene {
        WindowGroup {
            SettingsView(wallpapers: $wallpapers)
                .onReceive(NotificationCenter.default.publisher(for: NSApplication.willUpdateNotification), perform: { _ in
                    buildWindow()
                })
        }
            .windowStyle(HiddenTitleBarWindowStyle())
            .windowResizability(.contentSize)
    }

    func buildWindow() {
        if built {
            return
        }
        built = true

        // setting window
        for window in NSApplication.shared.windows {
            window.level = .floating
            window.collectionBehavior = [.canJoinAllSpaces]
        }

        // wallpaper
        wallpapers = WallpaperStore.shared.loadWallpapers()

        if wallpapers.isEmpty {
            wallpapers.append(
                    Wallpaper(
                            "Clock",
                            url: "https://ken109.github.io/wallpaper?disable-spotify",
                            position: Position(.fullscreen)
                    )
            )
            WallpaperStore.shared.saveWallpapers(wallpapers: wallpapers)
        }
    }
}
