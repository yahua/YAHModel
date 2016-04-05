//
//  YHModel.m
//  Test
//
//  Created by wangsw on 15/11/23.
//  Copyright © 2015年 wangsw. All rights reserved.
//

#import "YAHModel.h"
#import "YAHJSONAdapter.h"
#import "YAHURLRequestSerialization.h"
#import "YAHNetworkActivityIndicatorManager.h"

#import <objc/runtime.h>


static void *YHModelCachedPropertyKeysKey = &YHModelCachedPropertyKeysKey;

typedef NS_ENUM(NSUInteger, YHRequestStyle) {
    YHRequestStyleUnKnow,
    YHRequestStyleRow,   //row格式
    YHRequestStyleForm,  //form-data格式
};

@interface YAHModel ()

@property (nonatomic, copy) NSString *requestURL;    //请求的url
@property (nonatomic, copy) NSString *baseURLString;
@property (nonatomic, strong) Class resultClass;   //需要解析的类
@property (nonatomic, strong) __kindof YAHDataResponseInfo *result;

@property (nonatomic, strong) NSURLSessionDataTask *dataTask;
@property (nonatomic, strong) NSMutableDictionary *dictParam;
@property (nonatomic, strong) NSMutableDictionary *HTTPHeaders;

@property (nonatomic, assign) YHRequestStyle requestStyle;

@end

@implementation YAHModel


#pragma mark - Public


- (void)analyseWithData:(NSData *)data complete:(void (^)(NSError *error))complete {
    
    
            
        YAHDataResponseInfo *responseInfo = [YAHJSONAdapter modelFromJsonData:data modelClass:[YAHDataResponseInfo class]];

        if (![responseInfo isValid]) {
                dispatch_async(dispatch_get_main_queue(), ^{
                    NSString *errMsg = [responseInfo responseMsg];
                    errMsg = (errMsg)?:@"数据解析失败！！！";
                    BLOCK_EXEC(complete, [NSError errorWithDomain:errMsg code:YHRequestErrorParameter userInfo:nil]);
                });
                return;
            }
            self.result = [YAHJSONAdapter modelFromJsonData:data modelClass:self.resultClass];
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
