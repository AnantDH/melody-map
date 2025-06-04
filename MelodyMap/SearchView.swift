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

                        if let previewURL = song.preview, let url = URL(string: previewURL) {
                            Button(action: {
                                playPreview(url: url)
                            }) {
                                Image(systemName: "play.circle.fill")
                                    .font(.title2)
                                    .foregroundColor(.blue)
                            }
                        }
                    }
                    .padding(.vertical, 4)
                }

                Spacer()
            }
            .navigationTitle("Search")
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
                    print("❌ Decode error: \(error)")
                }
            } else {
                print("❌ Network error: \(error?.localizedDescription ?? "Unknown error")")
            }
        }.resume()
    }

    func playPreview(url: URL) {
        // Use AVPlayer or system browser for now
        UIApplication.shared.open(url)
    }
}

