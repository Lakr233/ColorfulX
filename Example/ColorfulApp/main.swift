//
//  main.swift
//
//
//  Created by 秋星桥 on 2024/8/16.
//

import ColorfulX
import Foundation

App.main()

/*

 let threadTestTarget = AnimatedMulticolorGradientView()
 let colors = ColorfulPreset.appleIntelligence.colors.map { ColorElement($0) }
 threadTestTarget.setColors(colors.map { .init($0) })

 DispatchQueue.main.async {
     Thread {
         while true {
             DispatchQueue.main.asyncAndWait {
                 threadTestTarget.layoutSublayers(of: threadTestTarget.layer)
             }
         }
     }.start()
     Thread {
         while true {
             let colors = ColorfulPreset.allCases
                 .randomElement()!
                 .colors
                 .map { ColorElement($0) }
             threadTestTarget.setColors(colors.map { .init($0) })
         }
     }.start()
 }

 CFRunLoopRun()

 */
