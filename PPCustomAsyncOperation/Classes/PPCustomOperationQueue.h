//
//  PPCustomOperationQueue.h
//  PPCustomAsyncOperation
//
//  Created by pengpeng on 2024/1/22.
//

#import <Foundation/Foundation.h>
#import "PPCustomAsyncOperation.h"

NS_ASSUME_NONNULL_BEGIN

@interface PPCustomOperationQueue : NSOperationQueue

- (void)addOperationWithIdentifier:(NSString *)identifier operationMainBlock:(PPCustomAsyncOperationMainBlock)block;

/// 便捷添加：带超时
- (PPCustomAsyncOperation *)addOperationWithIdentifier:(NSString *)identifier
                                     timeoutInterval:(NSTimeInterval)timeoutInterval
                                          mainBlock:(PPCustomAsyncOperationMainBlock)block;

/// 根据 identifier 查找/取消
- (nullable PPCustomAsyncOperation *)operationForIdentifier:(NSString *)identifier;
- (BOOL)cancelOperationForIdentifier:(NSString *)identifier;

/// 暂停与恢复队列
- (void)pause;
- (void)resume;

@property (nonatomic, copy) void(^didFinishedOperationsBlock)(PPCustomOperationQueue *queue);

@end

NS_ASSUME_NONNULL_END
