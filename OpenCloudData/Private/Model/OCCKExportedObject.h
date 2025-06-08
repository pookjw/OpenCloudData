//
//  OCCKExportedObject.h
//  OpenCloudData
//
//  Created by Jinwoo Kim on 6/8/25.
//

#import <CoreData/CoreData.h>

NS_ASSUME_NONNULL_BEGIN

@class OCCKExportOperation;

@interface OCCKExportedObject : NSManagedObject
@property (class, readonly, nonatomic) NSString* entityPath;
@property (retain, nonatomic, nullable) NSNumber *changeTypeNum;
@property (retain, nonatomic, nullable) NSNumber *typeNum;
@property (retain, nonatomic, nullable) NSString *ckRecordName;
@property (retain, nonatomic, nullable) NSString *zoneName; 
@property (nonatomic) int64_t changeType;
@property (nonatomic) int64_t type;
@property (retain, nonatomic, nullable) OCCKExportOperation* operation;
@end

NS_ASSUME_NONNULL_END
