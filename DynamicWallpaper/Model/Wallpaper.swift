//
// Created by Kensuke Kubo on 2022/12/02.
//

import SwiftUI

enum WallpaperType: String, CaseIterable, Codable {
    case off
    case web
    case video
}

class Wallpaper: Codable, Identifiable, Hashable {
    private var view: WallpaperView?

    let id: String

    var type: WallpaperType
    var position: Position
    var name: String

    // web
    var webUrl: String? = nil

    // video
    var videoPath: String? = nil

    private init(name: String, type: WallpaperType, position: Position,
                 webUrl: String?,
                 videoPath: String?
    ) {
        id = UUID().uuidString
        self.name = name
        self.type = type
        self.position = position
        self.webUrl = webUrl
        self.videoPath = videoPath

        view = WallpaperView(wallpaper: self)
    }

    // none type
    convenience init(_ name: String, position: Position) {
        self.init(name: name, type: .off, position: position, webUrl: nil, videoPath: nil)
    }

    // web type
    convenience init(_ name: String, webUrl: String, position: Position) {
        self.init(name: name, type: .web, position: position, webUrl: webUrl, videoPath: nil)
    }

    // video type
    convenience init(_ name: String, videoPath: String, position: Position) {
        self.init(name: name, type: .video, position: position, webUrl: nil, videoPath: videoPath)
    }

    // identifiable
    static func ==(lhs: Wallpaper, rhs: Wallpaper) -> Bool {
        lhs.id == rhs.id
    }

    // hashable
    func hash(into hasher: inout Hasher) {
        hasher.combine(id)
    }

    // codable
    enum CodingKeys: String, CodingKey {
        case id
        case name
        case type
        case position
        case webUrl
        case videoPath
    }

    required init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        id = try container.decode(String.self, forKey: .id)
        name = try container.decode(String.self, forKey: .name)
        type = try container.decode(WallpaperType.self, forKey: .type)
        position = try container.decode(Position.self, forKey: .position)
        webUrl = try? container.decode(String.self, forKey: .webUrl)
        videoPath = try? container.decode(String.self, forKey: .videoPath)

        if type == .video {
            if let bookmarkData = UserDefaults.standard.object(forKey: "bookmark-" + id) as? Data {
                do {
                    var bookmarkIsStale = false
                    let url = try URL.init(resolvingBookmarkData: bookmarkData as Data, options: .withSecurityScope, relativeTo: nil, bookmarkDataIsStale: &bookmarkIsStale)
                    let _ = url.startAccessingSecurityScopedResource()
                } catch let error as NSError {
                    print("Bookmark Access Fails: \(error.description)")
                }
            }
        }

        view = WallpaperView(wallpaper: self)
    }

    func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
        try container.encode(id, forKey: .id)
        try container.encode(name, forKey: .name)
        try container.encode(type, forKey: .type)
        try container.encode(position, forKey: .position)
        try container.encode(webUrl, forKey: .webUrl)
        try container.encode(videoPath, forKey: .videoPath)
    }

    // misc
    func reload() {
        view?.update()
    }

    func savePosition() {
        if let view = view {
            let frame = view.innerView.frame
            if let contentFrame = view.innerView.contentView?.frame {
                position = Position(rect: NSRect(x: frame.minX, y: frame.minY, width: contentFrame.width, height: contentFrame.height))
            }
        }
    }

    // control
    private var _isControlEnabled: Bool = false
    var isControlEnabled: Bool {
        get {
            _isControlEnabled
        }
        set {
            _isControlEnabled = newValue
            if newValue {
                if let onEnableControl {
                    onEnableControl()
                }
            } else {
                if let onDisableControl {
                    onDisableControl()
                }
            }
        }
    }

    private var onEnableControl: (() -> Void)?
    private var onDisableControl: (() -> Void)?

    func setOnEnableControl(callback: @escaping () -> Void) {
        onEnableControl = callback
    }

    func setOnDisableControl(callback: @escaping () -> Void) {
        onDisableControl = callback
    }

    // close
    func close() {
        view?.innerView.close()
    }
}
