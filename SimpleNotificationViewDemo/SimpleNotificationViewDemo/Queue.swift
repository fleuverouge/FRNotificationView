//
//  Queue.swift
//  StreamBitrate
//
//  Created by Do Thi Hong Ha on 1/7/16.
//  Copyright © 2016 Yotel. All rights reserved.
//

import Foundation

protocol ExcutableQueue {
    var queue: dispatch_queue_t { get }
}

extension ExcutableQueue {
    func execute(after timerInterval: UInt64 = 0, closure: () -> Void) {
        if (timerInterval != 0) {
            dispatch_after(dispatch_time(DISPATCH_TIME_NOW, Int64(timerInterval * NSEC_PER_SEC)), queue, closure)
        }
        else {
            dispatch_async(queue, closure)
        }
    }
}

enum Queue: ExcutableQueue {
    case Main
    case UserInteractive
    case UserInitiated
    case Utility
    case Background
    
    var queue: dispatch_queue_t {
        switch self {
        case .Main:
            // tasks in this queue execute one at a time. However, it’s guaranteed that all tasks will execute on the main thread, which is the only thread allowed to update your UI. This queue is the one to use for sending messages to UIView objects or posting notifications.
            return dispatch_get_main_queue()
        case .UserInteractive:
            // tasks that need to be done immediately in order to provide a nice user experience. Use it for UI updates, event handling and small workloads that require low latency. The total amount of work done in this class during the execution of your app should be small.
            if #available(iOS 8.0, *) {
                return dispatch_get_global_queue(QOS_CLASS_USER_INTERACTIVE, 0)
            } else {
                // Fallback on earlier versions
                return dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_HIGH, 0)
            }
        case .UserInitiated:
            // tasks that are initiated from the UI and can be performed asynchronously. It should be used when the user is waiting for immediate results, and for tasks required to continue user interaction.
            if #available(iOS 8.0, *) {
                return dispatch_get_global_queue(QOS_CLASS_USER_INITIATED, 0)
            } else {
                // Fallback on earlier versions
                return dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0)
            }
        case .Utility:
            // long-running tasks, typically with a user-visible progress indicator. Use it for computations, I/O, networking, continous data feeds and similar tasks. This class is designed to be energy efficient.
            if #available(iOS 8.0, *) {
                return dispatch_get_global_queue(QOS_CLASS_UTILITY, 0)
            } else {
                // Fallback on earlier versions
                return dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_LOW, 0)
            }
        case .Background:
            // tasks that the user is not directly aware of. Use it for prefetching, maintenance, and other tasks that don’t require user interaction and aren’t time-sensitive
            if #available(iOS 8.0, *) {
                return dispatch_get_global_queue(QOS_CLASS_BACKGROUND, 0)
            }
            else {
                return dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_BACKGROUND, 0)
            }
        }
    }
}