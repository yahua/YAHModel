//
//  MobileModel.h
//  Demo
//
//  Created by yahua on 16/4/6.
//  Copyright © 2016年 wangsw. All rights reserved.
//

#import "TestModelRequest.h"

@interface MobileInfo : YAHActiveObject

@property (nonatomic, copy) NSString *phone;
@property (nonatomic, copy) NSString *prefix;
@property (nonatomic, copy) NSString *supplier;
@property (nonatomic, copy) NSString *province;
@property (nonatomic, copy) NSString *city;

@end

@interface MobileRespone : TestDataResponseInfo

@property (nonatomic, strong) MobileInfo *data;

@end

@interface MobileModelRequest : TestModelRequest

- (void)getNetworkData:(void(^)(NSError *error))block;

@end
