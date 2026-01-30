import Foundation
import AVFoundation

/// Handles Athan audio playback.
@MainActor
final class AthanPlayer: ObservableObject {
    private var player: AVAudioPlayer?

    /// Plays the Athan audio if available.
    func play() {
        configureAudioSessionIfNeeded()
        if player == nil {
            player = loadPlayer()
        }
        player?.currentTime = 0
        player?.play()
    }

    /// Stops playback if active.
    func stop() {
        player?.stop()
    }

    private func loadPlayer() -> AVAudioPlayer? {
        guard let url = Bundle.main.url(forResource: "athan_masjid_an_nabawi", withExtension: "mp3") else {
            #if DEBUG
            print("[AthanPlayer] Audio file not found in bundle.")
            #endif
            return nil
        }
        do {
            let audioPlayer = try AVAudioPlayer(contentsOf: url)
            audioPlayer.prepareToPlay()
            return audioPlayer
        } catch {
            #if DEBUG
            print("[AthanPlayer] Failed to load audio: \(error)")
            #endif
            return nil
        }
    }

    private func configureAudioSessionIfNeeded() {
        #if os(tvOS)
        let session = AVAudioSession.sharedInstance()
        do {
            try session.setCategory(.playback, mode: .default)
            try session.setActive(true)
        } catch {
            #if DEBUG
            print("[AthanPlayer] Failed to configure audio session: \(error)")
            #endif
        }
        #endif
    }
}
