//
//  YHURLRequestSerialization.h
//  YCZZ_iPad
//
//  Created by wangsw on 16/1/18.
//  Copyright © 2016年 com.nd.hy. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface YAHURLRequestSerialization : NSObject

//以form-data的形式
+ (NSURLRequest *)requestWithMethod:(NSString *)method
                          URLString:(NSString *)URLString
                         parameters:(NSDictionary<NSString *, NSString *> *)parameters
                             header:(NSDictionary<NSString *, NSString *> *)headers;

//以row的形式 不支持GET
+ (NSURLRequest *)requestWithMethod:(NSString *)method
                          URLString:(NSString *)URLString
                      rowParameters:(NSDictionary *)rowParameters
                          rowHeader:(NSDictionary<NSString *, NSString *> *)rowheader;

@end
