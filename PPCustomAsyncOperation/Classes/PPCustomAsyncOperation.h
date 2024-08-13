//
//  PPCustomAsyncOperation.h
//  PPCustomAsyncOperation
//
//  Created by pengpeng on 2024/1/22.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN
@class PPCustomAsyncOperation;
typedef BOOL(^PPCustomAsyncOperationMainBlock)(PPCustomAsyncOperation *operation);
@interface PPCustomAsyncOperation : NSOperation

@property (nonatomic, strong) NSString *identifier;

/// 任务超时自动结束, 步长为1, 默认 为0或者负数, 如果设置>0, 那么该时长后, 任务自动结束
@property (nonatomic, assign) NSTimeInterval timeoutInterval;

/// 手动结束任务
- (void)finishOperation;

/// what you do in operation. You must call - (void)finishOperation to finish the operation if return NO.
/// "No" for async, "YES" for sync.
@property (nonatomic, copy) PPCustomAsyncOperationMainBlock mainOperationDoBlock;

@end

NS_ASSUME_NONNULL_END
