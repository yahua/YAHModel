//
//  MobileModel.m
//  Demo
//
//  Created by yahua on 16/4/6.
//  Copyright © 2016年 wangsw. All rights reserved.
//

#import "MobileModel.h"

@implementation MobileModel

- (NSString *)getCacheKey {
    
    return self.phone;
}

- (instancetype)init
{
    self = [super initWithResultClass:[MobileRespone class]];
    if (self) {
        
    }
    return self;
}

@end
