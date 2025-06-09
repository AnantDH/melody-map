import SwiftUI

struct AddPlaylistView: View {
    @Environment(\.dismiss) private var dismiss
    @State private var playlistName = ""
    @State private var searchQuery = ""
    @State private var searchResults: [DeezerSong] = []
    @State private var selectedSongs: [DeezerSong] = []
    @State private var isLoading = false
    
    var onSave: (Playlist) -> Void
    
    var body: some View {
        NavigationView {
            VStack {
                TextField("Playlist Name", text: $playlistName)
                    .textFieldStyle(RoundedBorderTextFieldStyle())
                    .padding()
                
                TextField("Search songs...", text: $searchQuery)
                    .textFieldStyle(RoundedBorderTextFieldStyle())
                    .padding(.horizontal)
                    .onChange(of: searchQuery) { oldValue, newValue in
                        searchDeezer()
                    }
                
                if isLoading {
                    ProgressView("Searching...")
                        .padding()
                }
                
                List {
                    Section(header: Text("Search Results")) {
                        ForEach(searchResults) { song in
                            HStack {
                                AsyncImage(url: URL(string: song.album.cover_medium)) { image in
                                    image.resizable()
                                } placeholder: {
                                    Color.gray
                                }
                                .frame(width: 40, height: 40)
                                .cornerRadius(4)
                                
                                VStack(alignment: .leading) {
                                    Text(song.title)
                                        .fontWeight(.semibold)
                                    Text(song.artist.name)
                                        .foregroundColor(.gray)
                                        .font(.subheadline)
                                }
                                
                                Spacer()
                                
                                if selectedSongs.contains(where: { $0.id == song.id }) {
                                    Image(systemName: "checkmark.circle.fill")
                                        .foregroundColor(.blue)
                                }
                            }
                            .contentShape(Rectangle())
                            .onTapGesture {
                                if let index = selectedSongs.firstIndex(where: { $0.id == song.id }) {
                                    selectedSongs.remove(at: index)
                                } else {
                                    selectedSongs.append(song)
                                }
                            }
                        }
                    }
                    
                    Section(header: Text("Selected Songs")) {
                        ForEach(selectedSongs) { song in
                            HStack {
                                AsyncImage(url: URL(string: song.album.cover_medium)) { image in
                                    image.resizable()
                                } placeholder: {
                                    Color.gray
                                }
                                .frame(width: 40, height: 40)
                                .cornerRadius(4)
                                
                                VStack(alignment: .leading) {
                                    Text(song.title)
                                        .fontWeight(.semibold)
                                    Text(song.artist.name)
                                        .foregroundColor(.gray)
                                        .font(.subheadline)
                                }
                            }
                        }
                        .onDelete { indexSet in
                            selectedSongs.remove(atOffsets: indexSet)
                        }
                    }
                }
            }
            .navigationTitle("New Playlist")
            .navigationBarItems(
                leading: Button("Cancel") {
                    dismiss()
                },
                trailing: Button("Save") {
                    let newPlaylist = Playlist(
                        name: playlistName,
                        songs: selectedSongs,
                        type: .custom
                    )
                    onSave(newPlaylist)
                    dismiss()
                }
                .disabled(playlistName.isEmpty || selectedSongs.isEmpty)
            )
        }
    }
    
    func searchDeezer() {
        guard !searchQuery.isEmpty else {
            searchResults = []
            return
        }
        
        isLoading = true
        
        let formattedQuery = searchQuery.addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed) ?? ""
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
                        searchResults = decoded.data
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