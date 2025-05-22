//
//  Log.c
//  OpenCloudData
//
//  Created by Jinwoo Kim on 3/30/25.
//

#import "OpenCloudData/Private/Log.h"

os_log_t _OCLogGetLogStream(int32_t arg /* unknown */) {
    return os_log_create("OpenCloudData", "com.pookjw.OpenCloudData");
}
