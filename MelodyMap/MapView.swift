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

    var body: some View {
        NavigationView {
            ZStack {
                Map(position: $cameraPosition) {
                    ForEach(pins) { pin in
                        Marker(pin.song.title, coordinate: pin.coordinate)
                            .tint(.blue)
                    }
                }
                .mapStyle(.standard)
                .onMapCameraChange { context in
                    visibleRegion = context.region
                }
                .onTapGesture { location in
                    if isSelectingLocation {
                        if let region = visibleRegion {
                            selectedLocation = region.center
                            showingAddPin = true
                        }
                    }
                }
                .overlay(
                    Group {
                        if isSelectingLocation {
                            Text("Tap to place MelodyPin")
                                .padding()
                                .background(Color.white.opacity(0.8))
                                .cornerRadius(8)
                                .padding(.top, 8)
                        }
                    }
                )

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
        }
    }
}

