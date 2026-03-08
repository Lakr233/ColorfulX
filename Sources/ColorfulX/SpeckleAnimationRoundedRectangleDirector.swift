//
//  SpeckleAnimationRoundedRectangleDirector.swift
//
//
//  Created by GitHub Copilot on 2025/10/12.
//

import ColorVector
import CoreGraphics
import Foundation

#if os(macOS) && DEBUG
  import AppKit
  import QuartzCore
#endif

open class SpeckleAnimationRoundedRectangleDirector: SpeckleAnimationDirector {
  #if os(macOS) && DEBUG
    private var debugOverlayLayer: CALayer?
    private var debugPointLayers: [CAShapeLayer] = []
    private var debugPathLayer: CAShapeLayer?

    public var debugVisualizationEnabled: Bool = false {
      didSet {
        if debugVisualizationEnabled {
          setupDebugOverlay()
        } else {
          removeDebugOverlay()
        }
      }
    }

    public var debugPointRadius: CGFloat = 8.0
    public var debugPointColor: CGColor = NSColor.systemRed.cgColor
    public var debugPathColor: CGColor = NSColor.systemBlue.withAlphaComponent(0.5).cgColor
    public var debugPathLineWidth: CGFloat = 2.0
  #endif

  public enum Direction {
    case clockwise
    case counterClockwise

    var sign: Double { self == .clockwise ? 1 : -1 }
  }

  public var direction: Direction {
    get { directionValue }
    set {
      guard newValue != directionValue else { return }
      directionValue = newValue
      view?.renderInputWasModified = true
    }
  }

  public var inset: Double {
    get { insetValue }
    set {
      assert(
        newValue <= 1,
        "Inset must be less than or equal to 1; use negative values to extend outside the unit square."
      )
      let clamped = Self.clampInset(newValue)
      guard clamped != insetValue else { return }
      insetValue = clamped
      distributionDirty = true
      pathNeedsUpdate = true
      needsPositionRefresh = true
      view?.renderInputWasModified = true
    }
  }

  public var cornerRadius: Double {
    get { cornerRadiusValue }
    set {
      let clamped = Self.clampRadius(newValue)
      guard clamped != cornerRadiusValue else { return }
      cornerRadiusValue = clamped
      pathNeedsUpdate = true
      needsPositionRefresh = true
      view?.renderInputWasModified = true
    }
  }

  public var movementRate: Double {
    get { movementRateValue }
    set {
      let clamped = max(0, newValue)
      guard clamped != movementRateValue else { return }
      movementRateValue = clamped
      view?.renderInputWasModified = true
    }
  }

  public var positionResponseRate: Double {
    get { positionResponseRateValue }
    set {
      let clamped = max(0, newValue)
      guard clamped != positionResponseRateValue else { return }
      positionResponseRateValue = clamped
      view?.renderInputWasModified = true
    }
  }

  private var directionValue: Direction
  private var insetValue: Double
  private var cornerRadiusValue: Double
  private var movementRateValue: Double
  private var positionResponseRateValue: Double

  private var progressState: [Double]
  private var distributionDirty: Bool
  private var needsPositionRefresh: Bool
  private var pathCache: Path
  private var pathNeedsUpdate: Bool
  private var distributionIndices: [Int]

  nonisolated static let numericEpsilon: Double = 1e-6

  public init(
    inset: Double = 0.1,
    cornerRadius: Double = 0.18,
    direction: Direction = .clockwise,
    movementRate: Double = 0.25,
    positionResponseRate: Double = 0.5,
  ) {
    precondition(
      inset <= 1,
      "Inset must be less than or equal to 1; use negative values to extend outside the unit square."
    )
    directionValue = direction
    insetValue = Self.clampInset(inset)
    cornerRadiusValue = Self.clampRadius(cornerRadius)
    movementRateValue = max(0, movementRate)
    positionResponseRateValue = max(0, positionResponseRate)
    progressState = Array(repeating: 0, count: Uniforms.COLOR_SLOT)
    distributionDirty = true
    needsPositionRefresh = true
    distributionIndices = []
    pathCache = .empty
    pathNeedsUpdate = true
    super.init()
  }

  override open func attach(to view: AnimatedMulticolorGradientView) {
    super.attach(to: view)
    #if os(macOS) && DEBUG
      if debugVisualizationEnabled {
        setupDebugOverlay()
      }
    #endif
  }

  override open func detach() {
    #if os(macOS) && DEBUG
      removeDebugOverlay()
    #endif
    super.detach()
  }

  override open func initialize() {
    if let view {
      ensureProgressCapacity(view.speckles.count)
      refreshDistribution(for: view, force: true)
    }
    super.initialize()
    needsPositionRefresh = false
  }

  override open func update(deltaTime: Double) {
    guard let view else {
      super.update(deltaTime: deltaTime)
      return
    }
    ensureProgressCapacity(view.speckles.count)
    refreshDistribution(for: view)
    advanceProgress(for: view, deltaTime: deltaTime)
    super.update(deltaTime: deltaTime)
    needsPositionRefresh = false

    #if os(macOS) && DEBUG
      if debugVisualizationEnabled {
        updateDebugVisualization()
      }
    #endif
  }

  override open func initializeSpeckle(
    _ speckle: inout AnimatedMulticolorGradientView.Speckle,
    index: Int,
  ) {
    super.initializeSpeckle(&speckle, index: index)
    guard index < progressState.count else { return }
    let location = samplePoint(at: progressState[index])
    speckle.position.setCurrent(.init(x: location.x, y: location.y))
    speckle.position.setTarget(.init(x: location.x, y: location.y))
  }

  override open func updateSpeckle(
    _ speckle: inout AnimatedMulticolorGradientView.Speckle,
    index: Int,
    deltaTime: Double,
  ) {
    super.updateSpeckle(&speckle, index: index, deltaTime: deltaTime)
    guard let view, index < progressState.count else { return }
    let location = samplePoint(at: progressState[index])
    let targetX = location.x
    let targetY = location.y

    if needsPositionRefresh {
      speckle.position.setCurrent(.init(x: targetX, y: targetY))
      speckle.position.setTarget(.init(x: targetX, y: targetY))
      view.renderInputWasModified = true
      return
    }

    let previousTargetX = speckle.position.x.context.targetPos
    let previousTargetY = speckle.position.y.context.targetPos
    if abs(previousTargetX - targetX) > Self.numericEpsilon
      || abs(previousTargetY - targetY) > Self.numericEpsilon
    {
      speckle.position.setTarget(.init(x: targetX, y: targetY))
      view.renderInputWasModified = true
    }

    let moveDelta = deltaTime * view.speed * positionResponseRateValue
    if moveDelta > 0 {
      speckle.position.update(withDeltaTime: moveDelta)
      view.renderInputWasModified = true
    }
  }
}

extension SpeckleAnimationRoundedRectangleDirector {
  fileprivate typealias PathPoint = (x: Double, y: Double)

  fileprivate struct Path {
    let segments: [Segment]
    let totalLength: Double

    static let empty = Path(segments: [], totalLength: 1)
  }

  fileprivate struct Segment {
    enum Kind {
      case line(start: PathPoint, end: PathPoint)
      case arc(center: PathPoint, radius: Double, startAngle: Double, endAngle: Double)
    }

    let kind: Kind
    let length: Double

    var endPoint: PathPoint {
      switch kind {
      case .line(_, let end):
        end
      case .arc(let center, let radius, _, let endAngle):
        Segment.pointOnArc(center: center, radius: radius, angle: endAngle)
      }
    }

    func point(at ratio: Double) -> PathPoint {
      let clamped = SpeckleAnimationRoundedRectangleDirector.clamp01(ratio)
      switch kind {
      case .line(let start, let end):
        return (
          x: start.x + (end.x - start.x) * clamped,
          y: start.y + (end.y - start.y) * clamped,
        )
      case .arc(let center, let radius, let startAngle, let endAngle):
        let angle = startAngle + (endAngle - startAngle) * clamped
        return Segment.pointOnArc(center: center, radius: radius, angle: angle)
      }
    }

    static func line(from start: PathPoint, to end: PathPoint) -> Segment? {
      let length = hypot(end.x - start.x, end.y - start.y)
      guard length > SpeckleAnimationRoundedRectangleDirector.numericEpsilon else { return nil }
      return Segment(kind: .line(start: start, end: end), length: length)
    }

    static func arc(
      center: PathPoint,
      radius: Double,
      startAngle: Double,
      endAngle: Double,
    ) -> Segment? {
      let delta = endAngle - startAngle
      guard radius > SpeckleAnimationRoundedRectangleDirector.numericEpsilon,
        delta > SpeckleAnimationRoundedRectangleDirector.numericEpsilon
      else { return nil }
      return Segment(
        kind: .arc(center: center, radius: radius, startAngle: startAngle, endAngle: endAngle),
        length: radius * delta)
    }

    private static func pointOnArc(center: PathPoint, radius: Double, angle: Double) -> PathPoint {
      (
        x: center.x + cos(angle) * radius,
        y: center.y + sin(angle) * radius,
      )
    }
  }

  fileprivate nonisolated static func clampInset(_ value: Double) -> Double {
    if value >= 0 {
      return clamp(value, lower: 0, upper: 1)
    }
    return value
  }

  fileprivate nonisolated static func clampRadius(_ value: Double) -> Double {
    max(0, min(value, 0.5))
  }

  fileprivate nonisolated static func clamp01(_ value: Double) -> Double {
    clamp(value, lower: 0, upper: 1)
  }

  fileprivate nonisolated static func clamp(_ value: Double, lower: Double, upper: Double) -> Double
  { min(max(value, lower), upper) }

  fileprivate func ensureProgressCapacity(_ count: Int) {
    guard count > progressState.count else { return }
    progressState.append(contentsOf: Array(repeating: 0, count: count - progressState.count))
  }

  fileprivate func refreshDistribution(
    for view: AnimatedMulticolorGradientView, force: Bool = false
  ) {
    if force { distributionDirty = true }
    ensurePath()

    let enabledIndices = view.speckles.enumerated().compactMap {
      $0.element.enabled ? $0.offset : nil
    }
    let desiredDistribution = enabledIndices.isEmpty ? Array(view.speckles.indices) : enabledIndices

    guard distributionDirty || desiredDistribution != distributionIndices else { return }

    distributionIndices = desiredDistribution
    let total = max(distributionIndices.count, 1)
    for (offset, index) in distributionIndices.enumerated() {
      progressState[index] = Double(offset) / Double(total)
    }

    needsPositionRefresh = true
    distributionDirty = false
    view.renderInputWasModified = true
  }

  fileprivate func advanceProgress(for view: AnimatedMulticolorGradientView, deltaTime: Double) {
    let delta = deltaTime * view.speed * movementRateValue * directionValue.sign
    guard abs(delta) > Self.numericEpsilon else { return }
    if distributionIndices.isEmpty {
      for index in view.speckles.indices {
        progressState[index] = wrap(progressState[index] + delta)
      }
    } else {
      for index in distributionIndices {
        progressState[index] = wrap(progressState[index] + delta)
      }
    }
  }

  fileprivate func samplePoint(at progress: Double) -> PathPoint {
    ensurePath()
    guard !pathCache.segments.isEmpty else { return (x: 0.5, y: 0.5) }

    let totalLength = pathCache.totalLength
    var remaining = wrap(progress) * totalLength

    for segment in pathCache.segments {
      guard segment.length > Self.numericEpsilon else { continue }
      if remaining <= segment.length {
        let ratio = segment.length <= Self.numericEpsilon ? 0 : remaining / segment.length
        return segment.point(at: ratio)
      }
      remaining -= segment.length
    }

    return pathCache.segments.last?.endPoint ?? (x: 0.5, y: 0.5)
  }

  fileprivate func ensurePath() {
    guard pathNeedsUpdate else { return }
    pathCache = buildPath()
    pathNeedsUpdate = false
  }

  fileprivate func buildPath() -> Path {
    let inset = insetValue
    let left = inset
    let right = 1 - inset
    let top = inset
    let bottom = 1 - inset

    let width = max(right - left, 0)
    let height = max(bottom - top, 0)
    guard width > Self.numericEpsilon, height > Self.numericEpsilon else { return .empty }

    let radiusLimit = min(width, height) / 2
    let radius = min(max(cornerRadiusValue, 0), radiusLimit)

    var segments: [Segment] = []

    if radius <= Self.numericEpsilon {
      let topLeft: PathPoint = (x: left, y: top)
      let topRight: PathPoint = (x: right, y: top)
      let bottomRight: PathPoint = (x: right, y: bottom)
      let bottomLeft: PathPoint = (x: left, y: bottom)

      if let line = Segment.line(from: topLeft, to: topRight) { segments.append(line) }
      if let line = Segment.line(from: topRight, to: bottomRight) { segments.append(line) }
      if let line = Segment.line(from: bottomRight, to: bottomLeft) { segments.append(line) }
      if let line = Segment.line(from: bottomLeft, to: topLeft) { segments.append(line) }
    } else {
      let topStart: PathPoint = (x: left + radius, y: top)
      let topEnd: PathPoint = (x: right - radius, y: top)
      let rightStart: PathPoint = (x: right, y: top + radius)
      let rightEnd: PathPoint = (x: right, y: bottom - radius)
      let bottomStart: PathPoint = (x: right - radius, y: bottom)
      let bottomEnd: PathPoint = (x: left + radius, y: bottom)
      let leftStart: PathPoint = (x: left, y: bottom - radius)
      let leftEnd: PathPoint = (x: left, y: top + radius)

      if let line = Segment.line(from: topStart, to: topEnd) { segments.append(line) }
      if let arc = Segment.arc(
        center: (x: right - radius, y: top + radius),
        radius: radius,
        startAngle: 1.5 * .pi,
        endAngle: 2 * .pi,
      ) {
        segments.append(arc)
      }
      if let line = Segment.line(from: rightStart, to: rightEnd) { segments.append(line) }
      if let arc = Segment.arc(
        center: (x: right - radius, y: bottom - radius),
        radius: radius,
        startAngle: 0,
        endAngle: 0.5 * .pi,
      ) {
        segments.append(arc)
      }
      if let line = Segment.line(from: bottomStart, to: bottomEnd) { segments.append(line) }
      if let arc = Segment.arc(
        center: (x: left + radius, y: bottom - radius),
        radius: radius,
        startAngle: 0.5 * .pi,
        endAngle: .pi,
      ) {
        segments.append(arc)
      }
      if let line = Segment.line(from: leftStart, to: leftEnd) { segments.append(line) }
      if let arc = Segment.arc(
        center: (x: left + radius, y: top + radius),
        radius: radius,
        startAngle: .pi,
        endAngle: 1.5 * .pi,
      ) {
        segments.append(arc)
      }
    }

    let total = segments.reduce(0) { $0 + $1.length }
    return Path(segments: segments, totalLength: max(total, Self.numericEpsilon))
  }

  fileprivate func wrap(_ value: Double) -> Double {
    var result = value.truncatingRemainder(dividingBy: 1)
    if result < 0 { result += 1 }
    return result
  }
}

// MARK: - Debug Visualization

#if os(macOS) && DEBUG
  extension SpeckleAnimationRoundedRectangleDirector {
    func setupDebugOverlay() {
      guard let view, debugOverlayLayer == nil else { return }

      let overlay = CALayer()
      overlay.frame = view.bounds
      overlay.zPosition = 1000
      overlay.autoresizingMask = [.layerWidthSizable, .layerHeightSizable]
      view.layer?.addSublayer(overlay)
      debugOverlayLayer = overlay

      // Create path layer
      let pathLayer = CAShapeLayer()
      pathLayer.fillColor = nil
      pathLayer.strokeColor = debugPathColor
      pathLayer.lineWidth = debugPathLineWidth
      pathLayer.lineDashPattern = [4, 4]
      overlay.addSublayer(pathLayer)
      debugPathLayer = pathLayer

      // Create point layers for each speckle
      debugPointLayers.removeAll()
      for index in 0..<Uniforms.COLOR_SLOT {
        let pointLayer = CAShapeLayer()
        pointLayer.fillColor = debugPointColor
        pointLayer.strokeColor = NSColor.white.cgColor
        pointLayer.lineWidth = 2.0
        pointLayer.shadowColor = NSColor.black.cgColor
        pointLayer.shadowOffset = CGSize(width: 0, height: 1)
        pointLayer.shadowOpacity = 0.5
        pointLayer.shadowRadius = 2.0

        // Add index label
        let textLayer = CATextLayer()
        textLayer.string = "\(index)"
        textLayer.fontSize = 10
        textLayer.foregroundColor = NSColor.white.cgColor
        textLayer.alignmentMode = .center
        textLayer.contentsScale = NSScreen.main?.backingScaleFactor ?? 2.0
        textLayer.frame = CGRect(x: -10, y: -10, width: 20, height: 14)
        pointLayer.addSublayer(textLayer)

        overlay.addSublayer(pointLayer)
        debugPointLayers.append(pointLayer)
      }

      updateDebugVisualization()
    }

    func removeDebugOverlay() {
      debugOverlayLayer?.removeFromSuperlayer()
      debugOverlayLayer = nil
      debugPointLayers.removeAll()
      debugPathLayer = nil
    }

    func updateDebugVisualization() {
      guard let view, let overlay = debugOverlayLayer else { return }

      CATransaction.begin()
      CATransaction.setDisableActions(true)

      let bounds = view.bounds
      overlay.frame = bounds

      // Update path visualization
      updateDebugPath(in: bounds)

      // Update point positions
      for (index, pointLayer) in debugPointLayers.enumerated() {
        guard index < view.speckles.count else {
          pointLayer.isHidden = true
          continue
        }

        let speckle = view.speckles[index]
        pointLayer.isHidden = !speckle.enabled

        if speckle.enabled {
          let x = speckle.position.x.context.currentPos * bounds.width
          // Flip Y coordinate: macOS uses bottom-left origin, but path uses top-left origin
          let y = (1.0 - speckle.position.y.context.currentPos) * bounds.height

          let circlePath = CGPath(
            ellipseIn: CGRect(
              x: -debugPointRadius,
              y: -debugPointRadius,
              width: debugPointRadius * 2,
              height: debugPointRadius * 2,
            ),
            transform: nil,
          )
          pointLayer.path = circlePath
          pointLayer.position = CGPoint(x: x, y: y)

          // Update text layer position
          if let textLayer = pointLayer.sublayers?.first as? CATextLayer {
            textLayer.frame = CGRect(
              x: -10,
              y: debugPointRadius + 2,
              width: 20,
              height: 14,
            )
          }

          // Color the point based on the speckle's color
          let labColor = speckle.color
          let rgbColor = labColor.color(in: .rgb)
          pointLayer.fillColor = CGColor(
            red: CGFloat(rgbColor.v.x / 255.0),
            green: CGFloat(rgbColor.v.y / 255.0),
            blue: CGFloat(rgbColor.v.z / 255.0),
            alpha: 1.0,
          )
        }
      }

      CATransaction.commit()
    }

    private func updateDebugPath(in bounds: CGRect) {
      guard let pathLayer = debugPathLayer else { return }

      ensurePath()
      guard !pathCache.segments.isEmpty else {
        pathLayer.path = nil
        return
      }

      // Sample the path using samplePoint to ensure consistency with speckle positions
      let bezierPath = NSBezierPath()
      let sampleCount = 100

      for i in 0..<sampleCount {
        let progress = Double(i) / Double(sampleCount)
        let pathPoint = samplePoint(at: progress)

        let screenPoint = CGPoint(
          x: pathPoint.x * bounds.width,
          y: (1.0 - pathPoint.y) * bounds.height,
        )

        if i == 0 {
          bezierPath.move(to: screenPoint)
        } else {
          bezierPath.line(to: screenPoint)
        }
      }

      bezierPath.close()
      pathLayer.path = bezierPath.cgPath
    }
  }

  extension NSBezierPath {
    fileprivate var cgPath: CGPath {
      let path = CGMutablePath()
      var points = [CGPoint](repeating: .zero, count: 3)

      for i in 0..<elementCount {
        let type = element(at: i, associatedPoints: &points)
        switch type {
        case .moveTo:
          path.move(to: points[0])
        case .lineTo:
          path.addLine(to: points[0])
        case .curveTo:
          path.addCurve(to: points[2], control1: points[0], control2: points[1])
        case .closePath:
          path.closeSubpath()
        case .cubicCurveTo:
          path.addCurve(to: points[2], control1: points[0], control2: points[1])
        case .quadraticCurveTo:
          path.addQuadCurve(to: points[1], control: points[0])
        @unknown default:
          break
        }
      }

      return path
    }
  }
#endif
