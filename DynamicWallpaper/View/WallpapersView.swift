//
//  WallpapersView.swift
//  DynamicWallpaper
//
//  Created by Kensuke Kubo on 2023/05/14.
//

import SwiftUI

struct WallpapersView: View {
    @ObservedObject var wallpapers: WallpapersContainer
    
    init(wallpapers: WallpapersContainer) {
        self.wallpapers = wallpapers
    }
    
    var body: some View {
        let frame = NSScreen.main?.frame
        
        ZStack(alignment: .topLeading) {
            ForEach(wallpapers.value, id: \.id) { wallpaper in
                WallpaperView(wallpaper: wallpaper)
                    .offset(x: wallpaper.position.getX(), y: wallpaper.position.getY())
                    .frame(width: wallpaper.position.getWidth(), height: wallpaper.position.getHeight())
                
            }
        }.frame(width: frame?.width, height: frame?.height)
    }
}
