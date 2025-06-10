//
//  MapView.swift
//  MelodyMap
//
//  Created by Anant Dhokia on 6/3/25.
//

import SwiftUI
import MapKit

struct MapView: View {
    @State private var cameraPosition: MapCameraPosition = .region(MKCoordinateRegion(
        center: CLLocationCoordinate2D(latitude: 47.6062, longitude: -122.3321),
        span: MKCoordinateSpan(latitudeDelta: 0.05, longitudeDelta: 0.05)
    ))

    @State private var pins: [MelodyPin] = PinStorageService.shared.loadPins()
    @State private var showingAddPin = false
    @State private var selectedLocation: CLLocationCoordinate2D?
    @State private var isSelectingLocation = false
    @State private var visibleRegion: MKCoordinateRegion?
    @StateObject private var audioPlayer = AudioPlayerManager()
    @State private var selectedPin: MelodyPin?

    var body: some View {
        NavigationView {
            ZStack {
                MapReader { proxy in
                    Map(position: $cameraPosition) {
                        ForEach(pins) { pin in
                            Annotation(pin.song.title, coordinate: pin.coordinate) {
                                VStack {
                                    Image(systemName: audioPlayer.currentSong?.id == pin.song.id && audioPlayer.isPlaying ? "pause.circle.fill" : "play.circle.fill")
                                        .font(.title2)
                                        .foregroundColor(.white)
                                        .background(Circle().fill(audioPlayer.currentSong?.id == pin.song.id ? Color.green : Color.blue))
                                        .scaleEffect(audioPlayer.currentSong?.id == pin.song.id && audioPlayer.isPlaying ? 1.2 : 1.0)
                                        .animation(.easeInOut(duration: 0.2), value: audioPlayer.currentSong?.id == pin.song.id && audioPlayer.isPlaying)
                                }
                                .contentShape(Rectangle()) // larger tap area for taps outside the icon
                                .onTapGesture {
                                    selectedPin = pin
                                }
                            }
                        }
                    }
                    .mapStyle(.standard)
                    .onTapGesture(perform: { screenPoint in
                        guard isSelectingLocation else { return }
                        let coordinate = proxy.convert(screenPoint, from: .local)
                        selectedLocation = coordinate
                        showingAddPin = true
                        isSelectingLocation = false
                    })
                    .onMapCameraChange { context in
                        visibleRegion = context.region
                    }
                    .overlay(
                        Group {
                            if isSelectingLocation {
                                Text("Tap to place pin")
                                    .padding()
                                    .background(Color.white.opacity(0.8))
                                    .cornerRadius(8)
                                    .padding(.top, 8)
                            }
                        }
                    )
                }

                VStack {
                    Spacer()
                    HStack {
                        Spacer()
                        Button(action: {
                            isSelectingLocation = true
                        }) {
                            Image(systemName: "plus")
                                .font(.title2)
                                .padding()
                                .background(Color.blue)
                                .foregroundColor(.white)
                                .clipShape(Circle())
                                .shadow(radius: 4)
                        }
                        .padding()
                    }
                }
            }
            .navigationTitle("Map")
            .sheet(isPresented: $showingAddPin) {
                if let coordinate = selectedLocation {
                    AddPinView(coordinate: coordinate) { newPin in
                        pins.append(newPin)
                        PinStorageService.shared.savePins(pins)
                        showingAddPin = false
                        isSelectingLocation = false
                    }
                }
            }
            .sheet(item: $selectedPin) { pin in
                SongDetailsView(pin: pin, audioPlayer: audioPlayer)
            }
        }
    }
}

struct SongDetailsView: View {
    let pin: MelodyPin
    @ObservedObject var audioPlayer: AudioPlayerManager
    @Environment(\.dismiss) private var dismiss
    
    var body: some View {
        NavigationView {
            VStack(spacing: 20) {
                // Album cover
                AsyncImage(url: URL(string: pin.song.album.cover_medium)) { image in
                    image
                        .resizable()
                        .aspectRatio(contentMode: .fit)
                } placeholder: {
                    Rectangle()
                        .fill(Color.gray.opacity(0.3))
                        .overlay(
                            Image(systemName: "music.note")
                                .font(.system(size: 40))
                                .foregroundColor(.gray)
                        )
                }
                .frame(width: 200, height: 200)
                .cornerRadius(12)
                .shadow(radius: 4)
                
                // Song info
                VStack(spacing: 8) {
                    Text(pin.song.title)
                        .font(.title2)
                        .fontWeight(.bold)
                        .multilineTextAlignment(.center)
                    
                    Text(pin.song.artist.name)
                        .font(.title3)
                        .foregroundColor(.secondary)
                }
                
                // Note if exists
                if let note = pin.note, !note.isEmpty {
                    Text("Note: \(note)")
                        .font(.body)
                        .padding()
                        .background(Color.gray.opacity(0.1))
                        .cornerRadius(8)
                }
                
                // Play button (disabled if no preview available)
                if let preview = pin.song.preview, !preview.isEmpty {
                    Button(action: {
                        audioPlayer.playPause(song: pin.song)
                    }) {
                        HStack {
                            Image(systemName: audioPlayer.currentSong?.id == pin.song.id && audioPlayer.isPlaying ? "pause.fill" : "play.fill")
                            Text(audioPlayer.currentSong?.id == pin.song.id && audioPlayer.isPlaying ? "Pause" : "Play Preview")
                        }
                        .font(.title3)
                        .foregroundColor(.white)
                        .padding()
                        .background(Color.blue)
                        .cornerRadius(10)
                    }
                } else {
                    Text("Preview unavailable for this track")
                        .font(.subheadline)
                        .foregroundColor(.secondary)
                        .padding(.top, 8)
                }
                
                Spacer()
            }
            .padding()
            .navigationTitle("Song Details")
            .navigationBarTitleDisplayMode(.inline)
            .navigationBarBackButtonHidden(true)
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    Button("Done") {
                        dismiss()
                    }
                }
            }
        }
    }
}

