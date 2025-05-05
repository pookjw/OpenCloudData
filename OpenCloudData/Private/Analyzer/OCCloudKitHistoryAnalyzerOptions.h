//
//  OCCloudKitHistoryAnalyzerOptions.h
//  OpenCloudData
//
//  Created by Jinwoo Kim on 4/20/25.
//

#import <OpenCloudData/PFHistoryAnalyzerOptions.h>
#import <OpenCloudData/OCCloudKitMirroringRequest.h>

NS_ASSUME_NONNULL_BEGIN

@interface OCCloudKitHistoryAnalyzerOptions : NSObject <NSCopying> /* PFHistoryAnalyzerOptions */
//{
//    BOOL _includePrivateTransactions; // 0x21
//    OCCloudKitMirroringRequest * _Nullable _request; // 0x28
//}
@property (assign, nonatomic, direct) BOOL includePrivateTransactions;
@property (retain, nonatomic, nullable, direct) OCCloudKitMirroringRequest *request;
@end

extern void _OCCloudKitHistoryAnalyzerOptions_setIncludePrivateTransactions_(OCCloudKitHistoryAnalyzerOptions *self, BOOL value);
extern BOOL _OCCloudKitHistoryAnalyzerOptions_includePrivateTransactions_(OCCloudKitHistoryAnalyzerOptions *self);
extern void _OCCloudKitHistoryAnalyzerOptions_setRequest_(OCCloudKitHistoryAnalyzerOptions *self, OCCloudKitMirroringRequest * _Nullable value);
extern OCCloudKitMirroringRequest * _Nullable _OCCloudKitHistoryAnalyzerOptions_request(OCCloudKitHistoryAnalyzerOptions *self);

NS_ASSUME_NONNULL_END
