//
//  PPCustomAsyncOperation.m
//  PPCustomAsyncOperation
//
//  Created by pengpeng on 2024/1/22.
//

#import "PPCustomAsyncOperation.h"

@interface PPCustomAsyncOperation ()

@property(nonatomic, assign, readonly) BOOL hasStart;

@property(nonatomic, assign) BOOL operationExecuting;
@property(nonatomic, assign) BOOL operationFinished;

/// 超时的计数器, 步长为1
@property (nonatomic, assign) NSTimeInterval timeoutCount;
@property (nonatomic, strong, nullable) NSTimer *timeoutTimer;

@end

@implementation PPCustomAsyncOperation

#pragma mark - 重写系统方法

- (void)start {
    _hasStart = YES;
    if ([self isCancelled]) {
        [self signKVOComplete];
        return;
    }

    // If the operation is not canceled, begin executing the task.
    [self willChangeValueForKey:@"isExecuting"];
    [NSThread detachNewThreadSelector:@selector(main)
                             toTarget:self withObject:nil];
    self.operationExecuting = YES;
    [self didChangeValueForKey:@"isExecuting"];
}

- (void)main {
    @autoreleasepool {
        if (self.isCancelled) {
            return;
        }

        if (self.mainOperationDoBlock(self)) {
            NSLog(@"======== %@, identifier: %@ 同步任务已完成", NSStringFromClass([self class]), self.identifier);
            [self finishOperation];
        } else {
            // 判断超时
            if (self.timeoutInterval <= 0) {
                NSLog(@"======== %@, identifier: %@ 异步任务已启动, 未设置超时检测", NSStringFromClass([self class]), self.identifier);
                return;
            }

            NSLog(@"======== %@, identifier: %@ 异步任务已启动, 开启超时检测: %.0f", NSStringFromClass([self class]), self.identifier, self.timeoutInterval);

            [self.timeoutTimer invalidate];
            self.timeoutCount = 0;
            self.timeoutTimer = [NSTimer timerWithTimeInterval:1 target:self selector:@selector(timeoutTimerAction:) userInfo:nil repeats:YES];
            [[NSRunLoop mainRunLoop] addTimer:self.timeoutTimer forMode:NSRunLoopCommonModes];
        }
    }
}

- (void)timeoutTimerAction:(NSTimer *)timer {
    self.timeoutCount += 1;
    if (self.timeoutCount >= self.timeoutInterval) {
        NSLog(@"======== %@, identifier: %@ 已超时, 即将自动结束", NSStringFromClass([self class]), self.identifier);
        [self finishOperation];
    } else {
        NSLog(@"======== %@, identifier: %@ 计时中: %.0f", NSStringFromClass([self class]), self.identifier, self.timeoutCount);
    }
}

- (void)releaseTimer {
    self.timeoutCount = 0;
    [self.timeoutTimer invalidate];
    self.timeoutTimer = nil;
}

- (BOOL)isConcurrent {
    return YES;
}

- (BOOL)isExecuting {
    if (self.operationExecuting) {
        NSLog(@"---------%@ Start---------", NSStringFromClass([self class]));
    }
    return self.operationExecuting;
}

- (BOOL)isFinished {
    if (self.operationFinished) {
        NSLog(@"---------%@ End---------", NSStringFromClass([self class]));
    }
    return self.operationFinished;
}

- (void)cancel {
    @synchronized (self) {
        [super cancel];

        [self releaseTimer];
        if ([self isExecuting]) {
            [self finishOperation];
        }
    }
}

#pragma mark - 自定义方法

- (void)finishOperation {
    @synchronized (self) {
        [self releaseTimer];
        if (!self.operationExecuting && self.operationFinished) {
            return;
        }

        if (_hasStart) {
            [self signKVOComplete];
        } else {
            [self cancel];
        }
    }
}

- (void)signKVOComplete {
    [self willChangeValueForKey:@"isFinished"];
    [self willChangeValueForKey:@"isExecuting"];

    self.operationExecuting = NO;
    self.operationFinished = YES;

    [self didChangeValueForKey:@"isExecuting"];
    [self didChangeValueForKey:@"isFinished"];
}

- (void)dealloc {
    NSLog(@"===== %@ dealloc; identifier: %@ ======", NSStringFromClass([self class]), self.identifier);
}

@end
