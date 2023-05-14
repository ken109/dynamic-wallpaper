//
// Created by Kensuke Kubo on 2022/12/07.
//

import SwiftUI

struct CommandView: View {
    @State var command: String
    @State var out: String = ""
    
    init(command: String) {
        self.command = command
    }
    
    var body: some View {
        VStack {
            Text(out)
                .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .topLeading)
        }
        .onAppear {
            Task {
                run()
                
                // run every 1 seconds
                Timer.scheduledTimer(withTimeInterval: 1, repeats: true) { _ in
                    run()
                }
            }
        }
    }
    
    func run() {
        let task = Process()
        let pipe: Pipe = Pipe()
        
        task.standardOutput = pipe
        task.launchPath = "/usr/bin/env"
        task.arguments = ["zsh", "-c", command]
        
        do {
            try task.run()
        } catch {
            print("error: \(error)")
        }
        
        let data = pipe.fileHandleForReading.readDataToEndOfFile()
        out = String(data: data, encoding: .utf8)!
    }
}
