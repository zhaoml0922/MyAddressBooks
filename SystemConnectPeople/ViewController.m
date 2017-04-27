//
//  ViewController.m
//  SystemConnectPeople
//
//  Created by zhaoml on 2017/4/25.
//  Copyright © 2017年 赵明亮. All rights reserved.
//

#import "ViewController.h"
#import "ConnectPeopleViewController.h"
@interface ViewController ()

@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.view.backgroundColor = [UIColor whiteColor];
    
    UIButton *btn = [UIButton buttonWithType:UIButtonTypeRoundedRect];
    [btn setTitle:@"进入通讯录" forState:UIControlStateNormal];
    btn.frame = self.view.bounds;
    [btn addTarget:self action:@selector(tapClick) forControlEvents:UIControlEventTouchUpInside];
    [self.view addSubview:btn];
    
    // Do any additional setup after loading the view, typically from a nib.
}

- (void)tapClick {
    ConnectPeopleViewController *cccc = [[ConnectPeopleViewController alloc] init];
    [self.navigationController pushViewController:cccc animated:YES];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}


@end
