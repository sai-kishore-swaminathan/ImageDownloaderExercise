//
//  Notes.swift
//  TestProject
//
//  Created by Sai Kishore Swaminathan on 15/10/22.
//

import Foundation


// MARK: - Todo

/*
 - Make URLCell as Struct - ✅
 - Abstract solutions ( Use Image Downloader ) - ✅
 - Use same class with same function - ✅

---------------------------------------------------------------------------
 - Make Dictionary state thread safe with Locks  ( LOCK ) - 2 Hours ✅
 - Fix Async Await - ✅
 - Explore Cancellation Options - GCD / Operations / Async Await - 2 Hours
 - How to Notify the user about completion when you use operation queue (operationCount) - 2 Hours ✅ ( Added Dependency )


 // Lower Priority
 - Make output as an array
 - Always think about multiple ViewControllers accessing the states
 - Check weakbox
 - Read about class initializer
 - Watch Async Await developer videos / Documentations
 */


// MARK: - Critical section Concurrecy using GCD Serial Queue

class SafetyArraySerial<T> {
        var array = [T]()
        let serialQueue = DispatchQueue(label: "com.serial.queue")

    // Serial Queue executes items one after other
    // So if there is already some async writing happening in the queue,
    // Serial Sync will wait for the async to be completed and execute the sync task
    // But what if we have multiple reads ? everything will wait for the previous read to complete 🚩
    // Thus we are going to use the concurrent solution using barriers

    // KEY POINT - Read is not asynchronous
        var lastItem: T? {
            var result: T?
            self.serialQueue.sync {
                result = self.array.last
            }
            return result
        }

        func append(_ newElement: T) {
            self.serialQueue.async() {
                self.array.append(newElement)
            }
        }
    }

// MARK: - Critical section Concurrecy using Concurrent Queue

class SafeArrayConcurrent<T> {
        var array = [T]()
        let concurrentQueue = DispatchQueue(label: "com.uynguyen.queue", attributes: .concurrent)

    // So Like in the Previous solution we use read operation synchronously from concurrent queue
    // This means multiple read can happen in multiple threads in a synchronous way.
    // Sync waits for the task in the particular thread to be completed, before executing its own task
    // This means read can theoritically happen when some other thread is updating the value

    // Now we have to ensure write does not happen when a read is happeneing
    // For this we use Barriers, Barriers make Concurrent queue behave like serial queue
    // When other tasks are running in the barrier task, it will not execute itself, it will wait for completion.
    // It will not let other tasks run asynchoronously when its being executed because..
    // ..it will wait for all the tasks to be completed.
    // Thus when read is happening we will never execute a write task. ( Write is a barrier and waits for all tasks to be completed )
    // And when a write is happening we will not execute a read operation ( Write is a barrier which will not let other tasks happen at the same time )
    // And multiple reads can be achieved simultaneously because its a concurrent queue. Using sync will only affect the particular thread its written in.
    // Theoritically even using Async will result in the same result ???? ⁉️
    // But its better to call it synchronously to block the calling thread and obtain the result before moving on to the next section of the code
    // KEY POINT -  READ is Asynchornous, Write is sync

        var last: T? {
            var result: T?
            self.concurrentQueue.sync {
                result = self.array.last
            }
            return result
        }

        func append(_ newElement: T) {
            self.concurrentQueue.async(flags: .barrier) {
                self.array.append(newElement)
            }
        }
    }


// MARK: - Semaphores

// Can be used anywhere ( directly or with queues )
// Still have to wait for every read or write operations
// Can also be used with Concurrent queues but waiting cannot be avoided


//let dispatchSemaphore = DispatchSemaphore(value: 1)
// dispatchSemaphore.wait()
////  Perform update there.....
// dispatchSemaphore.signal()


// MARK: - Locks
// NSLock  and other locks wont solve the problem because it will block both read and write

//var myLock = NSLock()
//func setImage(img: UIImage) {
//    myLock.lock()
//    self.myImage = img
//    myLock.unlock()
//}


// MARK: - Pthread_rwlock_t
// Initialization of lock, pthread_rwlock_t is a value type , got to be var
// error prone cuz we have to init and destroy it
// GET MORE EXAMPLE 💿

//var lock = pthread_rwlock_t()
//pthread_rwlock_init(&lock, nil)
//
//// Protecting read section:
//pthread_rwlock_rdlock(&lock)
//// Read shared resource
//pthread_rwlock_unlock(&lock)
//
//// Protecting write section:
//pthread_rwlock_wrlock(&lock)
//// Write shared resource
//pthread_rwlock_unlock(&lock)
//
//// Clean up
//pthread_rwlock_destroy(&lock)



// REsources
//  Bench Marks GCD vs POSIX - https://dmytro-anokhin.medium.com/concurrency-in-swift-reader-writer-lock-4f255ae73422



// MARK: - Others

//// Read http://www.russbishop.net/the-law for more information on why this is necessary
//final class UnfairLock {
//    private var _lock: UnsafeMutablePointer<os_unfair_lock>
//
//    init() {
//        _lock = UnsafeMutablePointer<os_unfair_lock>.allocate(capacity: 1)
//        _lock.initialize(to: os_unfair_lock())
//    }
//
//    deinit {
//        _lock.deallocate()
//    }
//
//    func locked<ReturnValue>(_ f: () throws -> ReturnValue) rethrows -> ReturnValue {
//        os_unfair_lock_lock(_lock)
//        defer { os_unfair_lock_unlock(_lock) }
//        return try f()
//    }
//}
