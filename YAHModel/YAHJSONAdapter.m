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

+ (nullable id)objectFromJsonData:(id)jsonData objectClass:(Class)clazz {
    
    if (nil == jsonData) {
        return nil;
    }
    if ([jsonData isKindOfClass:[NSData class]]) {
        return [self p_objectFromData:jsonData objectClass:clazz];
    }else if ([jsonData isKindOfClass:[NSString class]]) {
        NSData* data = [jsonData dataUsingEncoding:NSUTF8StringEncoding];
        return [self p_objectFromData:data objectClass:clazz];
    }else if ([jsonData isKindOfClass:[NSDictionary class]]) {
        return [self p_objectFromDictionary:jsonData class:clazz];
    }else if ([jsonData isKindOfClass:[NSArray class]]) {
        return [self p_objectFromArray:jsonData objectClass:clazz];
    }
    
    return nil;
}

+ (NSString *)jsonStringFromObject:(id)object {
    
    NSString *json = nil;
    id t_d = nil;
    if ([object isKindOfClass:NSArray.class]) {
        t_d = [self p_arrayWithArray:object];
    }else {
        t_d  = [self p_dictionaryFromObject:object];
    }
    if (t_d) {
        NSData *jsonData = [NSJSONSerialization dataWithJSONObject:t_d options:NSJSONWritingPrettyPrinted error:nil];
        json = [[NSString alloc] initWithData:jsonData
                                     encoding:NSUTF8StringEncoding];
    }
    return [json copy];
}

+ (NSDictionary *)jsonDictionaryFromObject:(id)object {
    
    return [self p_dictionaryFromObject:object];
}

#pragma mark - Private

+ (id)p_objectFromData:(NSData *)data objectClass:(Class)clazz {
    
    NSError *error = nil;
    NSObject * obj = [NSJSONSerialization JSONObjectWithData:data options:0 error:&error];
    if ( obj ) {
        if ( [obj isKindOfClass:[NSDictionary class]] ) {
            return [self p_objectFromDictionary:(NSDictionary *)obj class:clazz];
        }else if ( [obj isKindOfClass:[NSArray class]] ) {
            return [self p_objectFromArray:(NSArray *)obj objectClass:clazz];
        }
    }
    
    return nil;
}

+ (id)p_objectFromArray:(NSArray *)array objectClass:(Class)clazz {
    
    NSMutableArray * results = [NSMutableArray array];
    for (id obj in array) {
        if ([obj isKindOfClass:[NSDictionary class]]) {
            id newObj = [self p_objectFromDictionary:obj class:clazz];
            if (newObj) {
                [results addObject:newObj];
            }
        }else if ([obj isKindOfClass:[NSArray class]]) {
            id newObj = [self p_objectFromArray:(NSArray *)obj objectClass:clazz];
            if (newObj) {
                [results addObject:newObj];
            }
        }else {
            [results addObject:obj];
        }
    }
    
    return [results copy];
}

#pragma mark 转化过程
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
            NSString *propertyKey = [[clazzType JSONKeyPathsByPropertyKey] objectForKey:propertyName];
            
            NSObject *	tempValue = [dic objectForKey:propertyKey];
            NSObject *	value = nil;
            
            if ( tempValue ) {
                if ([typeClass isSubclassOfClass:[NSNumber class]]) {
                    value = [self p_asNSNumber:tempValue];
                }else if ([typeClass isSubclassOfClass:[NSString class]]) {
                    value = [self p_asNSString:tempValue];
                }else if ([typeClass isSubclassOfClass:[NSArray class]]) {
                    if ([tempValue isKindOfClass:[NSArray class]] ) {
                        id convertClass = [[clazzType convertClassStringDictionary] objectForKey:propertyName];
                        if (convertClass) {
                            if ([convertClass isKindOfClass:[NSString class]]) {
                                convertClass = NSClassFromString(convertClass);
                            }
                            if (convertClass) {
                                value = [self p_objectFromArray:(NSArray *)tempValue objectClass:convertClass];
                            }
                            else {
                                value = tempValue;
                            }
                        }
                        else {
                            value = tempValue;
                        }
                    }
                }else if ([typeClass isSubclassOfClass:[NSDictionary class]]) {
                    if ([tempValue isKindOfClass:[NSDictionary class]]) {
                        value = tempValue;
                    }
                }else {  //nsobject类
                    if ([tempValue isKindOfClass:typeClass]) {
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

+ (NSArray *)p_arrayWithArray:(NSArray *)objects {
    
    if (![objects isKindOfClass:NSArray.class]) {
        return nil;
    }
    NSMutableArray *tmpList = [NSMutableArray arrayWithCapacity:1];
    for (id object in objects) {
        NSDictionary *dict = [self p_dictionaryFromObject:object];
        if (!dict) {
            continue;
        }
        [tmpList addObject:dict];
    }
    return [tmpList copy];
}

+ (NSDictionary *)p_dictionaryFromObject:(id)object {
    
    NSMutableDictionary *result = [NSMutableDictionary dictionary];
    
    if ([object isKindOfClass:[NSDictionary class]]) {
        NSDictionary * dict = (NSDictionary *)object;
        for ( NSString * key in dict.allKeys ) {
            NSObject * obj = [dict objectForKey:key];
            if ( obj ) {
                Class typeClazz = [obj class];
                if ([typeClazz isSubclassOfClass:[NSNumber class]] ||
                    [typeClazz isSubclassOfClass:[NSString class]]) {
                    [result setObject:obj forKey:key];
                }else if ( [NSDate class] == typeClazz ) {
                    [result setObject:[obj description] forKey:key];
                }else if ([typeClazz isSubclassOfClass:[NSArray class]]) {
                    NSMutableArray * array = [NSMutableArray array];
                    for ( NSObject * elem in (NSArray *)obj ) {
                        NSDictionary * dict = [self p_dictionaryFromObject:elem];
                        if ( dict ) {
                            [array addObject:dict];
                        }else { //系统类  nsstring等
                            [array addObject:elem];
                        }
                    }
                    [result setObject:array forKey:key];
                }else if ([typeClazz isSubclassOfClass:[NSDictionary class]]) {
                    NSMutableDictionary * dict = [NSMutableDictionary dictionary];
                    for ( NSString * key in ((NSDictionary *)obj).allKeys ) {
                        NSObject * val = [(NSDictionary *)obj objectForKey:key];
                        if ( val ) {
                            NSDictionary * subresult = [self p_dictionaryFromObject:val];
                            if ( subresult ) {
                                [dict setObject:subresult forKey:key];
                            }else {
                                [dict setObject:val forKey:key];
                            }
                        }
                    }
                    [result setObject:dict forKey:key];
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
    
    if (![self p_isCustomClass:[object class]]) {
        return nil;
    }
    
    for ( Class clazzType = [object class];; )
    {
        if (![self p_isCustomClass:clazzType])
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
                if ([typeClass isSubclassOfClass:NSNumber.class] ||
                    [typeClass isSubclassOfClass:NSString.class] ||
                    (NSObject.class == typeClass && ([obj isKindOfClass:NSNumber.class] ||
                                                     [obj isKindOfClass:NSString. class]))) {
                    [result setObject:obj forKey:propertyName];
                }else if ( [NSDate class] == typeClass ||
                          (NSObject.class == typeClass && [obj isKindOfClass:NSDate.class])){
                    [result setObject:[obj description] forKey:propertyName];
                }else if ( [NSArray class] == typeClass ||
                          (NSObject.class == typeClass && [obj isKindOfClass:NSArray.class])) {
                    NSMutableArray * array = [NSMutableArray array];
                    for ( NSObject * elem in (NSArray *)obj ) {
                        NSDictionary * dict = [self p_dictionaryFromObject:elem];
                        if ( dict ) {
                            [array addObject:dict];
                        }else {
                            [array addObject:elem];
                        }
                    }
                    [result setObject:array forKey:propertyName];
                }else if ( [NSDictionary class] == typeClass ||
                          (NSObject.class == typeClass && [obj isKindOfClass:NSDictionary.class])) {
                    NSMutableDictionary * dict = [NSMutableDictionary dictionary];
                    for ( NSString *key in ((NSDictionary *)obj).allKeys ) {
                        NSObject *val = [(NSDictionary *)obj objectForKey:key];
                        if ( val ) {
                            NSDictionary * subresult = [self p_dictionaryFromObject:val];
                            if ( subresult ) {
                                [dict setObject:subresult forKey:key];
                            }else {
                                [dict setObject:val forKey:key];
                            }
                        }
                    }
                    [result setObject:dict forKey:propertyName];
                }else{
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
    
    return [result copy];
}

+ (Class)p_typeOfAttribute:(const char *)attr {
    
    @try {
        
        NSString *attrs = @(attr);
        NSUInteger dotLoc = [attrs rangeOfString:@","].location;
        NSString *code = nil;
        NSUInteger loc = 1;
        if (dotLoc == NSNotFound) { // 没有,
            code = [attrs substringFromIndex:loc];
        } else {
            code = [attrs substringWithRange:NSMakeRange(loc, dotLoc - loc)];
        }
        
        if ([code isEqualToString:@"@"]) {//id类型
            return [NSObject class];
        }else if (code.length > 3 && [code hasPrefix:@"@\""]) {
            code = [code substringWithRange:NSMakeRange(2, code.length - 3)];
            return NSClassFromString(code);
        }else {  //基本类型
            return [NSNumber class];
        }
    }
    @catch (NSException *exception) {
        return nil;
    }
}

//是否为自定义的类
+ (BOOL)p_isCustomClass:(Class)clazz
{
    NSBundle *bundle = [NSBundle bundleForClass:clazz];
    if (bundle == [NSBundle mainBundle]) {
        return YES;
    }else {
        return NO;
    }
}
#pragma mark  类型转换

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
        double test = [(NSString *)object doubleValue];
        return [NSNumber numberWithDouble:test];
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

@end
