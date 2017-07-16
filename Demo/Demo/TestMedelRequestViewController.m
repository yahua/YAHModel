//
//  TestMedelRequestViewController.m
//  Demo
//
//  Created by 王时温 on 2017/7/16.
//  Copyright © 2017年 wangsw. All rights reserved.
//

#import "TestMedelRequestViewController.h"
#import "MobileModelRequest.h"

@interface TestMedelRequestViewController ()

@property (nonatomic, strong) MobileModelRequest *mobileModelRequest;

@end

@implementation TestMedelRequestViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view from its nib.
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}
- (IBAction)antionRequest:(id)sender {
    [self.mobileModelRequest getNetworkData];
}
- (IBAction)antionClearRequsrtCache:(id)sender {
    [self.mobileModelRequest clearCache];
}
- (IBAction)antionClearModelCache:(id)sender {
    [MobileModelRequest clearAllCache];
}
- (IBAction)actionClearYAHModelCache:(id)sender {
    [YAHModel clearAllCache];
}

- (MobileModelRequest *)mobileModelRequest {
    
    if (!_mobileModelRequest) {
        _mobileModelRequest = [[MobileModelRequest alloc] init];
    }
    
    return _mobileModelRequest;
}

@end
