//
// Created by Kensuke Kubo on 2022/12/02.
//

import SwiftUI

enum WallpaperType: String, CaseIterable {
    case web
}

class Wallpaper {
    let identifier: String = UUID().uuidString

    let type: WallpaperType
    let contentRect: NSRect

    var view: WallpaperView?

    private var _url: String?
    var url: String? {
        get {
            _url
        }
        set {
            _url = newValue
            view?.update()
        }
    }

    private init(type: WallpaperType, contentRect: NSRect,
                 url: String?) {
        self.type = type
        self.contentRect = contentRect
        self.url = url

        view = WallpaperView(wallpaper: self)
    }

    convenience init(url: String, contentRect: NSRect) {
        self.init(type: .web, contentRect: contentRect, url: url)
    }

    // web control
    private var innerIsControlEnabled: Bool = false

    var isControlEnabled: Bool {
        get {
            innerIsControlEnabled
        }
        set {
            innerIsControlEnabled = newValue
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
