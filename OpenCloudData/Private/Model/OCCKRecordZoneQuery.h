//
//  OCCKRecordZoneQuery.h
//  OpenCloudData
//
//  Created by Jinwoo Kim on 4/6/25.
//

#import <CloudKit/CloudKit.h>
#import <CoreData/CoreData.h>

NS_ASSUME_NONNULL_BEGIN

@class OCCKRecordZoneMetadata;

@interface OCCKRecordZoneQuery : NSManagedObject
@property (retain, nonatomic) OCCKRecordZoneMetadata *recordZone;
@property (retain, nonatomic) NSString *recordType;
@property (retain, nonatomic, nullable) NSDate *lastFetchDate;
@property (retain, nonatomic, nullable) NSDate *mostRecentRecordModificationDate;
@property (retain, nonatomic, nullable) NSPredicate* predicate;
@property (retain, nonatomic, nullable) CKQueryCursor* queryCursor;
@end

NS_ASSUME_NONNULL_END
