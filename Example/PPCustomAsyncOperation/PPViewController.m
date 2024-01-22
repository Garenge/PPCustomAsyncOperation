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

@end

@implementation PPViewController

- (void)viewDidLoad
{
    [super viewDidLoad];PPCustomOperationQueue *queue = [[PPCustomOperationQueue alloc] init];
    queue.maxConcurrentOperationCount = 1;

    self.queue = queue;
    __weak typeof(self) weakSelf = self;
    self.queue.didFinishedOperationsBlock = ^(PPCustomOperationQueue * _Nonnull queue) {
        weakSelf.queue = nil;
    };
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

@end
