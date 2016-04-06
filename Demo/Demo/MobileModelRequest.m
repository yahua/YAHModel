//
//  MobileModel.m
//  Demo
//
//  Created by yahua on 16/4/6.
//  Copyright © 2016年 wangsw. All rights reserved.
//

#import "MobileModelRequest.h"

@implementation MobileInfo

@end

@implementation MobileRespone

@end

@implementation MobileModelRequest

- (instancetype)init
{
    self = [super initWithURL:@"mobilenumber/mobilenumber" resultClass:[MobileRespone class]];
    if (self) {
        self.method = @"GET";
    }
    return self;
}

- (void)getNetworkData {
    
    NSDictionary *params = @{@"phone": @"18559197250"};
    [super requestWithParameters:params complete:^(NSError * _Nullable error) {
        
    }];
}

@end
