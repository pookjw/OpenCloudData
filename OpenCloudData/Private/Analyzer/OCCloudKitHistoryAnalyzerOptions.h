//
//  OCCloudKitHistoryAnalyzerOptions.h
//  OpenCloudData
//
//  Created by Jinwoo Kim on 4/20/25.
//

#import <OpenCloudData/PFHistoryAnalyzerOptions.h>
#import <OpenCloudData/OCCloudKitMirroringRequest.h>

NS_ASSUME_NONNULL_BEGIN

#warning TODO

@interface OCCloudKitHistoryAnalyzerOptions : NSObject /* PFHistoryAnalyzerOptions */
//{
//    BOOL _includePrivateTransactions; // 0x21
//    OCCloudKitMirroringRequest * _Nullable _request; // 0x28
//}
@property (assign, nonatomic, direct) BOOL includePrivateTransactions;
@property (retain, nonatomic, nullable, direct) OCCloudKitMirroringRequest *request;
@end

NS_ASSUME_NONNULL_END
