//
//  TestModelRequest.m
//  Demo
//
//  Created by yahua on 16/4/6.
//  Copyright © 2016年 wangsw. All rights reserved.
//

#import "TestModelRequest.h"

@implementation TestModelRequest

- (instancetype)initWithURL:(NSString *)url resultClass:(Class)resultClass {
    
    self = [super initWithURL:url resultClass:resultClass];
    if (self) {
        self.baseURL = [NSURL URLWithString:@"http://apis.baidu.com/apistore/"];
        [self setValue:@"百度的 apistore 的key" forHTTPHeaderField:@"apikey"];
    }
    return self;
}

- (void)requestWithParameters:(NSDictionary *)parameters complete:(YAHModelCompleteBlock)complete {
    
    NSMutableDictionary *tmpParams = [NSMutableDictionary dictionaryWithDictionary:parameters];
    [super requestWithParameters:[tmpParams copy] complete:complete];
}

@end
