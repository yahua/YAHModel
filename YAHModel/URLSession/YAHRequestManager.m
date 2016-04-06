//
//  YHRequestManager.m
//  MagicBean
//
//  Created by yahua on 16/4/5.
//  Copyright © 2016年 wangsw. All rights reserved.
//

#import "YAHRequestManager.h"
#import "YAHURLRequestSerialization.h"
#import "YAHModelDefine.h"

@interface YAHRequestManager () <
NSURLSessionDelegate,
NSURLSessionTaskDelegate,
NSURLSessionDataDelegate>

@property (nonatomic, strong) NSURL *baseURL;
@property (nonatomic, strong) NSURLSession *session;

@end

@implementation YAHRequestManager

+ (instancetype)manager {
    
    return [[YAHRequestManager alloc] initWithBaseURL:nil];
}

- (instancetype)initWithBaseURL:(NSURL *)baseURL {
    
    self = [super init];
    if (self) {
        _baseURL = baseURL;
        
        NSOperationQueue *queue = [[NSOperationQueue alloc] init];
        queue.maxConcurrentOperationCount = 1;
        
        _session = [NSURLSession sessionWithConfiguration:[NSURLSessionConfiguration defaultSessionConfiguration] delegate:self delegateQueue:queue];
    }
    
    return self;
}

- (NSURLSessionDataTask *)POST:(NSString *)url
                    parameters:(NSDictionary<NSString *, id> *)parameters
                       success:(void (^)(NSData *data))success
                       failure:(void (^)(NSError *error))failure {
    
    return [self dataWithURL:url method:@"POST" parameters:parameters success:success failure:failure];
}

- (NSURLSessionDataTask *)GET:(NSString *)url
                   parameters:(NSDictionary<NSString *, id> *)parameters
                      success:(void (^)(NSData *data))success
                      failure:(void (^)(NSError *error))failure {
    
    return [self dataWithURL:url method:@"GET" parameters:parameters success:success failure:failure];
}

- (NSURLSessionDataTask *)DELETE:(NSString *)url
                      parameters:(NSDictionary<NSString *, id> *)parameters
                         success:(void (^)(NSData *data))success
                         failure:(void (^)(NSError *error))failure {
    
    return [self dataWithURL:url method:@"DELETE" parameters:parameters success:success failure:failure];
}

#pragma mark - Private

- (NSURLSessionDataTask *)dataWithURL:(NSString *)url
                               method:(NSString *)method
                           parameters:(NSDictionary<NSString *, id> *)parameters
                              success:(void (^)(NSData *data))success
                              failure:(void (^)(NSError *error))failure {
    
    NSURLRequest *request = [YAHURLRequestSerialization requestWithMethod:method URLString:[[NSURL URLWithString:url relativeToURL:self.baseURL] absoluteString] parameters:parameters header:nil];
    
    NSURLSessionDataTask *dataTask = [self.session dataTaskWithRequest:request completionHandler:^(NSData * _Nullable data, NSURLResponse * _Nullable response, NSError * _Nullable error) {
        
        dispatch_async(dispatch_get_main_queue(), ^{
            if (error) {
                if (failure) {
                    failure(error);
                }
            }else {
                if (success) {
                    success(data);
                }
            }
        });
    }];
    
    [dataTask resume];
    
    return dataTask;
}

@end
