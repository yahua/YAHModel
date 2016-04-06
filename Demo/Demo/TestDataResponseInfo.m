//
//  TestDataResponseInfo.m
//  Demo
//
//  Created by yahua on 16/4/6.
//  Copyright © 2016年 wangsw. All rights reserved.
//

#import "TestDataResponseInfo.h"

@implementation TestDataResponseInfo

- (BOOL)isAdapterSuccess {
    
    if (self.errNum == 0) {
        return YES;
    }
    
    return NO;
}

- (NSInteger)responseCode {
    
    return self.errNum;
}

- (NSString *)responseMsg {
    
    return (self.retMsg)?:@"";
}

@end
