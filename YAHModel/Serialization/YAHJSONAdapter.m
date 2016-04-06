//
//  YHJSONAdapter.m
//  Test
//
//  Created by wangsw on 15/11/23.
//  Copyright © 2015年 wangsw. All rights reserved.
//

#import "YAHJSONAdapter.h"
#import <objc/runtime.h>

@implementation YAHJSONAdapter

#pragma mark - Public

+ (id)modelFromJsonData:(NSData *)data modelClass:(Class)clazz {
    
    if ( nil == data ) {
        return nil;
    }
    
    if (![data isKindOfClass:[NSData class]] ) {
        return nil;
    }
    NSError *error = nil;
    NSObject * obj = [NSJSONSerialization JSONObjectWithData:data options:NSJSONReadingMutableLeaves error:&error];
    if ( obj ) {
        if ( [obj isKindOfClass:[NSDictionary class]] ) {
            return [self p_objectFromDictionary:(NSDictionary *)obj class:clazz];
        }else if ( [obj isKindOfClass:[NSArray class]] ) {
            return [self modelFromArray:(NSArray *)obj modelClass:clazz];
        }
    }
    
    return nil;
}

+ (id)modelFromString:(id)str modelClass:(Class)clazz {
    
    if (!str || ![str isKindOfClass:[NSString class]]) {
        return nil;
    }
    NSError *error;
    NSData* jsonData = [str dataUsingEncoding:NSUTF8StringEncoding];
    NSObject * obj = [NSJSONSerialization JSONObjectWithData:jsonData options:NSJSONReadingMutableLeaves error:&error];
    if (!obj) {
        NSLog(@"%@", error);
        return nil;
    }
    if ([obj isKindOfClass:[NSDictionary class]]) {
        return [self p_objectFromDictionary:(NSDictionary *)obj class:clazz];
    }else if ( [obj isKindOfClass:[NSArray class]] ) {
        return [self modelFromArray:(NSArray *)obj modelClass:clazz];
    }else if ( [self p_isAtomClass:[obj class]] ) {
        return obj;
    }
    return nil;
}

+ (id)modelFromDictionary:(NSDictionary *)dict modelClass:(Class)clazz {
    
    if ( nil == dict ) {
        return nil;
    }
    
    if ( NO == [dict isKindOfClass:[NSDictionary class]] ) {
        return nil;
    }
    
    return [self p_objectFromDictionary:dict class:clazz];
}

+ (id)modelFromArray:(NSArray *)arr modelClass:(Class)clazz {
    
    if ( nil == arr )
        return nil;
    
    if ( NO == [arr isKindOfClass:[NSArray class]] )
        return nil;
    
    NSMutableArray * results = [NSMutableArray array];
    
    for ( NSObject * obj in (NSArray *)arr ) {
        if ( [obj isKindOfClass:[NSDictionary class]] ) {
            id newObj = [self modelFromDictionary:(NSDictionary *)obj modelClass:clazz];
            if ( newObj ) {
                [results addObject:newObj];
            }
        }else if ([obj isKindOfClass:[NSArray class]]) {
            id newObj = [self modelFromArray:(NSArray *)obj modelClass:clazz];
            if ( newObj ) {
                [results addObject:newObj];
            }
        }else {
            [results addObject:obj];
        }
    }
    
    return results;
}

+ (NSString *)jsonStringFromObject:(id)object {
    
    NSString *json;
    Class typeClazz = [object class];
    
    if ([object isKindOfClass:[NSNumber class]] ||
        [object isKindOfClass:[NSString class]]) {
        json = [self p_asNSString:object];
    }else if([object isKindOfClass:[NSArray class]]) {
        NSMutableArray *array = [NSMutableArray arrayWithCapacity:1];
        for (NSObject *elem in (NSArray *)object) {
            NSDictionary *dic = [self p_dictionaryFromObject:elem];
            if (dic) {
                [array addObject:dic];
            }else {
                if ([self p_isAtomClass:[elem class]]) {
                    [array addObject:elem];
                }
            }
        }
        NSData *jsonData = [NSJSONSerialization dataWithJSONObject:array options:NSJSONWritingPrettyPrinted error:nil];
        json = [[NSString alloc] initWithData:jsonData
                                     encoding:NSUTF8StringEncoding];
    }else if ([object isKindOfClass:[NSDictionary class]] ||
              ![self p_isAtomClass:typeClazz]) {
        NSDictionary *dic = [self p_dictionaryFromObject:object];
        if (dic) {
            NSData *jsonData = [NSJSONSerialization dataWithJSONObject:dic options:NSJSONWritingPrettyPrinted error:nil];
            json = [[NSString alloc] initWithData:jsonData
                                  encoding:NSUTF8StringEncoding];
        }
    }else if ([object isKindOfClass:[NSDate class]]) {
        json = [object description];
    }
    
    if (!json || json.length == 0) {
        return nil;
    }
    return [json copy];
}

+ (NSData *)jsonDataFromObject:(id)object {
    
    NSString *string = [self jsonStringFromObject:object];
    if (!string) {
        return nil;
    }
    return [string dataUsingEncoding:NSUTF8StringEncoding];
}

+ (NSDictionary *)jsonDictionaryFromObject:(id)object {
    
    return [self p_dictionaryFromObject:object];
}

#pragma mark - Private

+ (id)p_objectFromDictionary:(NSDictionary *)dic class:(Class)clazz {
    
    NSParameterAssert([clazz conformsToProtocol:@protocol(YAHJSONSerializing)]);
    
    id object = [[clazz alloc] init];
    if ( nil == object )
        return nil;
    
    for ( Class clazzType = clazz; clazzType != [NSObject class]; ) {
        unsigned int		propertyCount = 0;
        objc_property_t *	properties = class_copyPropertyList( clazzType, &propertyCount );
        
        for ( NSUInteger i = 0; i < propertyCount; i++ ) {
            const char *	name = property_getName(properties[i]);
            NSString *		propertyName = [NSString stringWithCString:name encoding:NSUTF8StringEncoding];
            const char *	attr = property_getAttributes(properties[i]);
            Class		    typeClass = [self p_typeOfAttribute:attr];
            if (!typeClass) {
                return nil;
            }
            
            //真正的json key
            NSString *propertyKey = [[clazz JSONKeyPathsByPropertyKey] objectForKey:propertyName];
            
            NSObject *	tempValue = [dic objectForKey:propertyKey];
            NSObject *	value = nil;
            
            if ( tempValue ) {
                if ( [NSNumber class] == typeClass ) {
                    value = [self p_asNSNumber:tempValue];
                }
                else if ( [NSString class] == typeClass ) {
                    value = [self p_asNSString:tempValue];
                }
                else if ( [NSDate class] == typeClass ) {
                    value = [self p_asNSDate:tempValue];
                }
                else if ( [NSArray class] == typeClass ) {
                    if ( [tempValue isKindOfClass:[NSArray class]] ) {
                        NSString *classString = [[clazz convertClassStringDictionary] objectForKey:propertyName];
                        if (classString) {
                            Class convertClass = NSClassFromString(classString);
                            if ( convertClass ) {
                                NSMutableArray * arrayTemp = [NSMutableArray array];
                                for ( NSObject * tempObject in (NSArray *)tempValue ) {
                                    if ( [tempObject isKindOfClass:[NSDictionary class]] ) { //自定义model
                                        [arrayTemp addObject:[self p_objectFromDictionary:(NSDictionary *)tempObject class:convertClass]];
                                    }else {   //非自定义
                                        [arrayTemp addObject:tempObject];
                                    }
                                }
                                value = arrayTemp;
                            }
                            else {
                                value = tempValue;
                            }
                        }
                        else {
                            value = tempValue;
                        }
                    }
                }
                else if ( [NSDictionary class] == typeClass ) {
                    if ( [tempValue isKindOfClass:[NSDictionary class]] ) {
                        NSString *classString = [[clazz convertClassStringDictionary] objectForKey:propertyName];
                        if ( classString ) {
                            Class convertClass = NSClassFromString(classString);
                            if ( convertClass ) {
                                value = [self p_objectFromDictionary:(NSDictionary *)tempValue class:convertClass];
                            }else {
                                value = tempValue;
                            }
                        }else {
                            value = tempValue;
                        }
                    }
                }
                else {  //nsobject类
                    if ( [tempValue isKindOfClass:typeClass] ) {
                        value = tempValue;
                    }else if ( [tempValue isKindOfClass:[NSDictionary class]] ) {
                        value = [self p_objectFromDictionary:(NSDictionary *)tempValue class:typeClass];
                    }
                }
            }
            
            if ( nil != value ) {
                [object setValue:value forKey:propertyName];
            }
        }
        
        free( properties );
        
        clazzType = class_getSuperclass( clazzType );
        if ( nil == clazzType )
            break;
    }
    
    return object;
}

+ (NSDictionary *)p_dictionaryFromObject:(id)object {
    
    NSMutableDictionary *result = [NSMutableDictionary dictionary];
    
    if ([object isKindOfClass:[NSDictionary class]]) {
        NSDictionary * dict = (NSDictionary *)object;
        for ( NSString * key in dict.allKeys ) {
            NSObject * obj = [dict objectForKey:key];
            if ( obj ) {
                Class typeClazz = [self p_typeOfClass:[obj class]];
                if ( [NSNumber class] == typeClazz ) {
                    [result setObject:obj forKey:key];
                }else if ( [NSString class] == typeClazz ) {
                    [result setObject:obj forKey:key];
                }else if ( [NSArray class] == typeClazz ) {
                    NSMutableArray * array = [NSMutableArray array];
                    for ( NSObject * elem in (NSArray *)obj ) {
                        NSDictionary * dict = [self p_dictionaryFromObject:elem];
                        if ( dict ) {
                            [array addObject:dict];
                        }else {
                            if ( [self p_isAtomClass:[elem class]] ) {
                                [array addObject:elem];
                            }
                        }
                    }
                    [result setObject:array forKey:key];
                }else if ( [NSDictionary class] == typeClazz ) {
                    NSMutableDictionary * dict = [NSMutableDictionary dictionary];
                    for ( NSString * key in ((NSDictionary *)obj).allKeys ) {
                        NSObject * val = [(NSDictionary *)obj objectForKey:key];
                        if ( val ) {
                            NSDictionary * subresult = [self p_dictionaryFromObject:val];
                            if ( subresult ) {
                                [dict setObject:subresult forKey:key];
                            }else {
                                if ( [self p_isAtomClass:[val class]] ) {
                                    [dict setObject:val forKey:key];
                                }
                            }
                        }
                    }
                    [result setObject:dict forKey:key];
                }else if ( [NSDate class] == typeClazz ) {
                    [result setObject:[obj description] forKey:key];
                }else { //自定义的obj
                    obj = [self p_dictionaryFromObject:obj];
                    if ( obj ) {
                        [result setObject:obj forKey:key];
                    }else {
                        [result setObject:[NSDictionary dictionary] forKey:key];
                    }
                }
            }
        }
        
    }
    
    if ([self p_isAtomClass:[object class]]) {
        return nil;
    }
    
    for ( Class clazzType = [object class];; )
    {
        if ( [self p_isAtomClass:clazzType] )
            break;
        
        unsigned int		propertyCount = 0;
        objc_property_t *	properties = class_copyPropertyList( clazzType, &propertyCount );
        
        for ( NSUInteger i = 0; i < propertyCount; i++ ) {
            const char *	name = property_getName(properties[i]);
            const char *	attr = property_getAttributes(properties[i]);
            
            NSString *		propertyName = [NSString stringWithCString:name encoding:NSUTF8StringEncoding];
            Class		typeClass = [self p_typeOfAttribute:attr];
            
            NSObject * obj = [object valueForKey:propertyName];
            if ( obj ) {
                if ([NSNumber class] == typeClass ||
                    [NSString class] == typeClass) {
                    
                    [result setObject:obj forKey:propertyName];
                }else if ( [NSArray class] == typeClass ) {
                    NSMutableArray * array = [NSMutableArray array];
                    for ( NSObject * elem in (NSArray *)obj ) {
                        Class elemType = [elem class];
                        if ([NSNumber class] == elemType ||
                            [NSString class] == elemType) {
                            
                            [array addObject:elem];
                        }else {
                            NSDictionary * dict = [self p_dictionaryFromObject:elem];
                            if ( dict ) {
                                [array addObject:dict];
                            }else {
                                if ( [self p_isAtomClass:[elem class]] ) {
                                    [array addObject:elem];
                                }
                            }
                        }
                    }
                    
                    [result setObject:array forKey:propertyName];
                }
                else if ( [NSDictionary class] == typeClass ) {
                    NSMutableDictionary * dict = [NSMutableDictionary dictionary];
                    
                    for ( NSString * key in ((NSDictionary *)obj).allKeys ) {
                        NSObject * val = [(NSDictionary *)obj objectForKey:key];
                        if ( val ) {
                            NSDictionary * subresult = [self p_dictionaryFromObject:val];
                            if ( subresult ) {
                                [dict setObject:subresult forKey:key];
                            }else {
                                if ( [self p_isAtomClass:[val class]] ) {
                                    [dict setObject:val forKey:key];
                                }
                            }
                        }
                    }
                    
                    [result setObject:dict forKey:propertyName];
                }
                else if ( [NSDate class] == typeClass )
                {
                    [result setObject:[obj description] forKey:propertyName];
                }
                else
                {
                    obj = [self p_dictionaryFromObject:obj];
                    if ( obj ) {
                        [result setObject:obj forKey:propertyName];
                    }else {
                        [result setObject:[NSDictionary dictionary] forKey:propertyName];
                    }
                }
            }
        }
        
        free( properties );
        
        clazzType = class_getSuperclass( clazzType );
        if ( nil == clazzType )
            break;
    }
    
    return result;
}

+ (Class)p_typeOfAttribute:(const char *)attr {
    
    @try {
        const char *property_type = attr;
        NSString *propertyType = [[NSString alloc] initWithBytes:property_type length:strlen(property_type) encoding:NSASCIIStringEncoding];
        
        if (property_type[1] == '@') {
            return NSClassFromString([propertyType componentsSeparatedByString:@"\""][1]);
        }else {  //基本类型
            return [NSNumber class];
        }
    }
    @catch (NSException *exception) {
        return nil;
    }
}

+ (Class)p_typeOfClass:(Class)clazz {
    
    if ( clazz == [NSArray class] || [[clazz description] isEqualToString:@"__NSCFArray"] )
        return [NSArray class];
    
    if ( clazz == [NSNumber class] || [[clazz description] isEqualToString:@"__NSCFNumber"] )
        return [NSNumber class];
    
    if ( clazz == [NSString class] || [[clazz description] isEqualToString:@"__NSCFString"] || [[clazz description] isEqualToString:@"__NSConstantString"] ||
        [[clazz description] isEqualToString:@"__NSCFConstantString"])
        return [NSString class];
    
    return clazz;
}

+ (BOOL)p_isAtomClass:(Class)clazz
{
    if ( clazz == [NSArray class] || [[clazz description] isEqualToString:@"__NSCFArray"] )
        return YES;
    if ( clazz == [NSData class] )
        return YES;
    if ( clazz == [NSDate class] )
        return YES;
    if ( clazz == [NSDictionary class] )
        return YES;
    if ( clazz == [NSNull class] )
        return YES;
    if ( clazz == [NSNumber class] || [[clazz description] isEqualToString:@"__NSCFNumber"] )
        return YES;
    if ( clazz == [NSObject class] )
        return YES;
    if ( clazz == [NSString class] || [[clazz description] isEqualToString:@"__NSCFString"] || [[clazz description] isEqualToString:@"__NSConstantString"] )
        return YES;
    if ( clazz == [NSURL class] )
        return YES;
    if ( clazz == [NSValue class] )
        return YES;
    
    return NO;
}
#pragma mark - 类型转换

+ (NSString *)p_asNSString:(id)object
{
    if ( [object isKindOfClass:[NSNull class]] )
        return nil;
    
    if ( [object isKindOfClass:[NSString class]] )
    {
        return (NSString *)object;
    }
    else if ( [object isKindOfClass:[NSData class]] )
    {
        NSData * data = (NSData *)object;
        
        NSString * text = [[NSString alloc] initWithBytes:data.bytes length:data.length encoding:NSUTF8StringEncoding];
        if ( nil == text )
        {
            text = [[NSString alloc] initWithData:data encoding:NSUTF8StringEncoding];
            if ( nil == text )
            {
                text = [[NSString alloc] initWithData:data encoding:NSASCIIStringEncoding];
            }
        }
        return text;
    }
    else
    {
        return [NSString stringWithFormat:@"%@", object];
    }
}

+ (NSNumber *)p_asNSNumber:(id)object
{
    if ( [object isKindOfClass:[NSNumber class]] )
    {
        return (NSNumber *)object;
    }
    else if ( [object isKindOfClass:[NSString class]] )
    {
        return [NSNumber numberWithFloat:[(NSString *)object floatValue]];
    }
    else if ( [object isKindOfClass:[NSDate class]] )
    {
        return [NSNumber numberWithDouble:[(NSDate *)object timeIntervalSince1970]];
    }
    else if ( [object isKindOfClass:[NSNull class]] )
    {
        return [NSNumber numberWithInteger:0];
    }
    
    return nil;
}

+ (NSDate *)p_asNSDate:(id)object
{
    if ( [object isKindOfClass:[NSDate class]] )
    {
        return (NSDate *)object;
    }
    else if ( [object isKindOfClass:[NSString class]] )
    {
        NSDate * date = nil;
        
        if ( nil == date )
        {
            static NSDateFormatter * formatter = nil;
            
            if ( nil == formatter )
            {
                formatter = [[NSDateFormatter alloc] init];
                [formatter setDateFormat:@"yyyy/MM/dd HH:mm:ss z"];
                [formatter setTimeZone:[NSTimeZone timeZoneForSecondsFromGMT:0]];
            }
            
            date = [formatter dateFromString:(NSString *)object];
        }
        
        if ( nil == date )
        {
            static NSDateFormatter * formatter = nil;
            
            if ( nil == formatter )
            {
                formatter = [[NSDateFormatter alloc] init];
                [formatter setDateFormat:@"yyyy-MM-dd HH:mm:ss z"];
                [formatter setTimeZone:[NSTimeZone timeZoneForSecondsFromGMT:0]];
            }
            
            date = [formatter dateFromString:(NSString *)object];
        }
        
        if ( nil == date )
        {
            static NSDateFormatter * formatter = nil;
            
            if ( nil == formatter )
            {
                formatter = [[NSDateFormatter alloc] init];
                [formatter setDateFormat:@"yyyy-MM-dd HH:mm:ss"];
                [formatter setTimeZone:[NSTimeZone timeZoneForSecondsFromGMT:0]];
            }
            
            date = [formatter dateFromString:(NSString *)object];
        }
        
        if ( nil == date )
        {
            static NSDateFormatter * formatter = nil;
            
            if ( nil == formatter )
            {
                formatter = [[NSDateFormatter alloc] init];
                [formatter setDateFormat:@"yyyy/MM/dd HH:mm:ss"];
                [formatter setTimeZone:[NSTimeZone timeZoneForSecondsFromGMT:0]];
            }
            
            date = [formatter dateFromString:(NSString *)object];
        }
        
        return date;
        
        //		NSTimeZone * local = [NSTimeZone localTimeZone];
        //		return [NSDate dateWithTimeInterval:(3600 + [local secondsFromGMT])
        //								  sinceDate:[dateFormatter dateFromString:text]];
    }
    else
    {
        return [NSDate dateWithTimeIntervalSince1970:[self p_asNSNumber:object].doubleValue];
    }
    
    return nil;
}

@end
