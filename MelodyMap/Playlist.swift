import Foundation

struct Playlist: Identifiable, Codable {
    var id: UUID = UUID()
    var name: String
    var songs: [DeezerSong]
    var type: PlaylistType
    
    enum PlaylistType: String, Codable {
        case topHits = "Today's Top Hits"
        case throwbacks = "Throwbacks"
        case topRap = "Top Rap"
        case custom = "Custom"
    }
}

class PlaylistStorageService {
    static let shared = PlaylistStorageService()
    
    private let filename = "playlists.json"
    
    private var fileURL: URL {
        let docsDir = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first!
        return docsDir.appendingPathComponent(filename)
    }
    
    func savePlaylists(_ playlists: [Playlist]) {
        do {
            let data = try JSONEncoder().encode(playlists)
            try data.write(to: fileURL, options: [.atomic, .completeFileProtection])
        } catch {
            print("Failed to save playlists: \(error)")
        }
    }
    
    func loadPlaylists() -> [Playlist] {
        do {
            let data = try Data(contentsOf: fileURL)
            let playlists = try JSONDecoder().decode([Playlist].self, from: data)
            return playlists
        } catch {
            print("No saved playlists found or failed to load: \(error)")
            return []
        }
    }
} 