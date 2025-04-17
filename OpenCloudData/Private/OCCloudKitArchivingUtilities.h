//
//  OCCloudKitArchivingUtilities.h
//  OpenCloudData
//
//  Created by Jinwoo Kim on 4/17/25.
//

#import <CloudKit/CloudKit.h>

NS_ASSUME_NONNULL_BEGIN

#warning TODO

@interface OCCloudKitArchivingUtilities : NSObject
- (CKShare * _Nullable)shareFromEncodedData:(NSData *)encodedShareData inZoneWithID:(CKRecordZoneID *)zoneID error:(NSError * _Nullable * _Nullable)error NS_RETURNS_RETAINED __attribute__((objc_direct));
@end

NS_ASSUME_NONNULL_END
