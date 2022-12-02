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
    @State var wallpapers: [WallpaperView] = []

    var body: some Scene {
        WindowGroup {
            ContentView(wallpapers: $wallpapers)
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
        let displaySize = NSScreen.main!.frame.size

        wallpapers.append(
                WallpaperView(
                        contentRect: NSRect(x: 0, y: 0, width: displaySize.width, height: displaySize.height),
                        url: "https://ken109.github.io/wallpaper")
        )
    }
}
