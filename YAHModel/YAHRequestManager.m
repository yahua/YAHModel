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

static dispatch_queue_t url_session_manager_creation_queue() {
    static dispatch_queue_t af_url_session_manager_creation_queue;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        af_url_session_manager_creation_queue = dispatch_queue_create("com.alamofire.networking.session.manager.creation", DISPATCH_QUEUE_SERIAL);
    });
    
    return af_url_session_manager_creation_queue;
}

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
        
        _requestStyle = YHRequestStyleForm;
    }
    
    return self;
}

- (NSURLSessionDataTask *)POST:(NSString *)url
                    parameters:(NSDictionary<NSString *, id> *)parameters
                       headers:(NSDictionary<NSString *, id> *)headers
                       success:(void (^)(NSData *data))success
                       failure:(void (^)(NSError *error))failure {
    
    return [self dataWithURL:url method:@"POST" parameters:parameters headers:headers success:success failure:failure];
}

- (NSURLSessionDataTask *)GET:(NSString *)url
                   parameters:(NSDictionary<NSString *, id> *)parameters
                      headers:(NSDictionary<NSString *, id> *)headers
                      success:(void (^)(NSData *data))success
                      failure:(void (^)(NSError *error))failure {
    
    return [self dataWithURL:url method:@"GET" parameters:parameters headers:headers success:success failure:failure];
}

- (NSURLSessionDataTask *)DELETE:(NSString *)url
                      parameters:(NSDictionary<NSString *, id> *)parameters
                         headers:(NSDictionary<NSString *, id> *)headers
                         success:(void (^)(NSData *data))success
                         failure:(void (^)(NSError *error))failure {
    
    return [self dataWithURL:url method:@"DELETE" parameters:parameters headers:headers success:success failure:failure];
}

#pragma mark - Private

- (NSURLSessionDataTask *)dataWithURL:(NSString *)url
                               method:(NSString *)method
                           parameters:(NSDictionary<NSString *, id> *)parameters
                              headers:(NSDictionary<NSString *, id> *)headers
                              success:(void (^)(NSData *data))success
                              failure:(void (^)(NSError *error))failure {
    
    NSURLRequest *request = nil;
    switch (self.requestStyle) {
        case YHRequestStyleUnKnow:
            break;
        case YHRequestStyleRow:
            request = [YAHURLRequestSerialization requestWithMethod:method URLString:url rowParameters:parameters rowHeader:headers];
            break;
        case YHRequestStyleForm:
            request = [YAHURLRequestSerialization requestWithMethod:method URLString:url parameters:parameters header:headers];
            break;
    }
    
    __block NSURLSessionDataTask *dataTask = nil;
    
    dispatch_sync(url_session_manager_creation_queue(), ^{
        
        dataTask = [self.session dataTaskWithRequest:request completionHandler:^(NSData * _Nullable data, NSURLResponse * _Nullable response, NSError * _Nullable error) {
            
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
    });
    
   
    
    [dataTask resume];
    
    return dataTask;
}

- (void)URLSession:(NSURLSession *)session didReceiveChallenge:(NSURLAuthenticationChallenge *)challenge completionHandler:(void (^)(NSURLSessionAuthChallengeDisposition, NSURLCredential * _Nullable))completionHandler {
    
    NSURLSessionAuthChallengeDisposition disposition = NSURLSessionAuthChallengePerformDefaultHandling;
    NSURLCredential *credential = nil;

    if ([challenge.protectionSpace.authenticationMethod isEqualToString:NSURLAuthenticationMethodServerTrust]) {
            credential = [NSURLCredential credentialForTrust:challenge.protectionSpace.serverTrust];
            if (credential) {
                disposition = NSURLSessionAuthChallengeUseCredential;
            } else {
                disposition = NSURLSessionAuthChallengePerformDefaultHandling;
            }
        } else {
            disposition = NSURLSessionAuthChallengePerformDefaultHandling;
        }
    

    if (completionHandler) {
        completionHandler(disposition, credential);
    }
}

@end
