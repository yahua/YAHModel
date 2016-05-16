# YAHModel
网络请求封装 使用NSURLSession

# How to use
    //第一种  会自动将model与json匹配
    self.mobileNumber = [MobileNumber new];
    [self.mobileNumber checkMobileNumber:@"15210011578"];
    
    //第二种 返回json字典
    NSURLSessionDataTask *task =  [YAHRequestManager
    getNetworkDataWithURL:@"http://apis.baidu.com/apistore/mobilenumber/mobilenumber" 
               method:@"GET" 
        completeBlock:^(NSDictionary * _Nullable jsonDic, NSError * _Nullable error) {
        NSLog(@"%@", jsonDic);
    } parameters:@{@"phone": @"15210011578"} 
         headers:@{@"apikey": @"123456789"}];

一般项目使用的是第一种。
例如服务端返回的这种JSON

    {
    "errNum": 0,
    "retMsg": "success",
    "retData": {
        "phone": "15210011578",
        "prefix": "1521001",
        "supplier": "移动 ",
        "province": "北京 ",
        "city": "北京 ",
        "suit": "152卡"
        }
    }
需要新建三个类来处理

    .h
    @interface MobileData : YAHActiveObject
    
    @property (nonatomic, copy) NSString *phone;
    @property (nonatomic, copy) NSString *prefix;
    @property (nonatomic, copy) NSString *supplier;
    @property (nonatomic, copy) NSString *province;
    @property (nonatomic, copy) NSString *city;
    @property (nonatomic, copy) NSString *suit;

    @end

    @interface MobileRespone : YAHDataResponseInfo

    @property (nonatomic, strong) MobileData *retData;

    @end

    @interface MobileNumber : YAHModelRequest

    - (void)checkMobileNumber:(NSString *)number;

    @end
    
    .m
    #import "MobileNumber.h"

    @implementation MobileData
    @end

    @implementation MobileRespone
    @end
    
    @implementation MobileNumber

    - (instancetype)init
    {
        self = [super initWithURL:@"mobilenumber/mobilenumber" resultClass:[MobileRespone class]];
        if (self) {
            self.method = @"GET";
            [self setValue:@"" forHTTPHeaderField:@"apikey"];  //apikey http://apistore.baidu.com/ 上注册
        }
        return self;
    }

    - (void)checkMobileNumber:(NSString *)number {
    
        [self addParamWithkey:@"phone" value:number];
        [self getNetworkData:^{
        NSLog(@"%@", self.result);
        } failure:^(NSString * _Nullable errorMsg) {
        NSLog(@"%@", errorMsg);
        }];
    }

    @end
    
    MobileNumber 网络请求
    MobileRespone 返回数据检验 （是否有效）
    MobileData  需要用到的返回数据  该类中的属性名要与jso中的key要一一对应，若想不对应需要重
    写changeJSONPropertyKey该函数,若属性是某个类需要重写convertClassString函数
    + (NSDictionary *)changeJSONPropertyKey {
        return @{@"mykey":@"jsonkey"};
    }
    + (NSDictionary *)convertClassString {
        return @{@"property":@"class"};
    }


# 待续
