//
//  TestRequestManager.m
//  Demo
//
//  Created by yahua on 16/4/6.
//  Copyright © 2016年 wangsw. All rights reserved.
//

#import "TestRequestManager.h"

@implementation TestRequestManager

+ (instancetype)shareInstance {
    
    static TestRequestManager *instance;
    static dispatch_once_t once;
    
    dispatch_once(&once, ^{
        
        instance = [[TestRequestManager alloc] initWithBaseURL:[NSURL URLWithString:@"http://apis.baidu.com/apistore/"]];
    });
    
    return instance;
}

@end
