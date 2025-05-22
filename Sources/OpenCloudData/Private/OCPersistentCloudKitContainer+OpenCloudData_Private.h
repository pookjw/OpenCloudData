//
//  OCPersistentCloudKitContainer+OpenCloudData_Private.h
//  OpenCloudData
//
//  Created by Jinwoo Kim on 3/30/25.
//

#import "OpenCloudData/Public/OCPersistentCloudKitContainer.h"
#import "OpenCloudData/Private/OCCloudKitMirroringDelegateProgressProvider.h"
#import "OpenCloudData/Private/OCPersistentCloudKitContainerActivityVoucher.h"

NS_ASSUME_NONNULL_BEGIN

@interface OCPersistentCloudKitContainer (OpenCloudData_Private) <OCCloudKitMirroringDelegateProgressProvider>
- (void)applyActivityVoucher:(OCPersistentCloudKitContainerActivityVoucher *)activityVoucher toStores:(NSArray<__kindof NSPersistentStore *> * /* not verified */)stores;
- (void)expireActivityVoucher:(OCPersistentCloudKitContainerActivityVoucher *)activityVoucher;
- (BOOL)assignManagedObjects:(NSArray<NSManagedObject *> *)managedObjects toCloudKitRecordZone:(CKRecordZone *)cloudKitRecordZone inPersistentStore:(__kindof NSPersistentStore *)persistentStore error:(NSError * _Nullable * _Nullable)error;
- (void)doWorkOnMetadataContext:(BOOL)asynchronous withBlock:(void (^)(NSManagedObjectContext * metadataContext))block __attribute__((objc_direct));
@end

NS_ASSUME_NONNULL_END
