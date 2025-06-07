import SwiftUI

struct PlaylistDetailView: View {
    let playlist: Playlist
    @StateObject private var audioPlayer = AudioPlayerManager()
    
    var body: some View {
        VStack(spacing: 0) {
            List {
                ForEach(playlist.songs) { song in
                    HStack {
                        AsyncImage(url: URL(string: song.album.cover_medium)) { image in
                            image.resizable()
                                .aspectRatio(contentMode: .fill)
                        } placeholder: {
                            Color.gray
                        }
                        .frame(width: 50, height: 50)
                        .cornerRadius(6)
                        
                        VStack(alignment: .leading) {
                            Text(song.title)
                                .fontWeight(.semibold)
                            Text(song.artist.name)
                                .foregroundColor(.gray)
                                .font(.subheadline)
                        }
                        
                        Spacer()
                        
                        if song.preview != nil {
                            Button(action: {
                                audioPlayer.playPause(song: song)
                            }) {
                                Image(systemName: getPlayButtonIcon(for: song))
                                    .font(.title2)
                                    .foregroundColor(.blue)
                            }
                        }
                    }
                    .padding(.vertical, 4)
                }
            }
            .listStyle(PlainListStyle())
            
            // Now Playing bar
            if let currentSong = audioPlayer.currentSong {
                VStack {
                    Divider()
                    HStack {
                        Text("Now Playing:")
                            .font(.caption)
                            .foregroundColor(.gray)
                        Spacer()
                    }
                    .padding(.horizontal)
                    
                    HStack {
                        AsyncImage(url: URL(string: currentSong.album.cover_medium)) { image in
                            image.resizable()
                                .aspectRatio(contentMode: .fill)
                        } placeholder: {
                            Color.gray
                        }
                        .frame(width: 40, height: 40)
                        .cornerRadius(4)
                        
                        VStack(alignment: .leading) {
                            Text(currentSong.title)
                                .font(.subheadline)
                                .fontWeight(.medium)
                            Text(currentSong.artist.name)
                                .font(.caption)
                                .foregroundColor(.gray)
                        }
                        
                        Spacer()
                        
                        Button(action: {
                            audioPlayer.playPause(song: currentSong)
                        }) {
                            Image(systemName: audioPlayer.isPlaying ? "pause.circle.fill" : "play.circle.fill")
                                .font(.title3)
                                .foregroundColor(.blue)
                        }
                        
                        Button(action: {
                            audioPlayer.stop()
                        }) {
                            Image(systemName: "stop.circle.fill")
                                .font(.title3)
                                .foregroundColor(.red)
                        }
                    }
                    .padding(.horizontal)
                    .padding(.bottom, 8)
                }
                .background(Color(.systemGray6))
            }
        }
        .navigationTitle(playlist.name)
        .navigationBarTitleDisplayMode(.inline)
    }
    
    func getPlayButtonIcon(for song: DeezerSong) -> String {
        if audioPlayer.currentSong?.id == song.id && audioPlayer.isPlaying {
            return "pause.circle.fill"
        } else {
            return "play.circle.fill"
        }
    }
} 