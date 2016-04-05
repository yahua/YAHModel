//
//  YHDataResponseInfo.h
//  YCZZ_iPad
//
//  Created by wangsw on 15/11/25.
//  Copyright © 2015年 com.nd.hy. All rights reserved.
//

#import "YAHActiveObject.h"

@interface YAHDataResponseInfo : YAHActiveObject

@property (nonatomic, strong) NSNumber *errcode;
@property (nonatomic, strong) NSString *errmsg;

/**
 *  网络请求是否有效
 *
 *  @return YES json数据有效
 */
- (BOOL)isValid;

- (NSInteger)responseCode;

- (NSString *)responseMsg;

@end
