//
//  SpeckleAnimationDirector.swift
//
//
//  Created by GitHub Copilot on 2025/10/12.
//

import Foundation

@MainActor
open class SpeckleAnimationDirector {
  public private(set) weak var view: AnimatedMulticolorGradientView?

  public init() {}

  open func attach(to view: AnimatedMulticolorGradientView) {
    self.view = view
  }

  open func detach() {
    view = nil
  }

  open func initialize() {
    guard let view else { return }
    view.alteringSpeckleByIteratingValues { speckle, idx in
      speckle.transitionProgress.setTarget(1)
      initializeSpeckle(&speckle, index: idx)
    }
    updateColorStops()
  }

  open func update(deltaTime: Double) {
    guard let view else { return }
    view.alteringSpeckleByIteratingValues { speckle, idx in
      advanceColorTransition(for: &speckle, deltaTime: deltaTime)
      updateSpeckle(&speckle, index: idx, deltaTime: deltaTime)
    }
    updateColorStops()
  }

  open func initializeSpeckle(_: inout AnimatedMulticolorGradientView.Speckle, index _: Int) {}

  open func updateSpeckle(
    _: inout AnimatedMulticolorGradientView.Speckle,
    index _: Int,
    deltaTime _: Double,
  ) {}

  public func advanceColorTransition(
    for speckle: inout AnimatedMulticolorGradientView.Speckle,
    deltaTime: Double,
  ) {
    guard let view, speckle.transitionProgress.context.currentPos < 1 else { return }
    speckle.transitionProgress.update(withDeltaTime: deltaTime * view.transitionSpeed)
  }

  public func updateColorStops() {
    guard let view else { return }
    var points: [MulticolorGradientView.Parameters.ColorStop]?
    view.alteringSpeckles { speckles in
      points = speckles.filter(\.enabled).map { speckle in
        .init(
          color: speckle.color,
          position: .init(
            x: speckle.position.x.context.currentPos,
            y: speckle.position.y.context.currentPos,
          ),
        )
      }
    }
    guard let points else { return }
    view.parameters = .init(
      points: points,
      bias: view.bias,
      noise: view.noise,
    )
  }
}
