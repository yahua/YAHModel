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
    self = [super initWithURL:@"phonearea.php" resultClass:[MobileRespone class]];
    if (self) {
        self.method = @"GET";
    }
    return self;
}

- (void)getNetworkData:(void(^)(NSError *error))block {
    
    NSDictionary *params = @{@"number": @"18559197250"};
    [super requestWithParameters:params complete:^(NSError * _Nullable error) {
        
        if (error) {
            
            NSLog(@"MobileModelRequest fail");
        }else {
            [self saveCache];
            NSLog(@"MobileModelRequest success");
        }
        YAH_BLOCK_EXEC(block, error);
    }];
}

- (NSString *)getCacheKey {
    
    return @"18559197250";
}


@end
