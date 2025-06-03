//
//  shim.m
//  SampleApp
//
//  Created by Jinwoo Kim on 4/6/25.
//

#import "shim.h"
#import <CloudKit/CloudKit.h>
#import <CoreData/CoreData.h>
#include <objc/message.h>
#include <objc/runtime.h>

void sa_shim(void) {
//    NSLog(@"%@", ((id (*)(Class, SEL, Class))objc_msgSend)([NSObject class], sel_registerName("_fd__methodDescriptionForClass:"), objc_lookUpClass("CKContainerOptions")));
}
