import Foundation

class UserDefaultsService {
    static let shared = UserDefaultsService()
    private let defaults = UserDefaults.standard
    
    private let userNameKey = "userName"
    
    private init() {}
    
    var userName: String {
        get {
            defaults.string(forKey: userNameKey) ?? ""
        }
        set {
            defaults.set(newValue, forKey: userNameKey)
        }
    }
} 