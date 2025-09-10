//
//  PPCustomOperationQueue.m
//  PPCustomAsyncOperation
//
//  Created by pengpeng on 2024/1/22.
//

#import "PPCustomOperationQueue.h"

@implementation PPCustomOperationQueue

- (void)dealloc {
    @try {
        [self removeObserver:self forKeyPath:@"operationCount"];
    } @catch (__unused NSException *exception) {
        // ignore if not registered
    }
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

- (PPCustomAsyncOperation *)addOperationWithIdentifier:(NSString *)identifier
                                     timeoutInterval:(NSTimeInterval)timeoutInterval
                                          mainBlock:(PPCustomAsyncOperationMainBlock)block {
    PPCustomAsyncOperation *operation = [[PPCustomAsyncOperation alloc] initWithIdentifier:identifier
                                                                         timeoutInterval:timeoutInterval
                                                                               mainBlock:block];
    [self addOperation:operation];
    return operation;
}

- (nullable PPCustomAsyncOperation *)operationForIdentifier:(NSString *)identifier {
    if (identifier.length == 0) { return nil; }
    for (NSOperation *op in self.operations) {
        if (![op isKindOfClass:[PPCustomAsyncOperation class]]) { continue; }
        PPCustomAsyncOperation *aop = (PPCustomAsyncOperation *)op;
        if ([aop.identifier isEqualToString:identifier]) {
            return aop;
        }
    }
    return nil;
}

- (BOOL)cancelOperationForIdentifier:(NSString *)identifier {
    PPCustomAsyncOperation *op = [self operationForIdentifier:identifier];
    if (!op) { return NO; }
    [op cancel];
    return YES;
}

- (void)pause {
    self.suspended = YES;
}

- (void)resume {
    self.suspended = NO;
}

@end
