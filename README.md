# PPCustomAsyncOperation

[![CI Status](https://img.shields.io/travis/pengpeng/PPCustomAsyncOperation.svg?style=flat)](https://travis-ci.org/pengpeng/PPCustomAsyncOperation)
[![Version](https://img.shields.io/cocoapods/v/PPCustomAsyncOperation.svg?style=flat)](https://cocoapods.org/pods/PPCustomAsyncOperation)
[![License](https://img.shields.io/cocoapods/l/PPCustomAsyncOperation.svg?style=flat)](https://cocoapods.org/pods/PPCustomAsyncOperation)
[![Platform](https://img.shields.io/cocoapods/p/PPCustomAsyncOperation.svg?style=flat)](https://cocoapods.org/pods/PPCustomAsyncOperation)

## Example

To run the example project, clone the repo, and run `pod install` from the Example directory first.

### 使用queue
导入头文件`#import <PPCustomAsyncOperation/PPCustomOperationQueue.h>`
### 只使用operation
导入头文件`#import <PPCustomAsyncOperation/PPCustomAsyncOperation.h>`

* 正常创建queue和operation
* 同步的任务, 直接`operation.mainOperationDoBlock`中`return YES;`
* 然后如果是异步的`operation`, 可以在`operation.mainOperationDoBlock`中返回NO, 并在合适的时候, 手动结束operation, 调用`[operation finishOperation];`
* 具体的看`Example`

### 新增能力（>= 0.1.4）

- Operation：
  - 便捷构造 `initWithIdentifier:timeoutInterval:mainBlock:`
  - `willFinishBlock` 与 `didFinishBlock`（完成前/完成后回调）
  - 判空保护：未设置 `mainOperationDoBlock` 视为同步完成
  - 时间戳与耗时：`startDate`、`finishDate`、`duration`
  - 支持 `isAsynchronous`（兼容新 API）
- Queue：
  - `addOperationWithIdentifier:timeoutInterval:mainBlock:` 返回创建的 operation
  - `operationForIdentifier:` 与 `cancelOperationForIdentifier:`
  - `pause` / `resume` 快捷方法

### 最小示例（Operation）

```objc
PPCustomAsyncOperation *op = [[PPCustomAsyncOperation alloc] initWithIdentifier:@"demo"
                                                              timeoutInterval:5
                                                                    mainBlock:^BOOL(PPCustomAsyncOperation * _Nonnull operation) {
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(2 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
        [operation finishOperation];
    });
    return NO; // 异步
}];
op.willFinishBlock = ^(PPCustomAsyncOperation * _Nonnull op) {
    NSLog(@"willFinish: %@, duration: %.2f", op.identifier, op.duration);
};
op.didFinishBlock = ^(PPCustomAsyncOperation * _Nonnull op) {
    NSLog(@"didFinish: %@, duration: %.2f", op.identifier, op.duration);
};
```

### 最小示例（Queue）

```objc
PPCustomOperationQueue *queue = [[PPCustomOperationQueue alloc] init];
[queue addOperationWithIdentifier:@"task_1" timeoutInterval:3 mainBlock:^BOOL(PPCustomAsyncOperation * _Nonnull operation) {
    return YES; // 同步
}];

PPCustomAsyncOperation *task2 = [queue addOperationWithIdentifier:@"task_2" timeoutInterval:5 mainBlock:^BOOL(PPCustomAsyncOperation * _Nonnull operation) {
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(1 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
        [operation finishOperation];
    });
    return NO;
}];
task2.timeoutBlock = ^(PPCustomAsyncOperation * _Nonnull op) {
    NSLog(@"timeout: %@", op.identifier);
};
```

```
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
```

## Requirements

## Installation

PPCustomAsyncOperation is available through [CocoaPods](https://cocoapods.org). To install
it, simply add the following line to your Podfile:

```ruby
pod 'PPCustomAsyncOperation'
```

## Author

pengpeng, garenge@outlook.com

## License

PPCustomAsyncOperation is available under the MIT license. See the LICENSE file for more info.
