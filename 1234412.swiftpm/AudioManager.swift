import SwiftUI
import AVFoundation

@MainActor
final class AudioManager: ObservableObject, @unchecked Sendable {
    static let shared = AudioManager()
    private var audioPlayer: AVAudioPlayer?
    @Published private(set) var isPlaying = true  // 默认为 true
    
    private init() {
        prepareAudio()
        play()  // 初始化时自动播放
    }
    
    private func prepareAudio() {
        if let audioURL = Bundle.main.url(forResource: "Planet", withExtension: "mp3") {
            do {
                audioPlayer = try AVAudioPlayer(contentsOf: audioURL)
                audioPlayer?.numberOfLoops = -1 // 无限循环
                audioPlayer?.prepareToPlay()
                print("找到音频文件，准备播放")
            } catch {
                print("创建音频播放器失败: \(error)")
            }
        } else {
            print("找不到音频文件 Planet.mp3")
        }
    }
    
    func play() {
        audioPlayer?.play()
        isPlaying = true
        print("开始播放背景音乐")
    }
    
    func stop() {
        audioPlayer?.stop()
        isPlaying = false
        print("停止播放背景音乐")
    }
    
    func toggleBackgroundMusic() {
        if isPlaying {
            stop()
        } else {
            play()
        }
    }
}

struct AudioPlayerView: View {
    @StateObject private var audioManager = AudioManager.shared
    
    var body: some View {
        Button(action: {
            audioManager.toggleBackgroundMusic()
        }) {
            Image(systemName: audioManager.isPlaying ? "speaker.wave.2.fill" : "speaker.slash.fill")
                .font(.system(size: 24))
                .foregroundColor(.white)
                .padding(10)
                .background(Color(red: 0.2, green: 0.2, blue: 0.3).opacity(0.6))
                .clipShape(Circle())
        }
    }
} 