//
//  ContentView.swift
//  DynamicWallpaper
//
//  Created by Kensuke Kubo on 2022/11/30.
//

import SwiftUI

struct SettingsView: View {
    @ObservedObject var wallpapers: WallpapersContainer

    @State private var selectedWallpaper: Wallpaper? = nil

    var body: some View {
        NavigationSplitView {
            List(wallpapers.value, selection: $selectedWallpaper) { wallpaper in
                NavigationLink(value: wallpaper) {
                    Text(wallpaper.name)
                }
            }
                .toolbar {
                    Button {
                        let wallpaper = Wallpaper("New Wallpaper",
                                webUrl: "https://ken109.github.io/wallpaper?disable-spotify",
                                position: Position(.center))
                        wallpapers.add(wallpaper)
                        selectedWallpaper = wallpaper
                    } label: {
                        Image(systemName: "plus")
                    }
                }
        } detail: {
            if let wallpaper = selectedWallpaper, !wallpaper.isClosed {
                DetailSettingsView(wallpapers: wallpapers, wallpaper: wallpaper)
            } else {
                Text("Select a wallpaper")
            }
        }
            .onDisappear {
                wallpapers.value.forEach({ wallpaper in
                    wallpaper.isControlEnabled = false
                })
            }
    }
}

struct DetailSettingsView: View {
    @ObservedObject var wallpapers: WallpapersContainer
    @ObservedObject var wallpaper: Wallpaper

    @State private var name: String = ""

    // position
    @State private var wallpaperPositionType: PositionType = .center
    @State private var wallpaperPositionX: CGFloat = 0
    @State private var wallpaperPositionY: CGFloat = 0
    @State private var wallpaperPositionWidth: CGFloat = 0
    @State private var wallpaperPositionHeight: CGFloat = 0

    @State private var wallpaperType: WallpaperType = .off

    // web
    @State private var webUrl: String = ""

    // video
    @State private var videoPath: String = ""

    @State private var isControlEnabled: Bool = false

    init(wallpapers: WallpapersContainer, wallpaper: Wallpaper) {
        self.wallpapers = wallpapers
        self.wallpaper = wallpaper
    }

    var body: some View {
        VStack {
            Form {
                TextField("name", text: $name)

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
                .disabled(isControlEnabled)

            Spacer()

            // control button
            HStack {
                if isControlEnabled {
                    Button {
                        // save position
                        wallpaper.savePosition()
                        setFormValues(wallpaper: wallpaper)
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
                        .disabled(wallpaper.position.type != wallpaperPositionType)
                }

                Spacer()

                Button {
                    wallpapers.remove(wallpaper)
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
            .onAppear {
                setFormValues(wallpaper: wallpaper)
            }
            .onChange(of: wallpaper) { wallpaper in
                setFormValues(wallpaper: wallpaper)
            }
    }

    private func setFormValues(wallpaper: Wallpaper) {
        // general
        name = wallpaper.name

        let defaultPosition = Position(.custom)
        // position
        wallpaperPositionType = wallpaper.position.type
        wallpaperPositionX = wallpaper.position.x ?? defaultPosition.x!
        wallpaperPositionY = wallpaper.position.y ?? defaultPosition.y!
        wallpaperPositionWidth = wallpaper.position.width ?? defaultPosition.width!
        wallpaperPositionHeight = wallpaper.position.height ?? defaultPosition.height!

        // content
        wallpaperType = wallpaper.type
        webUrl = wallpaper.webUrl ?? ""
        videoPath = wallpaper.videoPath ?? ""

        isControlEnabled = wallpaper.isControlEnabled
    }

    private func updateWallpaper() {
        // general
        wallpaper.name = name

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
                let bookmark = try url.bookmarkData(
                        options: .securityScopeAllowOnlyReadAccess,
                        includingResourceValuesForKeys: nil,
                        relativeTo: nil)
                UserDefaults.standard.set(bookmark, forKey: "bookmark-" + wallpaper.id)
            } catch let error as NSError {
                print("Set Bookmark Fails: \(error.description)")
            }
        }

        wallpaper.reload()
        wallpapers.save()
    }
}
