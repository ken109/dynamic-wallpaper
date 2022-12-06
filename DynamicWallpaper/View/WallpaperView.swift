//
//  WallpaperView.swift
//  DynamicWallpaper
//
//  Created by Kensuke Kubo on 2022/12/01.
//

import SwiftUI

struct WallpaperView: View {
    let identifier: NSUserInterfaceItemIdentifier = NSUserInterfaceItemIdentifier.init(rawValue: UUID().uuidString)

    let wallpaper: Wallpaper

    let innerView: NSPanel

    init(wallpaper: Wallpaper) {
        self.wallpaper = wallpaper

        innerView = NSPanel(
                contentRect: wallpaper.position.result(),
                styleMask: [.nonactivatingPanel],
                backing: .buffered, defer: false)

        innerView.identifier = NSUserInterfaceItemIdentifier(rawValue: UUID().uuidString)

        innerView.contentView = NSHostingView(rootView: self)

        innerView.titleVisibility = .hidden

        innerView.backgroundColor = NSColor(white: 1, alpha: 0)
        innerView.hasShadow = false
        innerView.collectionBehavior = [.canJoinAllSpaces]
        innerView.orderFrontRegardless()

        disableControl()

        self.wallpaper.setOnEnableControl { [self] in
            innerView.level = NSWindow.Level(rawValue: NSWindow.Level.floating.rawValue - 1)
            innerView.styleMask = [.titled]
        }
        self.wallpaper.setOnDisableControl { [self] in
            disableControl()
        }
    }

    var body: some View {
        VStack {
            switch wallpaper.type {
            case .off:
                EmptyView()
            case .web:
                WebView(url: wallpaper.url!)
            }
        }
    }

    func update() {
        innerView.contentView = NSHostingView(rootView: self)
        innerView.setFrame(wallpaper.position.result(), display: true)
    }

    func enableControl() {
        innerView.level = NSWindow.Level(rawValue: NSWindow.Level.floating.rawValue - 1)
        innerView.styleMask = [.titled]
    }

    func disableControl() {
        innerView.level = NSWindow.Level(rawValue: Int(CGWindowLevelForKey(.desktopIconWindow)) - 1)
        innerView.styleMask = [.nonactivatingPanel]
        innerView.setFrame(wallpaper.position.result(), display: true)
    }
}
