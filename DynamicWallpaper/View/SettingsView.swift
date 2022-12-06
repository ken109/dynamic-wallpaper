//
//  ContentView.swift
//  DynamicWallpaper
//
//  Created by Kensuke Kubo on 2022/11/30.
//

import SwiftUI

struct SettingsView: View {
    @Binding var wallpapers: [Wallpaper]

    @State private var selectedWallpaper: Wallpaper?

    var body: some View {
        NavigationSplitView {
            List(wallpapers, selection: $selectedWallpaper) { wallpaper in
                NavigationLink(value: wallpaper) {
                    Text(wallpaper.name)
                }
            }
                .toolbar {
                    Button {
                        let wallpaper = Wallpaper("New Wallpaper", webUrl: "https://ken109.github.io/wallpaper?disable-spotify", position: Position(.center))
                        wallpapers.append(wallpaper)
                        WallpaperStore.shared.saveWallpapers(wallpapers: wallpapers)
                        selectedWallpaper = wallpaper
                    } label: {
                        Image(systemName: "plus")
                    }
                }
        } detail: {
            DetailSettingsView(wallpapers: $wallpapers, wallpaper: $selectedWallpaper)
        }
            .onDisappear {
                wallpapers.forEach({ wallpaper in
                    wallpaper.isControlEnabled = false
                })
            }
    }
}

struct DetailSettingsView: View {
    @Binding var wallpapers: [Wallpaper]

    @Binding var wallpaper: Wallpaper?

    // position
    @State private var wallpaperPositionType: PositionType
    @State private var wallpaperPositionX: CGFloat
    @State private var wallpaperPositionY: CGFloat
    @State private var wallpaperPositionWidth: CGFloat
    @State private var wallpaperPositionHeight: CGFloat

    @State private var wallpaperType: WallpaperType

    // web
    @State private var webUrl: String

    // video
    @State private var videoPath: String

    @State private var isControlEnabled: Bool = false

    init(wallpapers: Binding<[Wallpaper]>, wallpaper: Binding<Wallpaper?>) {
        _wallpapers = wallpapers
        _wallpaper = wallpaper

        // position
        _wallpaperPositionType = State(initialValue: wallpaper.wrappedValue?.position.type ?? .center)
        _wallpaperPositionX = State(initialValue: wallpaper.wrappedValue?.position.x ?? 0)
        _wallpaperPositionY = State(initialValue: wallpaper.wrappedValue?.position.y ?? 0)
        _wallpaperPositionWidth = State(initialValue: wallpaper.wrappedValue?.position.width ?? 0)
        _wallpaperPositionHeight = State(initialValue: wallpaper.wrappedValue?.position.height ?? 0)

        _wallpaperType = State(initialValue: wallpaper.wrappedValue?.type ?? .off)
        _webUrl = State(initialValue: wallpaper.wrappedValue?.webUrl ?? "")
        _videoPath = State(initialValue: wallpaper.wrappedValue?.videoPath ?? "")
    }

    var body: some View {
        if let wallpaper {
            VStack {
                Form {
                    Section("Position") {
                        Picker("type", selection: $wallpaperPositionType) {
                            ForEach(PositionType.allCases, id: \.self) { position in
                                Text(position.rawValue)
                            }
                        }
                            .pickerStyle(.menu)

                        if wallpaperPositionType != .fullscreen {
                            TextField("width", value: $wallpaperPositionWidth, formatter: NumberFormatter())
                                .frame(width: 100)
                            TextField("height", value: $wallpaperPositionHeight, formatter: NumberFormatter())
                                .frame(width: 100)
                        }
                        if wallpaperPositionType == .custom {
                            TextField("x", value: $wallpaperPositionX, formatter: NumberFormatter())
                                .frame(width: 100)
                            TextField("y", value: $wallpaperPositionY, formatter: NumberFormatter())
                                .frame(width: 100)
                        }
                    }

                    Section("Content") {
                        Picker("type", selection: $wallpaperType) {
                            ForEach(WallpaperType.allCases, id: \.self) { type in
                                Text(type.rawValue)
                            }
                        }
                            .pickerStyle(.menu)

                        if wallpaperType == .web {
                            TextField("url", text: $webUrl, axis: .vertical)
                        }
                        if wallpaperType == .video {
                            LabeledContent("path") {
                                HStack {
                                    Text(videoPath)
                                    Spacer()
                                    Button("choose") {
                                        let panel = NSOpenPanel()
                                        panel.canChooseDirectories = false
                                        panel.canChooseFiles = true
                                        panel.allowsMultipleSelection = false
                                        panel.allowedContentTypes = [.mpeg4Movie, .movie]
                                        panel.begin { result in
                                            if result == .OK {
                                                if let url = panel.url {
                                                    videoPath = url.path
                                                }
                                            }
                                        }
                                    }
                                }
                            }
                        }
                    }
                }

                Spacer()

                // control button
                HStack {
                    if isControlEnabled {
                        Button {
                            // save position
                            wallpaper.savePosition()
                            setFormValues()
                            updateWallpaper()

                            isControlEnabled = false
                            wallpaper.isControlEnabled = false
                        } label: {
                            Text("Stop")
                        }
                    } else {
                        Button {
                            isControlEnabled = true
                            wallpaper.isControlEnabled = true
                        } label: {
                            Text("Control")
                        }
                    }

                    Spacer()

                    Button {
                        deleteWallpaper()
                    } label: {
                        Image(systemName: "trash")
                    }

                    Button {
                        updateWallpaper()
                    } label: {
                        Image(systemName: "checkmark")
                    }
                        .disabled(isControlEnabled)
                }
            }
                .padding()
                .onAppear(perform: setFormValues)
                .onChange(of: wallpaper) { _ in
                    setFormValues()
                }
        } else {
            Text("Please select an item")
        }
    }

    private func setFormValues() {
        // position
        wallpaperPositionType = wallpaper?.position.type ?? .center
        wallpaperPositionX = wallpaper?.position.x ?? 0
        wallpaperPositionY = wallpaper?.position.y ?? 0
        wallpaperPositionWidth = wallpaper?.position.width ?? 0
        wallpaperPositionHeight = wallpaper?.position.height ?? 0

        wallpaperType = wallpaper?.type ?? .off
        webUrl = wallpaper?.webUrl ?? ""
        videoPath = wallpaper?.videoPath ?? ""

        isControlEnabled = wallpaper?.isControlEnabled ?? false
    }

    private func deleteWallpaper() {
        wallpaper?.close()
        wallpapers.removeAll {
            $0.id == wallpaper?.id
        }
        wallpaper = nil
        WallpaperStore.shared.saveWallpapers(wallpapers: wallpapers)
    }

    private func updateWallpaper() {
        guard let wallpaper = wallpaper else {
            return
        }

        // position
        switch wallpaperPositionType {
        case .fullscreen:
            wallpaper.position = Position(.fullscreen)
        case .center:
            wallpaper.position = Position(.center,
                    width: wallpaperPositionWidth,
                    height: wallpaperPositionHeight)
        case .custom:
            wallpaper.position = Position(.custom,
                    x: wallpaperPositionX,
                    y: wallpaperPositionY,
                    width: wallpaperPositionWidth,
                    height: wallpaperPositionHeight)
        }

        wallpaper.type = wallpaperType
        wallpaper.webUrl = webUrl
        wallpaper.videoPath = videoPath

        if wallpaperType == .video && FileManager.default.fileExists(atPath: videoPath) {
            let url = URL(fileURLWithPath: videoPath)
            do {
                let bookmark = try url.bookmarkData(options: .securityScopeAllowOnlyReadAccess, includingResourceValuesForKeys: nil, relativeTo: nil)
                UserDefaults.standard.set(bookmark, forKey: "bookmark-" + wallpaper.id)
            } catch let error as NSError {
                print("Set Bookmark Fails: \(error.description)")
            }
        }

        wallpaper.reload()
        WallpaperStore.shared.saveWallpapers(wallpapers: wallpapers)
    }
}
