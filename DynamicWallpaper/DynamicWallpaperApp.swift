//
//  DynamicWallpaperApp.swift
//  DynamicWallpaper
//
//  Created by Kensuke Kubo on 2022/11/30.
//

import SwiftUI

@main
struct DynamicWallpaperApp: App {
    var body: some Scene {
        WindowGroup {
            ContentView()
                .onReceive(NotificationCenter.default.publisher(for: NSApplication.willUpdateNotification), perform: { _ in
                    buildWindow()
                })
        }
            .windowStyle(HiddenTitleBarWindowStyle())
            .windowResizability(.contentSize)

    }

    @State var built: Bool = false

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
        let wallpaper = NSPanel(
                contentRect: NSRect(x: 0, y: 0, width: displaySize.width, height: displaySize.height),
                styleMask: [.nonactivatingPanel],
                backing: .buffered, defer: false)

        wallpaper.contentView = NSHostingView(rootView: WallpaperView())

        wallpaper.backgroundColor = NSColor(white: 1, alpha: 0)
        wallpaper.hasShadow = false
        wallpaper.level = NSWindow.Level(rawValue: Int(CGWindowLevelForKey(.desktopIconWindow)) - 1)
        wallpaper.collectionBehavior = [.canJoinAllSpaces]
        wallpaper.order(.below, relativeTo: 0)
    }
}
