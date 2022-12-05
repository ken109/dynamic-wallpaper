//
// Created by Kensuke Kubo on 2022/12/02.
//

import SwiftUI

enum PositionType: String, CaseIterable, Codable {
    case fullscreen
    case center
    case custom
}

struct Position: Codable {
    private (set) var type: PositionType
    private (set) var x: CGFloat?
    private (set) var y: CGFloat?
    private (set) var width: CGFloat?
    private (set) var height: CGFloat?

    // fullscreen or center or custom
    init(_ type: PositionType) {
        self.type = type

        let displaySize = NSScreen.main!.frame.size

        switch type {
        case .fullscreen:
            break
        case .center:
            width = displaySize.width / 3
            height = displaySize.height / 2
        case .custom:
            x = displaySize.width / 5
            y = displaySize.height / 5
            width = displaySize.width / 3
            height = displaySize.height / 2
        }
    }

    // center or custom
    init(_ type: PositionType, width: CGFloat, height: CGFloat) {
        guard type == .center || type == .custom else {
            fatalError("Position type must be center or custom")
        }

        self.type = type
        self.width = width
        self.height = height

        let displaySize = NSScreen.main!.frame.size

        switch type {
        case .fullscreen:
            break
        case .center:
            break
        case .custom:
            x = displaySize.width / 5
            y = displaySize.height / 5
        }
    }

    // custom
    init(_ type: PositionType, x: CGFloat, y: CGFloat, width: CGFloat, height: CGFloat) {
        guard type == .custom else {
            fatalError("Position type must be custom")
        }
        self.type = .custom
        self.x = x
        self.y = y
        self.width = width
        self.height = height
    }

    // from NSRect
    init(rect: NSRect) {
        type = .custom
        x = rect.origin.x
        y = rect.origin.y
        width = rect.size.width
        height = rect.size.height
    }

    func result() -> NSRect {
        switch type {
        case .fullscreen:
            return NSScreen.main!.frame
        case .center:
            let displaySize = NSScreen.main!.frame.size
            let width = width ?? displaySize.width
            let height = height ?? displaySize.height
            let x = (displaySize.width - width) / 2
            let y = (displaySize.height - height) / 2
            return NSRect(x: x, y: y, width: width, height: height)
        case .custom:
            let x = x ?? 0
            let y = y ?? 0
            let width = width ?? 0
            let height = height ?? 0
            return NSRect(x: x, y: y, width: width, height: height)
        }
    }

    // codable

    enum CodingKeys: String, CodingKey {
        case type
        case x
        case y
        case width
        case height
    }

    init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        type = try container.decode(PositionType.self, forKey: .type)
        switch type {
        case .fullscreen:
            break
        case .center:
            width = try container.decode(CGFloat.self, forKey: .width)
            height = try container.decode(CGFloat.self, forKey: .height)
        case .custom:
            x = try container.decode(CGFloat.self, forKey: .x)
            y = try container.decode(CGFloat.self, forKey: .y)
            width = try container.decode(CGFloat.self, forKey: .width)
            height = try container.decode(CGFloat.self, forKey: .height)
        }
    }

    func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
        try container.encode(type, forKey: .type)
        switch type {
        case .fullscreen:
            break
        case .center:
            try container.encode(width, forKey: .width)
            try container.encode(height, forKey: .height)
        case .custom:
            try container.encode(x, forKey: .x)
            try container.encode(y, forKey: .y)
            try container.encode(width, forKey: .width)
            try container.encode(height, forKey: .height)
        }
    }
}
