@preconcurrency import Vision
import UIKit
import SwiftUI

@MainActor
final class VisionProcessor: NSObject, ObservableObject {
    @Published var isSmiling = false
    @Published var smilingDuration: TimeInterval = 0
    @Published var hasReachedTarget = false
    
    private var lastSmileStartTime: Date?
    private let targetDuration: TimeInterval = 2.0
    
    nonisolated private static let sequenceHandler = VNSequenceRequestHandler()
    
    static nonisolated func detectSmile(mouthPoints: [CGPoint]) -> Bool {
        // Check for sufficient mouth points
        guard mouthPoints.count >= 4 else {
            print("❌ Insufficient mouth points")
            return false
        }
        
        // Get key points
        let leftCorner = mouthPoints[0]      // Left mouth corner
        let rightCorner = mouthPoints[6]     // Right mouth corner
        let topCenter = mouthPoints[3]       // Top lip center
        let bottomCenter = mouthPoints[9]    // Bottom lip center
        
        // Calculate vertical distances (using y coordinates)
        let leftCornerToCenter = abs(leftCorner.y - ((topCenter.y + bottomCenter.y) / 2))
        let rightCornerToCenter = abs(rightCorner.y - ((topCenter.y + bottomCenter.y) / 2))
        
        // Calculate mouth openness
        let mouthOpenness = abs(topCenter.y - bottomCenter.y)
        
        print("""
        📏 Smile Detection Details:
        Left Corner: (\(leftCorner.x), \(leftCorner.y))
        Right Corner: (\(rightCorner.x), \(rightCorner.y))
        Top Center: (\(topCenter.x), \(topCenter.y))
        Bottom Center: (\(bottomCenter.x), \(bottomCenter.y))
        Left Corner Distance: \(leftCornerToCenter)
        Right Corner Distance: \(rightCornerToCenter)
        Mouth Openness: \(mouthOpenness)
        """)
        
        // Smile detection criteria
        let hasSignificantCorner = leftCornerToCenter > 0.2 || rightCornerToCenter > 0.2
        let bothCornersMoving = leftCornerToCenter > 0.1 && rightCornerToCenter > 0.1
        let isOpenEnough = mouthOpenness > 0.08
        
        print("""
        🔍 Detection Results:
        Has Significant Corner: \(hasSignificantCorner)
        Both Corners Moving: \(bothCornersMoving)
        Is Open Enough: \(isOpenEnough)
        """)
        
        return hasSignificantCorner && bothCornersMoving && isOpenEnough
    }
    
    nonisolated func processImage(_ pixelBuffer: CVPixelBuffer) async {
        let faceDetectionRequest = VNDetectFaceLandmarksRequest { [weak self] request, error in
            if let error = error {
                print("❌ Face detection error: \(error)")
                return
            }
            
            guard let observations = request.results as? [VNFaceObservation] else {
                print("❌ No face observations")
                Task { @MainActor [weak self] in
                    self?.isSmiling = false
                    self?.resetSmileDetection()
                }
                return
            }
            
            print("✅ Detected \(observations.count) faces")
            
            guard let face = observations.first,
                  let landmarks = face.landmarks else {
                print("❌ No landmarks detected")
                Task { @MainActor [weak self] in
                    self?.isSmiling = false
                    self?.resetSmileDetection()
                }
                return
            }
            
            print("✅ Landmarks detected")
            
            guard let mouth = landmarks.outerLips else {
                print("❌ No mouth detected")
                Task { @MainActor [weak self] in
                    self?.isSmiling = false
                    self?.resetSmileDetection()
                }
                return
            }
            
            print("✅ Mouth detected")
            let mouthPoints = mouth.normalizedPoints
            let isCurrentlySmiling = Self.detectSmile(mouthPoints: mouthPoints)
            
            print("😊 Smile detection result: \(isCurrentlySmiling)")
            
            Task { @MainActor [weak self] in
                self?.updateSmileState(isSmiling: isCurrentlySmiling)
            }
        }
        
        do {
            try Self.sequenceHandler.perform(
                [faceDetectionRequest],
                on: pixelBuffer,
                orientation: .right)
        } catch {
            print("❌ Vision processing error: \(error.localizedDescription)")
        }
    }
    
    private func updateSmileState(isSmiling: Bool) {
        self.isSmiling = isSmiling
        
        if isSmiling {
            if lastSmileStartTime == nil {
                lastSmileStartTime = Date()
                print("⏱ Started smile timer")
            }
            
            if let startTime = lastSmileStartTime {
                smilingDuration = min(Date().timeIntervalSince(startTime), targetDuration)
                print("⏱ Smile duration: \(smilingDuration)s")
                
                if smilingDuration >= targetDuration && !hasReachedTarget {
                    hasReachedTarget = true
                    print("🎉 Reached target duration!")
                }
            }
        } else {
            if lastSmileStartTime != nil {
                print("⏱ Reset smile timer")
            }
            resetSmileDetection()
        }
    }
    
    func resetSmileDetection() {
        lastSmileStartTime = nil
        smilingDuration = 0
        hasReachedTarget = false
    }
}