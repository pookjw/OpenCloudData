//
//  OCCKExportOperation.h
//  OpenCloudData
//
//  Created by Jinwoo Kim on 6/8/25.
//

#import <CoreData/CoreData.h>
#import "OpenCloudData/Private/Model/OCCKExportedObject.h"

NS_ASSUME_NONNULL_BEGIN

@class OCCKExportMetadata;

@interface OCCKExportOperation : NSManagedObject
@property (class, readonly, nonatomic) NSString *entityPath;
@property (retain, nonatomic, nullable) NSNumber *statusNum;
@property (retain, nonatomic, nullable) NSString *identifier;
@property (retain, nonatomic, nullable) OCCKExportMetadata *exportMetadata;
@property (nonatomic) int64_t status;
@property (retain, nonatomic, nullable) NSSet<OCCKExportedObject *> *objects;
@end

NS_ASSUME_NONNULL_END
