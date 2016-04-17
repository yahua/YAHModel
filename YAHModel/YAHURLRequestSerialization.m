//
//  YHURLRequestSerialization.m
//  YCZZ_iPad
//
//  Created by wangsw on 16/1/18.
//  Copyright © 2016年 com.nd.hy. All rights reserved.
//

#import "YAHURLRequestSerialization.h"

@implementation YAHURLRequestSerialization

+ (NSURLRequest *)requestWithMethod:(NSString *)method
                          URLString:(NSString *)URLString
                         parameters:(NSDictionary *)parameters
                             header:(NSDictionary *)headers {
    
    NSParameterAssert(method);
    NSParameterAssert(URLString);
    
    NSURL *url = [NSURL URLWithString:URLString];
    
    NSParameterAssert(url);
    
    NSMutableURLRequest *mutableRequest = [[NSMutableURLRequest alloc] initWithURL:url];
    mutableRequest.HTTPMethod = method;
    if (![mutableRequest valueForHTTPHeaderField:@"Content-Type"]) {
        [mutableRequest setValue:@"application/json" forHTTPHeaderField:@"Content-Type"];
    }
    
    //添加头
    for(id key in headers.allKeys) {
        NSParameterAssert([key isKindOfClass:[NSString class]]);
        id object = headers[key];
        NSParameterAssert([object isKindOfClass:[NSString class]]);
        [mutableRequest setValue:object forHTTPHeaderField:key];
    }
    
    //添加body
    NSMutableArray *paramList = [NSMutableArray arrayWithCapacity:1];
    for(id key in parameters.allKeys) {
        NSParameterAssert([key isKindOfClass:[NSString class]]);
        id object = parameters[key];
        NSParameterAssert([object isKindOfClass:[NSString class]]);
        [paramList addObject:[NSString stringWithFormat:@"%@=%@", key, object]];
    }
    NSString *bodyString = [paramList componentsJoinedByString:@"&"];
    
    NSSet *HTTPMethodsEncodingParametersInURI = [NSSet setWithObjects:@"GET", @"HEAD", @"DELETE", nil];
    if ([HTTPMethodsEncodingParametersInURI containsObject:[method uppercaseString]]) {
        if (bodyString) {
            mutableRequest.URL = [NSURL URLWithString:[[mutableRequest.URL absoluteString] stringByAppendingFormat:mutableRequest.URL.query ? @"&%@" : @"?%@", bodyString]];
        }
    } else {
        //an empty string is a valid x-www-form-urlencoded payload
        if (!bodyString) {
            bodyString = @"";
        }
        if (![mutableRequest valueForHTTPHeaderField:@"Content-Type"]) {
            [mutableRequest setValue:@"application/x-www-form-urlencoded" forHTTPHeaderField:@"Content-Type"];
        }
        [mutableRequest setHTTPBody:[bodyString dataUsingEncoding:NSUTF8StringEncoding]];
    }
    
    return mutableRequest;
}

+ (NSURLRequest *)requestWithMethod:(NSString *)method
                          URLString:(NSString *)URLString
                      rowParameters:(NSDictionary *)rowParameters
                          rowHeader:(NSDictionary<NSString *, NSString *> *)rowheader {
    
    NSParameterAssert(method);
    NSParameterAssert(URLString);
    
    NSURL *url = [NSURL URLWithString:URLString];
    
    NSParameterAssert(url);
    
    NSMutableURLRequest *mutableRequest = [[NSMutableURLRequest alloc] initWithURL:url];
    mutableRequest.HTTPMethod = method;
    
    //添加头
    [rowheader enumerateKeysAndObjectsUsingBlock:^(NSString * _Nonnull key, NSString * _Nonnull obj, BOOL * _Nonnull stop) {
        [mutableRequest setValue:obj forHTTPHeaderField:key];
    }];
    
    if (rowParameters) {
        
        if (![mutableRequest valueForHTTPHeaderField:@"Content-Type"]) {
            [mutableRequest setValue:@"application/json" forHTTPHeaderField:@"Content-Type"];
        }
        //添加body
        NSData *data = [NSJSONSerialization dataWithJSONObject:rowParameters options:0 error:nil];
        
//        NSString *paramJson = [[NSString alloc] initWithData:data
//                                                    encoding:NSUTF8StringEncoding];
        
        [mutableRequest setHTTPBody:data];
    }
    
    
    
    return mutableRequest;
}

@end
