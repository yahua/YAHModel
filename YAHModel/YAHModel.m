//
//  YHModel.m
//  Test
//
//  Created by wangsw on 15/11/23.
//  Copyright © 2015年 wangsw. All rights reserved.
//

#import "YAHModel.h"
#import "YAHJSONAdapter.h"

#import <objc/runtime.h>

static void *YHModelCachedPropertyKeysKey = &YHModelCachedPropertyKeysKey;


@interface YAHModel ()

@property (nonatomic, strong) Class resultClass;   //需要解析的类
@property (nonatomic, strong) __kindof YAHDataResponseInfo *result;

@end

@implementation YAHModel

- (instancetype)initWithResultClass:(Class)resultClass {
    
    self = [super init];
    if (self) {
        _resultClass = resultClass;
    }
    return self;
}


#pragma mark - Public


- (void)analyseWithData:(NSData *)data complete:(void (^)(NSError *error))complete {
    
    self.result = [YAHJSONAdapter objectFromJsonData:data objectClass:self.resultClass];
    
    if (self.result && [self.result isAdapterSuccess]) {
        YAH_BLOCK_EXEC(complete, nil);
    }else {
        NSString *errMsg = [self.result responseMsg];
        errMsg = (errMsg)?:@"数据解析失败！！！";
        YAH_BLOCK_EXEC(complete, [NSError errorWithDomain:errMsg code:YAHRequestErrorAdapter userInfo:nil]);
    }
}

- (NSString *)getCacheKey {

    return nil;
}

- (BOOL)loadCache {

    @try {
        self.result = [NSKeyedUnarchiver unarchiveObjectWithFile:[self p_getCahceURL]];
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
        return [NSKeyedArchiver archiveRootObject:self.result toFile:[self p_getCahceURL]];
    }
    @catch (NSException *exception) {
        return NO;
    }
}

- (BOOL)clearCache {
    
    return [[NSFileManager defaultManager] removeItemAtPath:[self p_getCahceURL] error:nil];
}

+ (void)clearAllCache {
    
    NSError *error = nil;
    [[NSFileManager defaultManager] removeItemAtPath:[self p_archiverFilePath] error:&error];
}

#pragma mark - Private

- (NSString *)p_getCahceURL {
    
    NSString *key = [self getCacheKey];
    if (!key) {
        key = [[self class] description];
    }
    return [NSString stringWithFormat:@"%@/%@", [[self class] p_archiverFilePath], key];
}

//归档path
+ (NSString *)p_archiverFilePath {
    
    NSString *folderName = [NSString stringWithFormat:@"%@_Cache", [[self class] description]];
    if (![[[self class] description] isEqualToString:[[YAHModel class] description]]) {
        folderName = [NSString stringWithFormat:@"YAHModel_Cache/%@", folderName];
    }
    
    NSFileManager *fm = [[NSFileManager alloc] init];
    NSString *documentPath = [NSSearchPathForDirectoriesInDomains(NSCachesDirectory, NSUserDomainMask, YES) objectAtIndex:0];
    NSString *optionPath = [documentPath stringByAppendingPathComponent:folderName];
    if (![fm fileExistsAtPath:optionPath]) {
        [fm createDirectoryAtPath:optionPath withIntermediateDirectories:YES attributes:nil error:nil];
    }
    return optionPath;
}


@end
