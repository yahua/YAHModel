//
//  YHDataResponseInfo.m
//  YCZZ_iPad
//
//  Created by wangsw on 15/11/25.
//  Copyright © 2015年 com.nd.hy. All rights reserved.
//

#import "YAHDataResponseInfo.h"

@implementation YAHDataResponseInfo

-(BOOL)isValid {
    
    if ([self.errcode integerValue] == 1) {
        return YES;
    }
    
    return NO;
}

- (NSInteger)responseCode {
    
    return [self.errcode integerValue];
}

- (NSString *)responseMsg {
    
    return (self.errmsg)?:@"";
}

@end
