//
//  DummyTimeConsumingLogic.swift
//  TestProject
//
//  Created by Sai Kishore Swaminathan on 11/10/22.
//

import Foundation

class DummyTimeConsumingLogic {
    func heavyProcessingCalculations() {
        var counter = 0
        for _ in 0...Int.random(in: 99999...10000000) {
            counter += 1
        }
    }
}
