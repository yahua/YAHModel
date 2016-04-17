//
//  YHRequestManager.h
//  MagicBean
//
//  Created by yahua on 16/4/5.
//  Copyright © 2016年 wangsw. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface YAHRequestManager : NSObject

+ (instancetype)manager;

- (instancetype)initWithBaseURL:(NSURL *)baseURL;

- (NSURLSessionDataTask *)POST:(NSString *)url
                    parameters:(NSDictionary<NSString *, id> *)parameters
                       headers:(NSDictionary<NSString *, id> *)headers
                       success:(void (^)(NSData *data))success
                       failure:(void (^)(NSError *error))failure;

- (NSURLSessionDataTask *)GET:(NSString *)url
                   parameters:(NSDictionary<NSString *, id> *)parameters
                      headers:(NSDictionary<NSString *, id> *)headers
                      success:(void (^)(NSData *data))success
                      failure:(void (^)(NSError *error))failure;

- (NSURLSessionDataTask *)DELETE:(NSString *)url
                      parameters:(NSDictionary<NSString *, id> *)parameters
                         headers:(NSDictionary<NSString *, id> *)headers
                         success:(void (^)(NSData *data))success
                         failure:(void (^)(NSError *error))failure;

@end
