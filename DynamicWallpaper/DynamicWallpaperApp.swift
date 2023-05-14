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
        
        // panel
        let panel = NSPanel(
            contentRect: NSScreen.main!.frame,
            styleMask: [.nonactivatingPanel],
            backing: .buffered, defer: false)
        
        panel.identifier = NSUserInterfaceItemIdentifier(rawValue: UUID().uuidString)
        
        panel.contentView = NSHostingView(rootView: WallpapersView(wallpapers: wallpapers))
        
        panel.titleVisibility = .hidden
        
        panel.backgroundColor = NSColor(white: 1, alpha: 0)
        panel.hasShadow = false
        panel.collectionBehavior = [.canJoinAllSpaces]
        panel.orderFrontRegardless()
        
        panel.level = NSWindow.Level(rawValue: Int(CGWindowLevelForKey(.desktopIconWindow)) - 1)
        panel.styleMask = [.nonactivatingPanel]
    }
}
