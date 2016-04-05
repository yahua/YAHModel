//
//  YHModel.m
//  Test
//
//  Created by wangsw on 15/11/23.
//  Copyright © 2015年 wangsw. All rights reserved.
//

#import "YHModel.h"
#import "YHJSONAdapter.h"
#import "YHURLRequestSerialization.h"
#import "ProjectData.h"
#import "YHNetworkActivityIndicatorManager.h"
#import "ReachabilityManager.h"
#import "MBProgressHUDManager.h"

#import <objc/runtime.h>


static void *YHModelCachedPropertyKeysKey = &YHModelCachedPropertyKeysKey;

typedef NS_ENUM(NSUInteger, YHRequestStyle) {
    YHRequestStyleUnKnow,
    YHRequestStyleRow,   //row格式
    YHRequestStyleForm,  //form-data格式
};

@interface YHModel ()

@property (nonatomic, copy) NSString *requestURL;    //请求的url
@property (nonatomic, copy) NSString *baseURLString;
@property (nonatomic, strong) Class resultClass;   //需要解析的类
@property (nonatomic, strong) id result;

@property (nonatomic, strong) NSURLSessionDataTask *dataTask;
@property (nonatomic, strong) NSMutableDictionary *dictParam;
@property (nonatomic, strong) NSMutableDictionary *HTTPHeaders;

@property (nonatomic, assign) YHRequestStyle requestStyle;

@end

@implementation YHModel

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
    
    self = [super init];
    if (self) {
        _dictParam = [NSMutableDictionary dictionary];
        _HTTPHeaders = [NSMutableDictionary dictionary];
        _requestURL = url;
        _resultClass = resultClass;
        _baseURLString = @"http://api.modoupi.com";     
        _method = @"POST";
        _requestStyle = YHRequestStyleRow;
    }
    return self;
}

#pragma mark - Public

- (void)setBaseURL:(NSString *)baseURL {
    
    _baseURLString = baseURL;
}

- (void)setValue:(id)value forParams:(NSString *)param; {
    
    if(value != nil && param != nil){
        [self.dictParam setObject:value forKey:param];
    }
}

- (void)setValue:(NSString *)value forHTTPHeaderField:(NSString *)field {
    
    if(value != nil && field != nil){
        [self.HTTPHeaders setValue:value forKey:field];
    }
}

- (void)getNetworkData:(YHModelCompleteBlock)complete {
    
    if (![[ReachabilityManager shareInstance] isReachable]) {
        if (complete) {
            BLOCK_EXEC(complete, [NSError errorWithDomain:@"网络未连接，请检查您的网络！" code:YHRequestErrorOther userInfo:nil]);
        }else {
            [[MBProgressHUDManager shareInstance] showErrorNotifyWithParentView:nil text:@"网络未连接，请检查您的网络！"];
        }
        return;
    }
    
    NSURLRequest *request = [self p_urlRequest];
    if (!request) {
        return;
    }
    
    [self.dataTask cancel];
    __weak __typeof(self)weakSelf = self;
    NSURLSession *session = [NSURLSession sharedSession];
    NSURLSessionDataTask *dataTask = [session dataTaskWithRequest:request completionHandler:^(NSData * _Nullable data, NSURLResponse * _Nullable response, NSError * _Nullable error) {
        __strong __typeof(weakSelf)self = weakSelf;
        
       // NSURLSessionDataTask *task = [session dataTaskWithURL:response.URL];
        dispatch_async(dispatch_get_main_queue(), ^{
            [[NSNotificationCenter defaultCenter] postNotificationName:YHNetworkingTaskDidCompleteNotification object:nil];
        });
        
        if (!error) {
            
            YHDataResponseInfo *responseInfo = [YHJSONAdapter modelFromJsonData:data modelClass:[YHDataResponseInfo class]];
            NSLog(@"%@请求返回参数:%@", [self class], [NSJSONSerialization JSONObjectWithData:data options:NSJSONReadingMutableLeaves error:&error]);
            if (![responseInfo isValid]) {
                dispatch_async(dispatch_get_main_queue(), ^{
                    NSString *errMsg = [responseInfo responseMsg];
                    errMsg = (errMsg)?:@"数据解析失败！！！";
                    BLOCK_EXEC(complete, [NSError errorWithDomain:errMsg code:YHRequestErrorParameter userInfo:nil]);
                });
                return;
            }
            self.result = [YHJSONAdapter modelFromJsonData:data modelClass:self.resultClass];
            dispatch_async(dispatch_get_main_queue(), ^{
                if(!self.result) {
                    BLOCK_EXEC(complete, [NSError errorWithDomain:@"数据解析失败！！！" code:YHRequestErrorAdapter userInfo:nil]);
                    return;
                }
                BLOCK_EXEC(complete,nil);
            });
        }else {
            
            NSLog(@"YHModel request Fail:%@", error);
            if (error.code==NSURLErrorCancelled) {
                NSLog(@"%@请求取消", [self class]);
                dispatch_async(dispatch_get_main_queue(), ^{
                    BLOCK_EXEC(complete, [NSError errorWithDomain:@"" code:YHRequestErrorCancel userInfo:nil]);
                });
                return;
            }
            NSError *failError = [NSError errorWithDomain:@"当前网络不稳定，请稍后再试" code:YHRequestErrorOther userInfo:nil];
            dispatch_async(dispatch_get_main_queue(), ^{
                BLOCK_EXEC(complete, failError);
            });
        }
    }];
    self.dataTask = dataTask;
    [self.dataTask resume];
}

- (NSString *)getCacheKey {

    NSString *key = [[self class] description];
    return key;
}

- (BOOL)loadCache {

    @try {
        self.result = [NSKeyedUnarchiver unarchiveObjectWithFile:[self p_archiverFilePath]];
        return YES;
    }
    @catch (NSException *exception) {
        return NO;
    }
}

- (BOOL)saveCache {

    if (!self.result) {
        return NO;
    }
    @try {
        [NSKeyedArchiver archiveRootObject:self.result toFile:[self p_archiverFilePath]];
        return YES;
    }
    @catch (NSException *exception) {
        return NO;
    }
}

- (BOOL)clearCache {
    
    return [[NSFileManager defaultManager] removeItemAtPath:[self p_archiverFilePath] error:nil];
}


#pragma mark - Private

//归档path
- (NSString *)p_archiverFilePath {
    
    NSString *folderName =[NSString stringWithFormat:@"Archiver"];
    NSFileManager *fm = [[NSFileManager alloc] init];
    NSString *documentPath = [NSSearchPathForDirectoriesInDomains(NSCachesDirectory, NSUserDomainMask, YES) objectAtIndex:0];
    NSString *optionPath = [documentPath stringByAppendingPathComponent:folderName];
    if (![fm fileExistsAtPath:optionPath]) {
        [fm createDirectoryAtPath:optionPath withIntermediateDirectories:YES attributes:nil error:nil];
    }
    
    return [NSString stringWithFormat:@"%@/%@", optionPath, [self getCacheKey]];
}

- (NSURLRequest *)p_urlRequest {
    
    [self setValue:[ProjectData shareInstance].access_token forParams:@"access_token"];
    
    long long time = [[NSDate date] timeIntervalSince1970]*1000;
    [self setValue:@(time) forParams:@"time_stamp"];
    
    //添加client_id
    if([ProjectData shareInstance].userInfo.client_id) {
        [self setValue:[ProjectData shareInstance].userInfo.client_id forParams:@"client_id"];
    }
    
    NSString *purpose = [self.dictParam objectForKey:@"do"];
    NSAssert(purpose, @"do not null");
    [self.dictParam removeObjectForKey:@"do"];
    NSData *paramData = [NSJSONSerialization dataWithJSONObject:self.dictParam options:0 error:nil];
    NSString *paramJson = [[NSString alloc] initWithData:paramData
                                                encoding:NSUTF8StringEncoding];
    NSAssert([self.dictParam objectForKey:@"access_token"], @"access_token 不能为空");
    NSString *sign = [paramJson hmacSha1WithKey:[ProjectData shareInstance].sign_key];
    NSDictionary *parameters = @{@"do": purpose,
                                 @"params": self.dictParam,
                                 @"sign": sign};
    
    NSURLRequest *request = nil;
    switch (self.requestStyle) {
        case YHRequestStyleRow:
            request = [YHURLRequestSerialization requestWithMethod:self.method URLString:[self p_wholeRequestURLString] rowParameters:parameters rowHeader:self.HTTPHeaders];
            break;
        case YHRequestStyleForm:
            request = [YHURLRequestSerialization requestWithMethod:self.method URLString:[self p_wholeRequestURLString] parameters:parameters header:self.HTTPHeaders];
            break;
        default:
            break;
    }
    return request;
}

- (NSString *)p_wholeRequestURLString {
    
    return [NSString stringWithFormat:@"%@/%@",_baseURLString, self.requestURL];
}

#pragma mark - NSObject

- (NSString *)description {
    
    return [NSString stringWithFormat:@"<%@: %p> %@", self.class, self, @{@"requestURL":self.requestURL}];
}

@end
