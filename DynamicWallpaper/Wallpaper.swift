//
// Created by Kensuke Kubo on 2022/12/02.
//

import SwiftUI

enum WallpaperType: String, CaseIterable, Codable {
    case off
    case web
}

class Wallpaper: Codable, Identifiable, Hashable {
    var view: WallpaperView?

    let id: String

    var type: WallpaperType
    var position: Position
    var name: String
    var url: String?

    private init(name: String, type: WallpaperType, position: Position,
                 url: String?) {
        id = UUID().uuidString
        self.name = name
        self.type = type
        self.position = position
        self.url = url

        view = WallpaperView(wallpaper: self)
    }

    // none type
    convenience init(_ name: String, position: Position) {
        self.init(name: name, type: .off, position: position, url: nil)
    }

    // web type
    convenience init(_ name: String, url: String, position: Position) {
        self.init(name: name, type: .web, position: position, url: url)
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
        case url
    }

    required init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        id = try container.decode(String.self, forKey: .id)
        name = try container.decode(String.self, forKey: .name)
        type = try container.decode(WallpaperType.self, forKey: .type)
        position = try container.decode(Position.self, forKey: .position)
        url = try? container.decode(String.self, forKey: .url)

        view = WallpaperView(wallpaper: self)
    }

    func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
        try container.encode(id, forKey: .id)
        try container.encode(name, forKey: .name)
        try container.encode(type, forKey: .type)
        try container.encode(position, forKey: .position)
        try container.encode(url, forKey: .url)
    }

    // misc
    func reload() {
        view?.update()
    }

    func savePosition() {
        if let view = view {
            position = Position(rect: view.innerView.frame)
        }
    }

    // web control
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
}
