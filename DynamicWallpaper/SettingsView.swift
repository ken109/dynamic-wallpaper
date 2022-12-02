//
//  ContentView.swift
//  DynamicWallpaper
//
//  Created by Kensuke Kubo on 2022/11/30.
//

import SwiftUI

struct SettingsView: View {
    @Binding var wallpapers: [Wallpaper]

    @State var controlledWallpaperIdentifier: String? = nil
    @State var editingWallpaperIdentifier: String? = nil

    @State var editingUrl: String = ""

    var body: some View {
        VStack {
            List {
                ForEach(wallpapers, id: \.identifier) { wallpaper in
                    HStack {
                        Text(wallpaper.type.rawValue)

                        if wallpaper.type == .web {
                            if editingWallpaperIdentifier == wallpaper.identifier {
                                TextField("URL", text: $editingUrl)
                                    .frame(width: 300)
                            } else {
                                Text(wallpaper.url!)
                            }

                            Button(action: {
                                if editingWallpaperIdentifier == wallpaper.identifier {
                                    editingWallpaperIdentifier = nil
                                    wallpaper.url = editingUrl
                                } else {
                                    editingWallpaperIdentifier = wallpaper.identifier
                                    editingUrl = wallpaper.url!
                                }
                            }) {
                                if editingWallpaperIdentifier == wallpaper.identifier {
                                    Text("Done")
                                } else {
                                    Text("Edit")
                                }
                            }

                            Button {
                                if controlledWallpaperIdentifier == wallpaper.identifier {
                                    controlledWallpaperIdentifier = nil
                                    wallpaper.isControlEnabled = false
                                } else {
                                    controlledWallpaperIdentifier = wallpaper.identifier
                                    wallpaper.isControlEnabled = true
                                }
                            } label: {
                                if controlledWallpaperIdentifier == wallpaper.identifier {
                                    Text("end")
                                } else {
                                    Text("control")
                                }
                            }
                                .disabled(controlledWallpaperIdentifier != nil && controlledWallpaperIdentifier != wallpaper.identifier)
                        }
                    }
                }
            }
        }
            .frame(width: 500, height: 300)
            .onDisappear {
                controlledWallpaperIdentifier = nil
                wallpapers.forEach { wallpaper in
                    wallpaper.isControlEnabled = false
                }
            }
    }
}
