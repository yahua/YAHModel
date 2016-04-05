//
//  YHJSONAdapter.h
//  Test
//
//  Created by wangsw on 15/11/23.
//  Copyright © 2015年 wangsw. All rights reserved.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN
@protocol YAHJSONSerializing

@required

/**
 *  @return NSDictionary with property and json key
 */
+ (NSDictionary *)JSONKeyPathsByPropertyKey;

/**
 *  @return NSDictionary with property 与自定义类的
 */
+ (nullable NSDictionary *)convertClassStringDictionary;

@end

@interface YAHJSONAdapter : NSObject

+ (id)modelFromJsonData:(NSData *)data modelClass:(Class)clazz;

+ (id)modelFromString:(id)str modelClass:(Class)clazz;

+ (id)modelFromDictionary:(NSDictionary *)dict modelClass:(Class)clazz;

+ (id)modelFromArray:(NSArray *)arr modelClass:(Class)clazz;


+ (NSString *)jsonStringFromObject:(id)object;

+ (NSData *)jsonDataFromObject:(id)object;

+ (NSDictionary *)jsonDictionaryFromObject:(id)object;

@end
NS_ASSUME_NONNULL_END
