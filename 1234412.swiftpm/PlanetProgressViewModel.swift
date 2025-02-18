import SwiftUI
import Combine

@MainActor
final class PlanetProgressViewModel: ObservableObject {
    // MARK: - Published Properties
    @Published private(set) var unlockedPlanets: Set<PlanetType>
    
    // MARK: - Constants
    private let userDefaultsKey = "UnlockedPlanets"
    
    // MARK: - Initialization
    init() {
        // 每次启动时只解锁 Venus
        self.unlockedPlanets = [.venus]
        self.saveUnlockedPlanets()
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
        saveUnlockedPlanets()
    }
    
    /// 锁定指定星球
    func lockPlanet(_ planet: PlanetType) {
        if planet != .venus {  // Prevent Venus from being locked
            unlockedPlanets.remove(planet)
            saveUnlockedPlanets()
        }
    }
    
    /// 批量锁定星球
    func lockPlanets(_ planets: Set<PlanetType>) {
        let planetsToLock = planets.filter { $0 != .venus }  // Prevent Venus from being locked
        unlockedPlanets.subtract(planetsToLock)
        saveUnlockedPlanets()
    }
    
    /// 重置所有星球状态
    func resetAllPlanets() {
        unlockedPlanets = [.venus]
        saveUnlockedPlanets()
    }
    
    /// 解锁指定星球之后的所有星球
    func unlockPlanetsAfter(_ planet: PlanetType) {
        let planetsToUnlock = PlanetType.allCases.filter { $0.rawValue > planet.rawValue }
        unlockedPlanets.formUnion(planetsToUnlock)
        saveUnlockedPlanets()
    }
    
    /// 解锁下一个星球
    func unlockNextPlanet(after planet: PlanetType) {
        if let next = planet.nextPlanet {
            unlockPlanet(next)
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
    
    // MARK: - Private Methods
    
    /// 保存解锁状态到 UserDefaults
    private func saveUnlockedPlanets() {
        let planetsArray = unlockedPlanets.map { $0.rawValue }
        UserDefaults.standard.set(planetsArray, forKey: userDefaultsKey)
    }
    
    /// 重置所有解锁状态（仅用于测试）
    func resetProgress() {
        unlockedPlanets = [.venus]
        saveUnlockedPlanets()
    }
} 