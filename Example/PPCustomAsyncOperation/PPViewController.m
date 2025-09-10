//
//  PPViewController.m
//  PPCustomAsyncOperation
//
//  Created by pengpeng on 01/22/2024.
//  Copyright (c) 2024 pengpeng. All rights reserved.
//

#import "PPViewController.h"
#import <PPCustomAsyncOperation/PPCustomOperationQueue.h>

@interface PPViewController ()

@property (nonatomic, strong, nullable) PPCustomOperationQueue *queue;

@property (nonatomic, strong) NSString *demoOpId;

@end

@implementation PPViewController

- (void)viewDidLoad
{
    [super viewDidLoad];PPCustomOperationQueue *queue = [[PPCustomOperationQueue alloc] init];
    queue.maxConcurrentOperationCount = 1;

    self.queue = queue;
    __weak typeof(self) weakSelf = self;
    self.queue.didFinishedOperationsBlock = ^(PPCustomOperationQueue * _Nonnull queue) {
        NSLog(@"queue finished all operations");
        // 保留队列实例，方便后续按钮继续使用；如需释放可在内存告警时置空
        (void)weakSelf; // 保持弱引用不产生警告
    };

    [self runSimpleDemo];

    // Demo 控制按钮
    UIButton *addBtn = [UIButton buttonWithType:UIButtonTypeSystem];
    [addBtn setTitle:@"添加任务" forState:UIControlStateNormal];
    addBtn.frame = CGRectMake(20, 100, 100, 40);
    [addBtn addTarget:self action:@selector(onTapAdd) forControlEvents:UIControlEventTouchUpInside];
    [self.view addSubview:addBtn];

    UIButton *cancelBtn = [UIButton buttonWithType:UIButtonTypeSystem];
    [cancelBtn setTitle:@"取消任务" forState:UIControlStateNormal];
    cancelBtn.frame = CGRectMake(140, 100, 100, 40);
    [cancelBtn addTarget:self action:@selector(onTapCancel) forControlEvents:UIControlEventTouchUpInside];
    [self.view addSubview:cancelBtn];

    UIButton *pauseBtn = [UIButton buttonWithType:UIButtonTypeSystem];
    [pauseBtn setTitle:@"暂停队列" forState:UIControlStateNormal];
    pauseBtn.frame = CGRectMake(260, 100, 100, 40);
    [pauseBtn addTarget:self action:@selector(onTapPauseOrResume:) forControlEvents:UIControlEventTouchUpInside];
    [self.view addSubview:pauseBtn];
}

- (void)createOperations {
    for (NSInteger index = 0; index < 20; index ++) {

        PPCustomAsyncOperation *operation = [[PPCustomAsyncOperation alloc] init];
        operation.identifier = [NSString stringWithFormat:@"ide_%ld", index];

        operation.mainOperationDoBlock = ^BOOL(PPCustomAsyncOperation * _Nonnull operation) {

            if (index % 2 == 0) {

                dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(0.5 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
                    NSLog(@"operation: %ld", index);
                    [operation finishOperation];
                });

                return NO;
            } else {
                NSLog(@"operation: %ld", index);
                return YES;
            }
        };

        [self.queue addOperation:operation];
    }
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)runSimpleDemo {
    // 正常完成的异步任务：2 秒后主动完成
    PPCustomAsyncOperation *normal = [[PPCustomAsyncOperation alloc] initWithIdentifier:@"normal_async"
                                                                      timeoutInterval:10
                                                                            mainBlock:^BOOL(PPCustomAsyncOperation * _Nonnull operation) {
        dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(2 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
            NSLog(@"normal finish");
            [operation finishOperation];
        });
        return NO;
    }];
    normal.willFinishBlock = ^(PPCustomAsyncOperation * _Nonnull op) {
        NSLog(@"willFinish: %@, duration: %.2f", op.identifier, op.duration);
    };
    normal.didFinishBlock = ^(PPCustomAsyncOperation * _Nonnull op) {
        NSLog(@"didFinish: %@, duration: %.2f", op.identifier, op.duration);
    };

    // 会触发超时自动完成的任务：不主动调用 finish
    PPCustomAsyncOperation *willTimeout = [[PPCustomAsyncOperation alloc] initWithIdentifier:@"will_timeout"
                                                                           timeoutInterval:3
                                                                                 mainBlock:^BOOL(PPCustomAsyncOperation * _Nonnull operation) {
        NSLog(@"start will_timeout but not finishing explicitly");
        return NO;
    }];
    willTimeout.timeoutBlock = ^(PPCustomAsyncOperation * _Nonnull op) {
        NSLog(@"timeout about to finish: %@", op.identifier);
    };
    willTimeout.willFinishBlock = ^(PPCustomAsyncOperation * _Nonnull op) {
        NSLog(@"willFinish: %@, duration: %.2f", op.identifier, op.duration);
    };
    willTimeout.didFinishBlock = ^(PPCustomAsyncOperation * _Nonnull op) {
        NSLog(@"didFinish: %@, duration: %.2f", op.identifier, op.duration);
    };

    [self.queue addOperation:normal];
    [self.queue addOperation:willTimeout];
}

#pragma mark - Demo Actions

- (void)onTapAdd {
    // 使用队列便捷方法添加一个 5 秒超时的任务
    if (!self.queue) {
        self.queue = [[PPCustomOperationQueue alloc] init];
        self.queue.maxConcurrentOperationCount = 1;
    }
    NSString *identifier = [NSString stringWithFormat:@"btn_task_%@", @([[NSDate date] timeIntervalSince1970])];
    self.demoOpId = identifier;
    PPCustomAsyncOperation *op = [self.queue addOperationWithIdentifier:identifier
                                                      timeoutInterval:5
                                                           mainBlock:^BOOL(PPCustomAsyncOperation * _Nonnull operation) {
        NSLog(@"start %@", operation.identifier);
        dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(2 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
            NSLog(@"finish %@", operation.identifier);
            [operation finishOperation];
        });
        return NO;
    }];
    op.willFinishBlock = ^(PPCustomAsyncOperation * _Nonnull op) {
        NSLog(@"willFinish: %@, duration: %.2f", op.identifier, op.duration);
    };
    op.didFinishBlock = ^(PPCustomAsyncOperation * _Nonnull op) {
        NSLog(@"didFinish: %@, duration: %.2f", op.identifier, op.duration);
    };
}

- (void)onTapCancel {
    if (!self.queue) {
        NSLog(@"queue not ready");
        return;
    }
    if (self.demoOpId.length == 0) {
        NSLog(@"no demoOpId to cancel");
        return;
    }
    BOOL ok = [self.queue cancelOperationForIdentifier:self.demoOpId];
    NSLog(@"cancel %@ -> %@", self.demoOpId, ok ? @"YES" : @"NO");
}

- (void)onTapPauseOrResume:(UIButton *)sender {
    if (!self.queue) { return; }
    if (self.queue.suspended) {
        [self.queue resume];
        [sender setTitle:@"暂停队列" forState:UIControlStateNormal];
        NSLog(@"queue resumed");
    } else {
        [self.queue pause];
        [sender setTitle:@"恢复队列" forState:UIControlStateNormal];
        NSLog(@"queue paused");
    }
}

@end
