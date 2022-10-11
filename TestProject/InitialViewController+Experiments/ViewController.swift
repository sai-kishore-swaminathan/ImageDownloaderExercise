//
//  ViewController.swift
//  TestProject
//
//  Created by Sai Kishore Swaminathan on 28/03/22.
//

import UIKit

final class ViewController: UIViewController {

    var myArray = [Int]()

    let semaphore = DispatchSemaphore(value: 3)

    let downloadQueue = DispatchQueue(label: "com.testing.downloadqueue", attributes: .concurrent)

    @IBOutlet weak var button: UIButton!
    var box: UIView!

    // Serial by default
    let starterQueue = DispatchQueue(label: "com.TestProject.starterQueue", qos: .userInteractive)
    let backgroundQueue = DispatchQueue(label: "com.TestProject.backgroud", qos: .background)
    let utilityQueue = DispatchQueue(label: "com.TestProject.utility", qos: .utility)

    let concurrentQueue = DispatchQueue(label: "com.TestProject.conc", attributes: .concurrent)

    override func viewDidLoad() {
        super.viewDidLoad()
        setupUI()
        operationDependency()
    }

    //MARK: - Action Logic

    @IBAction func mainAsyncPressed(_ sender: Any) {
        // Still does all the work in the main thread , just that its asynchronous
        print("Started in Main Queue \(Thread.current)")
        DispatchQueue.main.async { [unowned self] in
            self.customImageProcessing(display: 1, reps: 3)
        }
        DispatchQueue.main.async {
            self.customImageProcessing(display: 2, reps: 2)
        }
        changeBackgroundColour()

        // What if its performed in a different queue ?
    }

    @IBAction func dispatchBarrier(_ sender: Any) {
        for i in 0...6 {
            concurrentQueue.async {
                print("Utility \(i) \t\t \(Thread.current)")
                self.customImageProcessing(display: i, reps: 1)
            }
        }

        for j in 7...15 {
            concurrentQueue.async {
                print("Utiity \(j) \t\t \(Thread.current)")
            }
        }

//        for k in 16...24 {
//            concurrentQueue.async {
//                print("Utility \(k) \t\t \(Thread.current)")
//            }
//        }
        for k in 16...24 {
            concurrentQueue.async(flags: .barrier) {
                self.customImageProcessing(display: k, reps: 1)
                print("Utility \(k) \t\t \(Thread.current)")
            }
        }

        for l in 25...30 {
            concurrentQueue.async {
                print("Utiity \(l) \t\t \(Thread.current)")
            }
        }

    }

    @IBAction func deadLockPressed(_ sender: Any) {
        deadLock()
    }

    @IBAction func globalAsyncPressed(_ sender: Any) {
        print("started in Global Queue \(Thread.current)")

        DispatchQueue.global(qos: .default).async { [unowned self] in
            // Priority Inversion here
//            DispatchQueue.main.async { [unowned self] in
//                self.customImageProcessing(display: 3, reps: 3)
//            }
            self.customImageProcessing(display: 1, reps: 3)
        }
        DispatchQueue.global(qos: .userInteractive).async { [unowned self] in
            self.customImageProcessing(display: 2, reps: 2)
        }
        changeBackgroundColour()

    }

    @IBAction func priorityInversionButtonPressed(_ sender: Any) {
        starterQueue.async {
            print("Starter Queue starting \t\t \(Thread.current)")
            self.backgroundQueue.async {
                self.output(type: .background, times: 10)
            }
            self.backgroundQueue.async {
                self.output(type: .background, times: 10)
            }
            self.utilityQueue.async {
                self.output(type: .utility, times: 10)
            }
            self.utilityQueue.async {
                self.output(type: .utility, times: 10)
            }
//            self.backgroundQueue.sync {
//                print("Sync Started on \(Thread.current)")
//            }
        }
    }

    @IBAction func noTaskPressed(_ sender: Any) {
        changeBackgroundColour()
    }

    @IBAction func semaphoresPressed(_ sender: Any) {
        for i in 0..<15 {
            downloadQueue.async { [unowned self] in
                // Lock
                self.semaphore.wait()

                // Task
                self.download(i+1)

                DispatchQueue.main.async {
                    self.changeBackgroundColour()

                    // Relese Lock
                    self.semaphore.signal()
                }
            }
        }

    }


    @IBAction func dispatchGroupPressed(_ sender: Any) {
        print("Some Long Task going to start")

//        let dispatchGrouup = DispatchGroup()

//        dispatchGrouup.enter()
        DispatchQueue.global().async { [unowned self] in
            self.customImageProcessing(display: 1, reps: 2)
//            dispatchGrouup.leave()
        }

//        dispatchGrouup.enter()
        DispatchQueue.global().async { [unowned self] in
            self.customImageProcessing(display: 2, reps: 2)
//            dispatchGrouup.leave()
        }

//        dispatchGrouup.enter()
        DispatchQueue.global().async { [unowned self] in
            self.customImageProcessing(display: 3, reps: 2)
//            dispatchGrouup.leave()
        }

//        dispatchGrouup.wait() // Will Block current thread until all the above tasks are done
        print("All tasks completed")
    }

    @IBAction func targetQueuePressed(_ sender: Any) {
        let serialQueue = DispatchQueue(label:"com.mySerial.Queue")
        let concurrentQueue = DispatchQueue(label: "com.myConcurrent.Queue", attributes: [.concurrent])
        concurrentQueue.setTarget(queue: .main)
//        concurrentQueue.activate()
//        concurrentQueue.setTarget(queue: serialQueue)
//        concurrentQueue.activate()

        concurrentQueue.async {
            for i in 4...6 {
                print("Printing \(i) \(Thread.current)")
            }
        }

        serialQueue.async {
//            self.customImageProcessing(display: 1, reps: 3)
            for i in 0...3 {
                print("Printing \(i) \(Thread.current)")
            }
        }

        print("Printing gapp ------")

    }

    @IBAction func semaphores2(_ sender: Any) {
        var value = 2
        let concurrentQueue = DispatchQueue(label: "queue", attributes: .concurrent)
        let semaphore = DispatchSemaphore(value: 1)

        for j in 0...4 {
            concurrentQueue.async {
                print("\(j) waiting")
                semaphore.wait()
                print("\(j) wait finished")
                value = j
                print("\(value) ✡️")
                print("\(j) Done with assignment")
                semaphore.signal()
            }
        }
    }

    @IBAction func blockOperation(_ sender: Any) {
        let queue = OperationQueue()
        let operation = BlockOperation()

        for i in 1...3 {
            operation.addExecutionBlock {
                if !operation.isCancelled {
                        print("Operation \(i) happening")
                        let imageURL = URL(string: "https://upload.wikimedia.org/wikipedia/commons/0/07/Huge_ball_at_Vilnius_center.jpg")!
                        let _ = try! Data(contentsOf: imageURL)

                        OperationQueue.main.addOperation {
                            print("Image \(i) downloaded...")
                        }
                }
            }
            operation.queuePriority = .high
            queue.addOperation(operation)
        }

        queue.maxConcurrentOperationCount = 2
        queue.waitUntilAllOperationsAreFinished()
        queue.cancelAllOperations()
    }


    @IBAction func rlockPressed(_ sender: Any) {
        logLifecycle()
    }
    //MARK: - Private Methods

    private func setupUI() {
        view.backgroundColor = UIColor.colorOne
    }

    private func customImageProcessing(display: Int, reps: Int) {
        var counter = 0
        for _ in 0...reps {
            for _ in 0...9999999 {
                counter += 1
            }
            counter = 0
        }
        print("done \(display) in queue \(Thread.current)")
    }

    private func changeBackgroundColour() {
        print("Updated UI")
        view.backgroundColor = view.backgroundColor == UIColor.colorOne ? UIColor.colorTwo :  UIColor.colorOne
    }

    private func output(type: QueueQos, times: Int) {
        for i in 0...times {
            print(type.rawValue + "\(i)" + "\t\t" + "\(Thread.current)")
        }
    }

    private func deadLock() {
        concurrentQueue.async {
            print("Current Thread, \(Thread.current)") // Thread 5
            self.concurrentQueue.sync {
                print("No DeadLock \(Thread.current)") // Thread 5
            }
        }

//        starterQueue.async {
//            self.starterQueue.sync {
//                print("DeadLock")
//            }
//        }
    }

    private func download(_ songId: Int){
        var counter = 0
        for _ in 0..<Int.random(in: 9999999...10000000) {
            counter += songId
        }
    }

    private func createRaceCondition() {
        DispatchQueue.concurrentPerform(iterations: 30) { index in
            self.myArray.append(index)
            print(myArray)
        }
    }


    //MARK: - Recurssive Lock
    let recursiveLock = NSRecursiveLock()

    func synchronize(action: () -> Void) {
        recursiveLock.lock()
        action()
        recursiveLock.unlock()
    }

    func logEntered() {
        synchronize {
            print("Entered!")
        }
    }

    func logExited() {
        synchronize {
            print("Exited!")
        }
    }

    func logLifecycle() {
        synchronize {
            logEntered()
            print("Running!")
            logExited()
        }
    }

    let task1 = BlockOperation {
        print("Task 1")
    }
    let task2 = BlockOperation {
        print("Task 2")
    }

    func testFunction() {
        let task1 = BlockOperation {
            print("Task 1")
        }
        let task2 = BlockOperation {
            print("Task 2")
        }

        task1.addDependency(task2)
        let serialOperationQueue = OperationQueue()
        let tasks = [task1, task2]
        serialOperationQueue.addOperations(tasks, waitUntilFinished: false)
    }

    func testFunction2() {
        let task1 = BlockOperation {
            print("Task 1")
        }
        let task2 = BlockOperation {
            print("Task 2")
        }
        let concurrentOperationQueue = OperationQueue()
        concurrentOperationQueue.maxConcurrentOperationCount = 2
        let tasks = [task1, task2]
        concurrentOperationQueue.addOperations(tasks, waitUntilFinished: false)
    }

    func operationDependency() {

        let task1 = BlockOperation {
            print("Task 1")
        }
        let task2 = BlockOperation {
            print("Task 2")
        }
        let taskCombine = BlockOperation {
            print("taskCombine")
        }
        taskCombine.addDependency(task1)
        taskCombine.addDependency(task2)
        let operationQueue = OperationQueue()
        operationQueue.maxConcurrentOperationCount = 2
        let tasks = [task1, task2, taskCombine]
        operationQueue.addOperations(tasks, waitUntilFinished: false)
    }

    // MARK: - Operations


}

// Questions 
//someQueue.async { // Thread 7
//    someQueue.sync { // Thread 7
//        // concurrent -  No dead lock
//        // serial -  No dead lock
//    }
//}



