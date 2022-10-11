//
//  PitFallViewController.swift
//  TestProject
//
//  Created by Sai Kishore Swaminathan on 04/04/22.
//

import UIKit

class PitFallViewController: UIViewController {

    let concurrentQueue = DispatchQueue(label: "com.TestProject.conc", attributes: .concurrent)
    let concurrentQueue2 = DispatchQueue(label: "com.TestProject.conc2", attributes: .concurrent)
    let isolationQueue = DispatchQueue(label: "com.TestProject.conc", attributes: .concurrent)
    let queue = DispatchQueue(label: "boom_")

    private var _array = [1,2,3,4,5]

    var threadSafeContainer: [Int] {
        get {
            isolationQueue.sync {
                _array
            }
        }
        set {
            isolationQueue.async(flags: .barrier) {
                self._array = newValue
            }
        }
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        for _ in 0...9 {
            race()
        }
    }

    private func race() {

//        concurrentQueue.async {
//            // Read from Array
//            for i in self.threadSafeContainer {
//                print(i)
//            }
//        }
//
//        concurrentQueue2.async {
//            // write to array
//            for i in 0...100 {
//                self.threadSafeContainer.append(i)
//            }
//            print("Done Writing to threadUnsafe queue")
//        }

//        logLifecycle()
    }

    func logEntered() {
        queue.sync {
            print("Entered!")
        }
    }

    func logExited() {
        queue.sync {
            print("Exited!")
        }
    }

    func logLifecycle() {
        queue.async {
            self.logEntered()
            print("Running!")
            self.logExited()
        }
    }

}

final class ChickenFeederWithQueue {
    let food = "worms"

    /// A combination of a private backing property and a computed property allows for synchronized access.
    private var _numberOfEatingChickens: Int = 0
    var numberOfEatingChickens: Int {
        queue.sync {
            _numberOfEatingChickens
        }
    }

    /// A concurrent queue to allow multiple reads at once.
    private var queue = DispatchQueue(label: "chicken.feeder.queue", attributes: .concurrent)

    func chickenStartsEating() {
        /// Using a barrier to stop reads while writing
        queue.sync(flags: .barrier) {
            _numberOfEatingChickens += 1
        }
    }

    func chickenStopsEating() {
        /// Using a barrier to stop reads while writing
        queue.sync(flags: .barrier) {
            _numberOfEatingChickens -= 1
        }
    }
}

//  Swift Actor forces the compiler for synchronised access ( =<iOS 15
// Actor does not support inheritance,
// non-isolated functions is possible


// References
//https://www.avanderlee.com/swift/actors/
