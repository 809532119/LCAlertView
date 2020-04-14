//
//  ViewController.m
//  TestAlert
//
//  Created by 刘冲 on 2020/4/14.
//  Copyright © 2020 Konke. All rights reserved.
//

#import "ViewController.h"
#import "LCAlertView.h"

@interface ViewController ()

@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    
}

-(void)touchesBegan:(NSSet<UITouch *> *)touches withEvent:(UIEvent *)event {
    LCAlertView *alert = [[LCAlertView alloc]initWithStyle:KKAlertViewStyleActionSheet title:@"" message:@"" cancelTitle:@"" otherTitles:@[@"查看",@"快捷"] handler:^(NSInteger index) {
        
    }];
    alert.otherTitleColor = [UIColor colorWithRed:29/255.0 green:166/255.0 blue:96/255.0 alpha:1];
    [alert showInView:self.view];
}

@end
