//
//  YHModel.m
//  Test
//
//  Created by wangsw on 15/11/23.
//  Copyright © 2015年 wangsw. All rights reserved.
//

#import "YAHModelRequest.h"
#import "YAHJSONAdapter.h"
#import "YAHURLRequestSerialization.h"
#import "YAHNetworkActivityIndicatorManager.h"

#import <objc/runtime.h>

static void *YHModelCachedPropertyKeysKey = &YHModelCachedPropertyKeysKey;

@interface YAHModelRequest ()

@property (nonatomic, copy) NSString *requestURL;    //请求的url

@property (nonatomic, strong) NSURLSessionDataTask *dataTask;
@property (nonatomic, strong) NSMutableDictionary *HTTPHeaders;

@end

@implementation YAHModelRequest

#pragma mark -

- (void)dealloc {
    
    [self.dataTask cancel];
    self.dataTask = nil;
}

- (instancetype)init {
    
    NSAssert(NO, @"Must use initWithURL:resultClass: instead");
    return nil;
}

- (instancetype)initWithURL:(NSString *)url resultClass:(Class)resultClass {
    
    self = [super initWithResultClass:resultClass];
    if (self) {
        
        _HTTPHeaders = [NSMutableDictionary dictionary];
        _requestURL = url;
        _method = @"POST";
        _requestStyle = YHRequestStyleForm;
    }
    return self;
}

#pragma mark - Public

- (void)setValue:(NSString *)value forHTTPHeaderField:(NSString *)field {
    
    if(value != nil && field != nil){
        [self.HTTPHeaders setValue:value forKey:field];
    }
}

- (void)requestWithParameters:(NSDictionary *)parameters complete:(YAHModelCompleteBlock)complete {
    
    NSURLRequest *request = nil;
    switch (self.requestStyle) {
        case YHRequestStyleUnKnow:
            break;
        case YHRequestStyleRow:
            request = [YAHURLRequestSerialization requestWithMethod:self.method URLString:[self p_wholeRequestURLString] rowParameters:parameters rowHeader:self.HTTPHeaders];
            break;
        case YHRequestStyleForm:
            request = [YAHURLRequestSerialization requestWithMethod:self.method URLString:[self p_wholeRequestURLString] parameters:parameters header:self.HTTPHeaders];
            break;
    }
    if (!request) {
        return;
    }
    
    [self.dataTask cancel];
    __weak __typeof(self)weakSelf = self;
    
    NSURLSession *session = [NSURLSession sharedSession];
    [self requestStateChange:YAHRequestStateRunning];
    NSURLSessionDataTask *dataTask = [session dataTaskWithRequest:request completionHandler:^(NSData * _Nullable data, NSURLResponse * _Nullable response, NSError * _Nullable error) {
        __strong __typeof(weakSelf)self = weakSelf;
        
       // NSURLSessionDataTask *task = [session dataTaskWithURL:response.URL];
#if TARGET_OS_IOS
        dispatch_async(dispatch_get_main_queue(), ^{
            [[NSNotificationCenter defaultCenter] postNotificationName:YHNetworkingTaskDidCompleteNotification object:nil];
        });
#endif
        
        [self requestStateChange:error?YAHRequestStateFailure:YAHRequestStateSuccess];
        
        if (!error) {
            
            [self analyseWithData:data complete:complete];
        }else {
            
            dispatch_async(dispatch_get_main_queue(), ^{
                
                YAHModelLog(@"YHModel request Fail:%@", error);
                if (error.code==NSURLErrorCancelled) {
                    YAHModelLog(@"%@请求取消", [self class]);
                    YAH_BLOCK_EXEC(complete, [NSError errorWithDomain:@"" code:YAHRequestErrorCancel userInfo:nil]);
                     return;
                }
                YAH_BLOCK_EXEC(complete, error);
                
            });
        }
    }];
    self.dataTask = dataTask;
    [self.dataTask resume];
}


#pragma mark - Private

- (NSString *)p_wholeRequestURLString {
    
    return  [[NSURL URLWithString:self.requestURL relativeToURL:self.baseURL] absoluteString];
}

- (void)requestStateChange:(YAHRequestState)state {
    
    if (self.delegate && [self.delegate respondsToSelector:@selector(requestStateChange:)]) {
        [self.delegate requestStateChange:state];
    }
}

#pragma mark - NSObject

- (NSString *)description {
    
    return [NSString stringWithFormat:@"<%@: %p> %@", self.class, self, @{@"requestURL":self.requestURL}];
}

@end
