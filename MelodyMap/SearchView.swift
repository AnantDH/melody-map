//
//  SearchView.swift
//  MelodyMap
//
//  Created by Anant Dhokia on 6/3/25.
//

import SwiftUI

struct SearchView: View {
    @State private var query = ""
    @State private var results: [DeezerSong] = []
    @State private var isLoading = false
    @StateObject private var audioPlayer = AudioPlayerManager()

    var body: some View {
        NavigationView {
            VStack {
                HStack {
                    TextField("Search songs...", text: $query)
                        .textFieldStyle(RoundedBorderTextFieldStyle())
                        .padding(.horizontal)
                    Button("Go") {
                        searchDeezer()
                    }
                    .padding(.trailing, 20)
                }
                .padding(.top)

                if isLoading {
                    ProgressView("Searching...")
                        .padding()
                }

                List(results) { song in
                    HStack {
                        AsyncImage(url: URL(string: song.album.cover_medium)) { image in
                            image.resizable()
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
            .navigationTitle("Search")
        }
    }
    
    func getPlayButtonIcon(for song: DeezerSong) -> String {
        // If this song is currently playing, show pause icon
        if audioPlayer.currentSong?.id == song.id && audioPlayer.isPlaying {
            return "pause.circle.fill"
        } else {
            return "play.circle.fill"
        }
    }

    func searchDeezer() {
        guard !query.isEmpty else { return }
        isLoading = true
        results = []

        let formattedQuery = query.addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed) ?? ""
        let urlString = "https://api.deezer.com/search?q=\(formattedQuery)"

        guard let url = URL(string: urlString) else { return }

        URLSession.shared.dataTask(with: url) { data, response, error in
            DispatchQueue.main.async {
                isLoading = false
            }

            if let data = data {
                do {
                    let decoded = try JSONDecoder().decode(DeezerSearchResponse.self, from: data)
                    DispatchQueue.main.async {
                        results = decoded.data
                    }
                } catch {
                    print("Decode error: \(error)")
                }
            } else {
                print("Network error: \(error?.localizedDescription ?? "Unknown error")")
            }
        }.resume()
    }
}

