//
//  YHModel.h
//  Test
//
//  Created by wangsw on 15/11/23.
//  Copyright © 2015年 wangsw. All rights reserved.
//

#import "YHDataResponseInfo.h"
#import "YHModelDefine.h"

NS_ASSUME_NONNULL_BEGIN
@interface YHModel : NSObject

/**
 *  The dictParam to be encoded according to the client request serializer.
 */
@property (nonatomic, strong, readonly) NSMutableDictionary *dictParam;

/**
 *  请求成功后的结果, 一般是YHDataResponseInfo的子类的实例
 */
@property (nonatomic, strong, readonly, nullable) __kindof YHDataResponseInfo *result;

/**
 *  request method default is POST
 */
@property (nonatomic, copy) NSString *method;

/**
 *  Convenience initializer to create a new instance.
 *
 *  @param url         request url
 *  @param resultClass kindclass of YHDataResponseInfo
 *
 *  @return 'YHModel' instance.
 */
- (instancetype)initWithURL:(NSString *)url resultClass:(Class)resultClass;

/**
 *  set base request URL
 */
- (void)setBaseURL:(NSString *)baseURL;

/**
 *  The param to be either set as a query string for `GET` requests, or the request HTTP body.
 *
 *  @param value 参数值
 *  @param param 请求参数
 */
- (void)setValue:(id)value forParams:(NSString *)param;

/**
 *  Sets the value for the HTTP headers set in request objects made by the HTTP client. If `nil`, removes the existing value for that header.
 *
 *  @param value The value set as default for the specified header, or `nil`
 *  @param field The HTTP header to set a default value for
 */
- (void)setValue:(NSString *)value forHTTPHeaderField:(NSString *)field;

/**
 *  发起网络请求
 *
 *  @param complete 网络请求结束后回调，如果error!=nil 表示请求失败
 */
- (void)getNetworkData:(YHModelCompleteBlock)complete;

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
