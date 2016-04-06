//
//  ViewController.m
//  Demo
//
//  Created by yahua on 16/4/5.
//  Copyright © 2016年 wangsw. All rights reserved.
//

#import "ViewController.h"
#import "MobileModelRequest.h"

#import "TestRequestManager.h"
#import "MobileModel.h"

@interface ViewController ()

@property (nonatomic, strong) MobileModelRequest *mobileModelRequest;

@property (nonatomic, strong) MobileModel *mobileModel;

@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view, typically from a nib.
    
    [self.mobileModelRequest getNetworkData];
    
    
    [[TestRequestManager shareInstance] GET:@"mobilenumber/mobilenumber" parameters:@{@"phone": @"18559197250"} headers:@{@"apikey": @"百度的 apistore 的key"} success:^(NSData *data) {
        [self.mobileModel analyseWithData:data complete:^(NSError * _Nonnull error) {
            NSLog(@"");
        }];
    } failure:^(NSError *error) {
        
    }];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - Getters and Setters

- (MobileModelRequest *)mobileModelRequest {
    
    if (!_mobileModelRequest) {
        _mobileModelRequest = [[MobileModelRequest alloc] init];
    }
    
    return _mobileModelRequest;
}

- (MobileModel *)mobileModel {
    
    if (!_mobileModel) {
        _mobileModel = [[MobileModel alloc] init];
    }
    
    return _mobileModel;
}

@end
