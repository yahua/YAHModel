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
    
    self.result = [YAHJSONAdapter objectFromJson:data objectClass:self.resultClass];
    
    if (self.result && [self.result isAdapterSuccess] ) {
        BLOCK_EXEC(complete, nil);
    }else {
        NSString *errMsg = [self.result responseMsg];
        errMsg = (errMsg)?:@"数据解析失败！！！";
        BLOCK_EXEC(complete, [NSError errorWithDomain:errMsg code:YAHRequestErrorAdapter userInfo:nil]);
    }

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


@end
