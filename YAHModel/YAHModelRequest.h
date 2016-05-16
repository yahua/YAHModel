//
//  YHModel.h
//  Test
//
//  Created by wangsw on 15/11/23.
//  Copyright © 2015年 wangsw. All rights reserved.
//

#import "YAHModel.h"

NS_ASSUME_NONNULL_BEGIN

@protocol YAHModelRequestDelegate <NSObject>

@optional
- (void)requestStateChange:(YAHRequestState)state;

@end

@interface YAHModelRequest : YAHModel

@property (nonatomic, weak) id<YAHModelRequestDelegate> delegate;

/** The dictParam to be encoded according to the client request serializer. */
@property (nonatomic, strong, readonly) NSDictionary *dictParam;


/** request method default is POST */
@property (nonatomic, copy) NSString *method;


/** default is YHRequestStyleForm */
@property (nonatomic, assign) YHRequestStyle requestStyle;


/** 请求的基本url */
@property (nonatomic, strong) NSURL *baseURL;

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
 *  Sets the value for the HTTP headers set in request objects made by the HTTP client. If `nil`, removes the existing value for that header.
 *
 *  @param value The value set as default for the specified header, or `nil`
 *  @param field The HTTP header to set a default value for
 */
- (void)setValue:(NSString *)value forHTTPHeaderField:(NSString *)field;

/**
 *  发起网络请求
 *
 *  @param parameters  请求参数
 *  @param complete 网络请求结束后回调，如果error!=nil 表示请求失败
 */
- (void)requestWithParameters:(NSDictionary *)parameters complete:(YAHModelCompleteBlock)complete;


@end

NS_ASSUME_NONNULL_END
