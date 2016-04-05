//
//  YHModel.h
//  Test
//
//  Created by wangsw on 15/11/23.
//  Copyright © 2015年 wangsw. All rights reserved.
//

#import "YAHDataResponseInfo.h"
#import "YAHModelDefine.h"

NS_ASSUME_NONNULL_BEGIN
@interface YAHModel : NSObject


- (instancetype)initWithResultClass:(Class)resultClass;


- (void)analyseWithData:(NSData *)data complete:(void (^)(NSError *error))complete;

/**
 *  获取缓存的key，建议每个model重写自己的该方法
 *
 *  @return cache key
 */
- (NSString *)getCacheKey;

/**
 *  加载缓存
 *
 *  @return YES 表示成功
 */
- (BOOL)loadCache;

/**
 *  存储缓存， 需要手动调用  默认不缓存数据
 *
 *  @return YES 表示成功
 */
- (BOOL)saveCache;

/**
 *  清除缓存数据
 *
 *  @return YES 表示成功
 */
- (BOOL)clearCache;

@end
NS_ASSUME_NONNULL_END
