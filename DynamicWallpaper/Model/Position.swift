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
            x = 0
            y = 0
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
    
    func getWidth() -> CGFloat {
        switch type {
        case .fullscreen:
            return NSScreen.main!.frame.width
        case .center:
            let displaySize = NSScreen.main!.frame.size
            return width ?? displaySize.width
        case .custom:
            return width ?? 0
        }
    }
    
    func getHeight() -> CGFloat {
        switch type {
        case .fullscreen:
            return NSScreen.main!.frame.height
        case .center:
            let displaySize = NSScreen.main!.frame.size
            return height ?? displaySize.height
        case .custom:
            return height ?? 0
        }
    }
    
    func getX() -> CGFloat {
        let displaySize = NSScreen.main!.frame.size
        let width = width ?? displaySize.width
        
        switch type {
        case .fullscreen:
            return 0 + width / 2
        case .center:
            return 0
        case .custom:
            return x ?? 0
        }
    }
    
    func getY() -> CGFloat {
        let displaySize = NSScreen.main!.frame.size
        let height = height ?? displaySize.height
        
        switch type {
        case .fullscreen:
            return 0 + height / 2
        case .center:
            return 0
        case .custom:
            return y ?? 0
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
