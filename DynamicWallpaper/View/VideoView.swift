//
// Created by Kensuke Kubo on 2022/12/06.
//

import SwiftUI
import AVKit

struct VideoView: View {
    @State private var player: AVPlayer

    @State private var aspectRatio: CGFloat = 16 / 9

    init(path: String) {
        let url = URL(fileURLWithPath: path)

        player = AVPlayer(url: url)
        player.isMuted = true

        // Loop video
        NotificationCenter.default.addObserver(forName: .AVPlayerItemDidPlayToEndTime, object: player.currentItem, queue: .main) { [self] _ in
            player.seek(to: .zero)
            player.play()
        }

        // Play video
        player.play()
    }

    var body: some View {
        GeometryReader { proxy in
            VStack {
                VideoPlayer(player: player)
                    .onAppear {
                        Task { [self] in
                            let track = try await player.currentItem!.asset.load(.tracks).first!
                            let size = try await track.load(.naturalSize).applying(try await track.load(.preferredTransform))
                            aspectRatio = abs(size.width / size.height)
                        }
                    }
                    .onDisappear {
                        NotificationCenter.default.removeObserver(self,
                                name: .AVPlayerItemDidPlayToEndTime,
                                object: nil)
                    }
                    .frame(width: proxy.size.height * aspectRatio, height: proxy.size.height)
                    .position(x: proxy.size.width / 2, y: proxy.size.height / 2)
            }
        }
    }
}
