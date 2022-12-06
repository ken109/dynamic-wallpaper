//
//  DynamicWallpaperApp.swift
//  DynamicWallpaper
//
//  Created by Kensuke Kubo on 2022/11/30.
//

import SwiftUI

@main
struct DynamicWallpaperApp: App {
    @ObservedObject var wallpapers: WallpapersContainer = WallpapersContainer()

    @State var built: Bool = false

    var body: some Scene {
        WindowGroup {
            SettingsView(wallpapers: wallpapers)
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

        wallpapers.build()
    }
}
