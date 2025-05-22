//
//  PFHistoryAnalyzerOptions.h
//  OpenCloudData
//
//  Created by Jinwoo Kim on 4/20/25.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

@interface PFHistoryAnalyzerOptions : NSObject <NSCopying> {
@private BOOL _automaticallyPruneTransientRecords; // 0x8
@private NSUInteger _transactionLimit; // 0x10
@private size_t _contextMemoryLimitBytes; // 0x18
}
@end

NS_ASSUME_NONNULL_END
