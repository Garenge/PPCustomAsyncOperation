//
//  PPCustomOperationQueue.m
//  PPCustomAsyncOperation
//
//  Created by pengpeng on 2024/1/22.
//

#import "PPCustomOperationQueue.h"

@implementation PPCustomOperationQueue

- (void)dealloc {
    [self removeObserver:self forKeyPath:@"operationCount"];
    NSLog(@"PPCustomOperationQueue dealloc");
}

- (instancetype)init {
    if (self = [super init]) {
        self.maxConcurrentOperationCount = 1;
        [self addObserver:self forKeyPath:@"operationCount" options:NSKeyValueObservingOptionNew context:nil];
    }
    return self;
}

- (void)observeValueForKeyPath:(NSString *)keyPath
                      ofObject:(PPCustomOperationQueue *)object
                        change:(NSDictionary<NSKeyValueChangeKey,id> *)change
                       context:(void *)context {
    if ([keyPath isEqualToString:@"operationCount"]) {
        if (self.operationCount == 0) {
            if (self.didFinishedOperationsBlock) {
                self.didFinishedOperationsBlock(self);
            }
        }
    }
}

- (void)addOperationWithIdentifier:(NSString *)identifier operationMainBlock:(PPCustomAsyncOperationMainBlock)block {
    PPCustomAsyncOperation *operation = [[PPCustomAsyncOperation alloc] init];
    operation.identifier = identifier;
    operation.mainOperationDoBlock = block;
    [self addOperation:operation];
}

@end
