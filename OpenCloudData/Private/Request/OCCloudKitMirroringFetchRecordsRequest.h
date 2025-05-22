//
//  OCCloudKitMirroringFetchRecordsRequest.h
//  OpenCloudData
//
//  Created by Jinwoo Kim on 5/14/25.
//

#import "OpenCloudData/Private/Request/OCCloudKitMirroringImportRequest.h"
#import "OpenCloudData/SPI/CoreData/NSSQLCore.h"

NS_ASSUME_NONNULL_BEGIN

@interface OCCloudKitMirroringFetchRecordsRequest : OCCloudKitMirroringImportRequest {
    NSArray<NSManagedObjectID *> *_objectIDsToFetch; // 0x50
    NSDictionary<NSString *, NSArray<NSAttributeDescription *> *> *_entityNameToAttributesToFetch; // 0x58
    NSDictionary<NSString *, NSArray<NSString *> *> *_entityNameToAttributeNamesToFetch; // 0x60
    BOOL _editable; // 0x68
    NSUInteger _perOperationObjectThreshold; // 0x70
}
@property (copy, nonatomic, readonly) NSDictionary<NSString *, NSArray<NSAttributeDescription *> *>* entityNameToAttributesToFetch;
@property (copy, nonatomic) NSArray<NSManagedObjectID *> *objectIDsToFetch;
@property (assign, nonatomic, direct) NSUInteger perOperationObjectThreshold;
- (void)throwNotEditable:(SEL)aSEL __attribute__((objc_direct));
- (BOOL)validateForUseWithStore:(NSSQLCore *)store error:(NSError * _Nullable * _Nullable)error;
@end

NS_ASSUME_NONNULL_END
