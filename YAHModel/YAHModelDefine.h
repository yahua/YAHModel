//
//  YAHModelDefine.h
//  YAHModel
//
//  Created by yahua on 16/4/5.
//  Copyright © 2016年 wangsw. All rights reserved.
//

#ifndef YAHModelDefine_h
#define YAHModelDefine_h

typedef NS_ENUM(NSInteger, YAHRequestErrorCode) {
    YAHRequestErrorUnknow = -1,
    YAHRequestErrorCancel = 999,
    YAHRequestErrorParameter = 1000,  //参数错误
    YAHRequestErrorAdapter = 1001,    //解析出错
    YAHRequestErrorOther = 1002,      //超时、url错误、host错误等
};

typedef NS_ENUM(NSUInteger, YHRequestStyle) {
    YHRequestStyleUnKnow,
    YHRequestStyleRow,   //row格式
    YHRequestStyleForm,  //form-data格式
};


typedef NS_ENUM(NSUInteger, YAHRequestState) {
    YAHRequestStateRunning,
    YAHRequestStateSuspended,
    YAHRequestStateCanceling,
    YAHRequestStateFailure,
    YAHRequestStateSuccess,
};

/////////debug环境判断//////////////
#ifdef DEBUG

#define LRString [NSString stringWithFormat:@"%s", __FILE__].lastPathComponent
#define YAHLog(...) printf("%s 第%d行: %s\n\n", [LRString UTF8String] ,__LINE__, [[NSString stringWithFormat:__VA_ARGS__] UTF8String]);

#else

#define YAHLog(format, ...)

#endif

#define YAH_BLOCK_EXEC(block, ...) if (block) { block(__VA_ARGS__); };

typedef void (^YAHModelCompleteBlock)(NSError * _Nullable error);

typedef void (^YAHQuickNetworkCompleteBlock)(NSDictionary *_Nullable jsonDic, NSError * _Nullable error);

#endif /* YAHModelDefine_h */
