//
//  OCCloudKitMirroringDelegate.h
//  OpenCloudData
//
//  Created by Jinwoo Kim on 4/1/25.
//

#import <CloudKit/CloudKit.h>
#import "OpenCloudData/SPI/CoreData/NSPersistentStoreMirroringDelegate.h"
#import "OpenCloudData/Private/OCCloudKitMirroringDelegateOptions.h"
#import "OpenCloudData/Private/Export/OCCloudKitExporter.h"
#import "OpenCloudData/SPI/CoreData/PFApplicationStateMonitorDelegate.h"
#import "OpenCloudData/Private/OCCloudKitMirroringDelegateProgressProvider.h"
#import "OpenCloudData/Private/OCPersistentCloudKitContainerActivityVoucher.h"
#import "OpenCloudData/SPI/CloudKit/CKScheduler.h"
#import "OpenCloudData/SPI/CloudKit/CKNotificationListener.h"
#import "OpenCloudData/Private/OCDCloudKitClient.h"
#import "OpenCloudData/Private/OCCloudKitThrottledNotificationObserver.h"
#import "OpenCloudData/Private/OCCloudKitMirroringRequestManager.h"
#import "OpenCloudData/Private/OCCloudKitMirroringActivityVoucherManager.h"
#import "OpenCloudData/Public/OCPersistentCloudKitContainerOptions.h"

NS_ASSUME_NONNULL_BEGIN

#warning TODO

@interface OCCloudKitMirroringDelegate : NSObject <OCCloudKitExporterDelegate, PFApplicationStateMonitorDelegate, OCCloudKitMirroringDelegateProgressProvider, NSPersistentStoreMirroringDelegate> {
    @package OCCloudKitMirroringDelegateOptions *_options; // 0x8
    NSString * _Nullable _ckDatabaseName;  // 0x10
    dispatch_semaphore_t _cloudKitQueueSemaphore; // 0x18
    dispatch_queue_t _cloudKitQueue; // 0x20
    CKDatabaseSubscription *_databaseSubscription; // 0x28
    CKContainer *_container; // 0x30
    CKDatabase *_database; // 0x38
    CKScheduler *_scheduler; // 0x40
    CKNotificationListener *_notificationListener; // 0x48
    NSError * _Nullable _lastInitializationError; // 0x50
    BOOL _hadObservedStore; // 0x58
    @package BOOL _successfullyInitialized; // 0x59
    OCCloudKitExporterOptions *_exporterOptions; // 0x60
    OCDCloudKitClient * _Nullable _coredatadClient; // 0x68
    BOOL _registeredForAccountChangeNotifications; // 0x70
    BOOL _registeredForIdentityUpdateNotifications; // 0x71
    __weak NSSQLCore *_observedStore; // 0x78
    __weak NSPersistentStoreCoordinator *_observedCoordinator; // 0x80
    OCCloudKitThrottledNotificationObserver *_accountChangeObserver; // 0x88
    BOOL _setupFinishedMetadataInitialization; // 0x90
    BOOL _registeredForSubscription; // 0x91
    BOOL _registeredExportActivityHandler; // 0x92
    BOOL _registeredImportActivityHandler; // 0x93
    BOOL _registeredSetupActivityHandler; // 0x94
    @package CKRecordID *_currentUserRecordID; // 0x98
    OCCloudKitMirroringRequestManager *_requestManager; // 0xa0
    NSString *_observedStoreIdentifier; // 0xa8
    NSString *_importActivityIdentifier; // 0xb0
    NSString *_exportActivityIdentifier; // 0xb8
    NSString *_setupActivityIdentifier; // 0xc0
    NSString *_activityGroupName; // 0xc8
    PFApplicationStateMonitor *_applicationMonitor; // 0xd0
    CKSystemSharingUIObserver *_sharingUIObserver; // 0xd8
    OCCloudKitMirroringActivityVoucherManager *_voucherManager; // 0xe0
}
@property (class, readonly, nonatomic) NSString *cloudKitMachServiceName;
@property (class, readonly, nonatomic) NSString *cloudKitMetadataTransformerName;

+ (BOOL)checkAndCreateDirectoryAtURL:(NSURL *)url wipeIfExists:(BOOL)wipeIfExists error:(NSError * _Nullable * _Nullable)error;
+ (BOOL)checkIfContentsOfStore:(__kindof NSPersistentStore *)store matchContentsOfStore:(__kindof NSPersistentStore *)otherStore error:(NSError * _Nullable * _Nullable)error;
+ (BOOL)checkIfContentsOfStore:(__kindof NSPersistentStore *)store matchContentsOfStore:(__kindof NSPersistentStore *)otherStore onlyCompareSharedZones:(BOOL)onlyCompareSharedZones error:(NSError * _Nullable * _Nullable)error;
+ (NSXPCConnection *)createCloudKitServerWithMachServiceName:(NSString *)machServiceName andStorageDirectoryPath:(NSString *)storageDirectoryPath;
+ (BOOL)isFirstPartyContainerIdentifier:(NSString *)identifier;

+ (BOOL)printEventsInStores:(NSArray<__kindof NSPersistentStore *> *)stores startingAt:(NSDate *)startDate endingAt:(NSDate *)endDate error:(NSError * _Nullable * _Nullable)error;
+ (void)printMetadataForStoreAtURL:(NSURL *)url withConfiguration:(NSString *)configuration operateOnACopy:(BOOL)operateOnACopy;
+ (void)printRepresentativeSchemaForModelAtURL:(NSURL * _Nullable)modelURL orStoreAtURL:(NSURL * _Nullable)storeURL withConfiguration:(NSString *)configuration;
+ (void)printSharedZoneWithName:(NSString *)zoneName inStoreAtURL:(NSURL *)storeURL error:(NSError * _Nullable * _Nullable)error;
+ (NSString * _Nullable)stringForResetReason:(NSUInteger)reason;
+ (BOOL)traceObjectMatchingRecordName:(NSString *)recordName inStores:(NSArray<__kindof NSPersistentStore *> *)stores startingAt:(NSDate *)startDate endingAt:(NSDate *)endDate error:(NSError * _Nullable * _Nullable)error;
+ (BOOL)traceObjectMatchingValue:(id)value atKeyPath:(NSString *)keyPath inStores:(NSArray<__kindof NSPersistentStore *> *)stores startingAt:(NSDate *)startDate endingAt:(NSDate *)endDate error:(NSError * _Nullable * _Nullable)error;

@property (readonly, nonatomic) PFApplicationStateMonitor* applicationMonitor;
@property (readonly, nonatomic) BOOL registeredForSubscription;
@property (readonly, nonatomic) BOOL registeredExportActivityHandler;
@property (readonly, nonatomic) BOOL registeredImportActivityHandler;
@property (readonly, nonatomic) BOOL registeredSetupActivityHandler;

- (instancetype)initWithCloudKitContainerOptions:(OCPersistentCloudKitContainerOptions *)cloudKitContainerOptions;
- (instancetype)initWithOptions:(OCCloudKitMirroringDelegateOptions *)options;

- (void)addActivityVoucher:(OCPersistentCloudKitContainerActivityVoucher *)activityVoucher;
- (void)expireActivityVoucher:(OCPersistentCloudKitContainerActivityVoucher *)activityVoucher;

- (void)removeNotificationRegistrations __attribute__((objc_direct));
- (void)beginActivitiesForRequest:(__kindof OCCloudKitMirroringRequest *)request __attribute__((objc_direct));
- (void)checkAndExecuteNextRequest __attribute__((objc_direct));
@end

NS_ASSUME_NONNULL_END
