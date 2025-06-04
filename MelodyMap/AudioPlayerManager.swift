import Foundation
import AVFoundation

class AudioPlayerManager: ObservableObject {
    private var player: AVPlayer?
    @Published var isPlaying = false
    @Published var currentSong: DeezerSong?
    
    init() {
        setupAudioSession()
    }
    
    private func setupAudioSession() {
        do {
            try AVAudioSession.sharedInstance().setCategory(.playback, mode: .default)
            try AVAudioSession.sharedInstance().setActive(true)
        } catch {
            print("Failed to set up audio session: \(error)")
        }
    }
    
    func playPause(song: DeezerSong) {
        // If the same song is playing, just pause/resume
        if currentSong?.id == song.id {
            if isPlaying {
                pause()
            } else {
                resume()
            }
            return
        }
        
        // Play a new song
        playSong(song)
    }
    
    private func playSong(_ song: DeezerSong) {
        guard let previewURL = song.preview, let url = URL(string: previewURL) else {
            print("No preview URL available")
            return
        }
        
        // Stop current player if any
        player?.pause()
        
        // Create new player
        player = AVPlayer(url: url)
        currentSong = song
        
        // Play the song
        player?.play()
        isPlaying = true
        
        print("Playing: \(song.title) by \(song.artist.name)")
    }
    
    private func pause() {
        player?.pause()
        isPlaying = false
    }
    
    private func resume() {
        player?.play()
        isPlaying = true
    }
    
    func stop() {
        player?.pause()
        player = nil
        isPlaying = false
        currentSong = nil
    }
} 