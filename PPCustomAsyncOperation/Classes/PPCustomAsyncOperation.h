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
typedef void(^PPCustomAsyncOperationTimeoutBlock)(PPCustomAsyncOperation *operation);

@interface PPCustomAsyncOperation : NSOperation

@property (nonatomic, copy) NSString *identifier;

/// 任务超时自动结束, 步长为1, 默认 为0或者负数, 如果设置>0, 那么该时长后, 任务自动结束
@property (nonatomic, assign) NSTimeInterval timeoutInterval;
/// 超时结束任务之前的回调
@property (nonatomic, copy) PPCustomAsyncOperationTimeoutBlock timeoutBlock;

/// what you do in operation. You must call - (void)finishOperation to finish the operation if return NO.
/// "No" for async, "YES" for sync.
@property (nonatomic, copy) PPCustomAsyncOperationMainBlock mainOperationDoBlock;

/// 便捷构造，指定标识、超时与主任务执行块
- (instancetype)initWithIdentifier:(NSString *)identifier
                   timeoutInterval:(NSTimeInterval)timeoutInterval
                         mainBlock:(PPCustomAsyncOperationMainBlock)mainBlock;

/// 开始/结束时间与耗时（秒）
@property (nonatomic, strong, readonly) NSDate *startDate;
@property (nonatomic, strong, readonly, nullable) NSDate *finishDate;
@property (nonatomic, assign, readonly) NSTimeInterval duration;

/// 将要结束任务
@property (nonatomic, copy) void(^willFinishBlock)(PPCustomAsyncOperation *operation);
/// 已经结束任务（will 之后，状态已变更）
@property (nonatomic, copy, nullable) void(^didFinishBlock)(PPCustomAsyncOperation *operation);
/// 手动结束任务
- (void)finishOperation;

@end

NS_ASSUME_NONNULL_END
