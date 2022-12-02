//
//  ContentView.swift
//  DynamicWallpaper
//
//  Created by Kensuke Kubo on 2022/11/30.
//

import SwiftUI

struct ContentView: View {
    @State var activePanelIdentifier: NSUserInterfaceItemIdentifier? = nil

    @Binding var wallpapers: [WallpaperView]

    @State var message = "Hello, World!"
    @State var isRunning = false

    var body: some View {
        VStack {
            List {
                ForEach(wallpapers, id: \.identifier) { wallpaper in
                    HStack {
                        Text(wallpaper.identifier.rawValue)
                        Button {
                            if activePanelIdentifier == wallpaper.identifier {
                                activePanelIdentifier = nil
                                wallpaper.disableControl()
                            } else {
                                activePanelIdentifier = wallpaper.identifier
                                wallpaper.enableControl()
                            }
                        } label: {
                            if activePanelIdentifier == wallpaper.identifier {
                                Text("disable")
                            } else {
                                Text("enable")
                            }
                        }
                            .disabled(activePanelIdentifier != nil && activePanelIdentifier != wallpaper.identifier)
                    }
                }
            }
        }
            .frame(width: 500, height: 300)
            .onDisappear {
                activePanelIdentifier = nil
                wallpapers.forEach { panel in
                    panel.disableControl()
                }
            }
    }
}
