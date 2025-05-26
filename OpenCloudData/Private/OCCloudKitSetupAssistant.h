//
//  OCCloudKitSetupAssistant.h
//  OpenCloudData
//
//  Created by Jinwoo Kim on 5/26/25.
//

#import "OpenCloudData/Private/Request/OCCloudKitMirroringDelegateSetupRequest.h"
#import "OpenCloudData/Private/OCCloudKitMirroringDelegateOptions.h"
#import "OpenCloudData/Private/OCCloudKitStoreMonitor.h"
#import "OpenCloudData/Public/OCPersistentCloudKitContainerEvent.h"
#import "OpenCloudData/SPI/CoreData/NSSQLCore.h"

NS_ASSUME_NONNULL_BEGIN

@interface OCCloudKitSetupAssistant : NSObject {
    OCCloudKitMirroringDelegateOptions *_mirroringOptions; // 0x8
    CKContainer *_container; // 0x10
    CKDatabase *_database; // 0x18
    CKDatabaseSubscription *_databaseSubscription; // 0x20
    NSURL *_largeBlobDirectoryURL; // 0x28
    dispatch_semaphore_t _cloudKitSemaphore; // 0x30
    OCCloudKitStoreMonitor *_storeMonitor; // 0x38
    OCPersistentCloudKitContainerEvent *_setupEvent; // 0x40
    OCCloudKitMirroringDelegateSetupRequest *_setupRequest; // 0x48
    CKRecordID *_currentUserRecordID; // 0x50
}
+ (instancetype)new NS_UNAVAILABLE;
- (instancetype)init NS_UNAVAILABLE;
- (instancetype)initWithSetupRequest:(OCCloudKitMirroringDelegateSetupRequest *)setupRequest mirroringOptions:(OCCloudKitMirroringDelegateOptions *)mirroringOptions observedStore:(NSSQLCore *)observedStore;
- (BOOL)_initializeCloudKitForObservedStore:(NSError * _Nullable * _Nonnull)observedStorePtr andNoteMetadataInitialization:(BOOL *)metadataInitializationPtr __attribute__((objc_direct));
- (void)beginActivityForPhase:(NSUInteger)phase __attribute__((objc_direct));
- (void)endActivityForPhase:(NSUInteger)phase withError:(NSError * _Nullable)error __attribute__((objc_direct));
@end

NS_ASSUME_NONNULL_END
