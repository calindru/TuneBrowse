//
//  Scheduler+Utils.swift
//  TuneBrowse
//
//  Created by Calin Drule on 27.06.2022.
//

import Foundation

final class Scheduler {

    static var background: OperationQueue = {
        let operationQueue = OperationQueue()
        operationQueue.maxConcurrentOperationCount = 6
        operationQueue.qualityOfService = .userInitiated
        
        return operationQueue
    }()

    static let main = RunLoop.main
}
