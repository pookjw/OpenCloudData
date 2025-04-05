//
//  OCCKRecordMetadata.h
//  OpenCloudData
//
//  Created by Jinwoo Kim on 4/5/25.
//

#import <CoreData/CoreData.h>
#import <OpenCloudData/OCCKRecordZoneMoveReceipt.h>

NS_ASSUME_NONNULL_BEGIN

#warning TODO moveReceipts
// direct method 있음

@class OCCKRecordZoneMetadata;

@interface OCCKRecordMetadata : NSManagedObject
@property (retain, nonatomic) NSString *ckRecordName;
@property (retain, nonatomic, nullable) NSData *ckRecordSystemFields;
@property (retain, nonatomic, nullable) NSData *encodedRecord;
@property (retain, nonatomic) NSNumber *entityId;
@property (retain, nonatomic) NSNumber *entityPK;
@property (retain, nonatomic, nullable) NSData *ckShare;
@property (retain, nonatomic) OCCKRecordZoneMetadata *recordZone;
@property (nonatomic) BOOL needsUpload;
@property (nonatomic) BOOL needsLocalDelete;
@property (nonatomic) BOOL needsCloudDelete;
@property (retain, nonatomic, nullable) NSNumber *lastExportedTransactionNumber;
@property (retain, nonatomic, nullable) NSNumber *pendingExportTransactionNumber;
@property (retain, nonatomic, nullable) NSNumber *pendingExportChangeTypeNumber;
@property (retain, nonatomic, nullable) NSSet<OCCKRecordZoneMoveReceipt *> *moveReceipts;
@end

NS_ASSUME_NONNULL_END
