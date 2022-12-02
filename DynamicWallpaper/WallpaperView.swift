//
//  WallpaperView.swift
//  DynamicWallpaper
//
//  Created by Kensuke Kubo on 2022/12/01.
//

import SwiftUI

enum WallpaperType: String, CaseIterable {
    case web
}

struct WallpaperView: View {
    let identifier: NSUserInterfaceItemIdentifier = NSUserInterfaceItemIdentifier.init(rawValue: UUID().uuidString)

    let type: WallpaperType
    let contentRect: NSRect

    let innerView: NSPanel

    var url: String?

    private init(type: WallpaperType, contentRect: NSRect,
                 url: String?) {
        self.type = type
        self.contentRect = contentRect

        self.url = url

        innerView = NSPanel(
                contentRect: contentRect,
                styleMask: [.nonactivatingPanel],
                backing: .buffered, defer: false)

        innerView.identifier = NSUserInterfaceItemIdentifier(rawValue: UUID().uuidString)

        innerView.contentView = NSHostingView(rootView: self)

        innerView.titleVisibility = .hidden
        innerView.titlebarAppearsTransparent = true

        innerView.backgroundColor = NSColor(white: 1, alpha: 0)
        innerView.hasShadow = false
        innerView.collectionBehavior = [.canJoinAllSpaces]
        innerView.orderFrontRegardless()

        disableControl()
    }

    init(contentRect: NSRect, url: String) {
        self.init(type: .web, contentRect: contentRect, url: url)
    }

    var body: some View {
        VStack {
            switch type {
            case .web:
                WebView(url: url!)
            }
        }
    }

    func enableControl() {
        innerView.level = NSWindow.Level(rawValue: NSWindow.Level.floating.rawValue - 1)
        innerView.styleMask = [.titled]
    }

    func disableControl() {
        innerView.level = NSWindow.Level(rawValue: Int(CGWindowLevelForKey(.desktopIconWindow)) - 1)
        innerView.styleMask = [.nonactivatingPanel]
        innerView.setFrame(contentRect, display: true)
    }
}
