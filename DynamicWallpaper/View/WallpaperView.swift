//
//  WallpaperView.swift
//  DynamicWallpaper
//
//  Created by Kensuke Kubo on 2022/12/01.
//

import SwiftUI

struct WallpaperView: View {
    @ObservedObject var wallpaper: Wallpaper
    
    init(wallpaper: Wallpaper) {
        self.wallpaper = wallpaper
    }
    
    var body: some View {
        switch wallpaper.type {
        case .off:
            EmptyView()
        case .web:
            WebView(url: wallpaper.webUrl!)
        case .video:
            VideoView(path: wallpaper.videoPath!)
        case .command:
            CommandView(command: wallpaper.command!)
        }
    }
}
