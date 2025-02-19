import SwiftUI
import Combine

@MainActor
final class PlanetProgressViewModel: ObservableObject {
    // MARK: - UserDefaults Keys
    private enum UserDefaultsKeys {
        static let unlockedPlanets = "unlockedPlanets"
        static let completedPlanets = "completedPlanets"
    }
    
    // MARK: - Published Properties
    @Published private(set) var unlockedPlanets: Set<PlanetType>
    @Published private(set) var completedPlanets: Set<PlanetType>
    
    // MARK: - Initialization
    init() {
        // 从 UserDefaults 读取已保存的状态
        if let unlockedData = UserDefaults.standard.data(forKey: UserDefaultsKeys.unlockedPlanets),
           let completedData = UserDefaults.standard.data(forKey: UserDefaultsKeys.completedPlanets),
           let unlockedPlanets = try? JSONDecoder().decode(Set<PlanetType>.self, from: unlockedData),
           let completedPlanets = try? JSONDecoder().decode(Set<PlanetType>.self, from: completedData) {
            self.unlockedPlanets = unlockedPlanets
            self.completedPlanets = completedPlanets
            // 确保 Venus 始终解锁
            self.unlockedPlanets.insert(.venus)
        } else {
            // 首次启动时的默认状态
            self.unlockedPlanets = [.venus]
            self.completedPlanets = []
            saveState()
        }
    }
    
    // MARK: - Private Methods
    
    /// 保存当前状态到 UserDefaults
    private func saveState() {
        if let unlockedData = try? JSONEncoder().encode(unlockedPlanets) {
            UserDefaults.standard.set(unlockedData, forKey: UserDefaultsKeys.unlockedPlanets)
        }
        if let completedData = try? JSONEncoder().encode(completedPlanets) {
            UserDefaults.standard.set(completedData, forKey: UserDefaultsKeys.completedPlanets)
        }
    }
    
    // MARK: - Planet Type Definition
    enum PlanetType: Int, Codable, CaseIterable {
        case venus = 1
        case artistic = 2
        case oceanus = 3
        case andromeda = 4
        
        var nextPlanet: PlanetType? {
            PlanetType(rawValue: self.rawValue + 1)
        }
        
        var name: String {
            switch self {
            case .venus: return "Venus"
            case .artistic: return "Artistic"
            case .oceanus: return "Oceanus"
            case .andromeda: return "Andromeda"
            }
        }
        
        var description: String {
            switch self {
            case .venus: return "Let Your Smile Shine Like Venus"
            case .artistic: return "Paint Your Emotions in Space"
            case .oceanus: return "Breathe with the Ocean"
            case .andromeda: return "Journey Through the Stars"
            }
        }
        
        var unlockCondition: String {
            switch self {
            case .venus: return "Start your journey here"
            case .artistic: return "Complete Venus journey to unlock"
            case .oceanus: return "Complete Artistic journey to unlock"
            case .andromeda: return "Complete Oceanus journey to unlock"
            }
        }
    }
    
    // MARK: - Public Methods
    
    /// 检查星球是否已解锁
    func isPlanetLocked(_ planet: PlanetType) -> Bool {
        !unlockedPlanets.contains(planet)
    }
    
    /// 解锁指定星球
    func unlockPlanet(_ planet: PlanetType) {
        unlockedPlanets.insert(planet)
        saveState()
    }
    
    /// 锁定指定星球
    func lockPlanet(_ planet: PlanetType) {
        if planet != .venus {  // Prevent Venus from being locked
            unlockedPlanets.remove(planet)
            saveState()
        }
    }
    
    /// 批量锁定星球
    func lockPlanets(_ planets: Set<PlanetType>) {
        let planetsToLock = planets.filter { $0 != .venus }  // Prevent Venus from being locked
        unlockedPlanets.subtract(planetsToLock)
        saveState()
    }
    
    /// 检查星球是否已完成
    func isPlanetCompleted(_ planet: PlanetType) -> Bool {
        completedPlanets.contains(planet)
    }
    
    /// 标记星球为已完成
    func markPlanetAsCompleted(_ planet: PlanetType) {
        completedPlanets.insert(planet)
        
        // 完成后解锁下一个星球
        if let next = planet.nextPlanet {
            unlockPlanet(next)
        }
        saveState()
    }
    
    /// 重置所有星球状态
    func resetAllPlanets() {
        unlockedPlanets = [.venus]
        completedPlanets = []
        saveState()
    }
    
    /// 解锁指定星球之后的所有星球
    func unlockPlanetsAfter(_ planet: PlanetType) {
        let planetsToUnlock = PlanetType.allCases.filter { $0.rawValue > planet.rawValue }
        unlockedPlanets.formUnion(planetsToUnlock)
        saveState()
    }
    
    /// 解锁下一个星球
    func unlockNextPlanet(after planet: PlanetType) {
        if let next = planet.nextPlanet {
            unlockPlanet(next)
            saveState()
        }
    }
    
    /// 获取下一个待解锁的星球
    func getNextLockedPlanet() -> PlanetType? {
        for planet in PlanetType.allCases.sorted(by: { $0.rawValue < $1.rawValue }) {
            if isPlanetLocked(planet) {
                return planet
            }
        }
        return nil
    }
} 