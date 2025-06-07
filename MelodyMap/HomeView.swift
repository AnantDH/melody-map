//
//  HomeView.swift
//  MelodyMap
//
//  Created by Anant Dhokia on 6/3/25.
//

import SwiftUI

struct HomeView: View {
    @State private var playlists: [Playlist] = []
    @State private var showingAddPlaylist = false
    @State private var isLoading = false
    @State private var selectedPlaylist: Playlist?
    @State private var showingPlaylistDetail = false
    
    var body: some View {
        NavigationView {
            ScrollView {
                LazyVGrid(columns: [
                    GridItem(.flexible(), spacing: 16),
                    GridItem(.flexible(), spacing: 16)
                ], spacing: 16) {
                    // Default playlists
                    PlaylistBox(
                        title: "Today's Top Hits",
                        type: .topHits,
                        onTap: { loadTopHits() }
                    )
                    
                    PlaylistBox(
                        title: "Throwbacks",
                        type: .throwbacks,
                        onTap: { loadThrowbacks() }
                    )
                    
                    PlaylistBox(
                        title: "Top Rap",
                        type: .topRap,
                        onTap: { loadTopRap() }
                    )
                    
                    // Add Playlist button
                    PlaylistBox(
                        title: "Add Playlist",
                        type: .custom,
                        onTap: { showingAddPlaylist = true }
                    )
                    
                    // Custom playlists
                    ForEach(playlists.filter { $0.type == .custom }) { playlist in
                        PlaylistBox(
                            title: playlist.name,
                            type: playlist.type,
                            onTap: {
                                selectedPlaylist = playlist
                                showingPlaylistDetail = true
                            }
                        )
                    }
                }
                .padding()
            }
            .navigationTitle("Playlists")
            .sheet(isPresented: $showingAddPlaylist) {
                AddPlaylistView { newPlaylist in
                    playlists.append(newPlaylist)
                    PlaylistStorageService.shared.savePlaylists(playlists)
                }
            }
            .sheet(isPresented: $showingPlaylistDetail) {
                if let playlist = selectedPlaylist {
                    NavigationView {
                        PlaylistDetailView(playlist: playlist)
                            .navigationBarItems(trailing: Button("Done") {
                                showingPlaylistDetail = false
                            })
                    }
                }
            }
            .onAppear {
                loadPlaylists()
            }
            .overlay {
                if isLoading {
                    ProgressView("Loading...")
                        .padding()
                        .background(Color(.systemBackground))
                        .cornerRadius(10)
                        .shadow(radius: 10)
                }
            }
        }
    }
    
    private func loadPlaylists() {
        playlists = PlaylistStorageService.shared.loadPlaylists()
    }
    
    private func loadTopHits() {
        isLoading = true
        let urlString = "https://api.deezer.com/chart/0/tracks?limit=10"
        loadPlaylistFromDeezer(urlString: urlString, type: .topHits, title: "Today's Top Hits")
    }
    
    private func loadThrowbacks() {
        isLoading = true
        let urlString = "https://api.deezer.com/chart/0/tracks?limit=10&index=20" // Get some older hits
        loadPlaylistFromDeezer(urlString: urlString, type: .throwbacks, title: "Throwbacks")
    }
    
    private func loadTopRap() {
        isLoading = true
        let urlString = "https://api.deezer.com/search?q=genre:\"rap\"&limit=10"
        loadPlaylistFromDeezer(urlString: urlString, type: .topRap, title: "Top Rap")
    }
    
    private func loadPlaylistFromDeezer(urlString: String, type: Playlist.PlaylistType, title: String) {
        guard let url = URL(string: urlString) else {
            isLoading = false
            return
        }
        
        URLSession.shared.dataTask(with: url) { data, response, error in
            DispatchQueue.main.async {
                isLoading = false
            }
            
            if let data = data {
                do {
                    let decoded = try JSONDecoder().decode(DeezerSearchResponse.self, from: data)
                    DispatchQueue.main.async {
                        let playlist = Playlist(
                            name: title,
                            songs: decoded.data,
                            type: type
                        )
                        selectedPlaylist = playlist
                        showingPlaylistDetail = true
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

struct PlaylistBox: View {
    let title: String
    let type: Playlist.PlaylistType
    let onTap: (() -> Void)?
    
    var body: some View {
        Button(action: { onTap?() }) {
            VStack {
                if type == .custom && title == "Add Playlist" {
                    Image(systemName: "plus.circle.fill")
                        .font(.system(size: 40))
                } else {
                    Image(systemName: getIcon(for: type))
                        .font(.system(size: 40))
                }
                Text(title)
                    .font(.headline)
                    .multilineTextAlignment(.center)
            }
            .frame(maxWidth: .infinity)
            .frame(height: 160)
            .background(Color(.systemGray6))
            .cornerRadius(12)
        }
    }
    
    private func getIcon(for type: Playlist.PlaylistType) -> String {
        switch type {
        case .topHits:
            return "music.note.list"
        case .throwbacks:
            return "clock.arrow.circlepath"
        case .topRap:
            return "music.mic"
        case .custom:
            return "music.note"
        }
    }
}


