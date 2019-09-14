//
//  ViewController.m
//  NTCalendarDemo
//
//  Created by Lenhulk on 2019/9/14.
//  Copyright © 2019 NeilTes. All rights reserved.
//

#import "ViewController.h"
#import "NTCalendar/NTCalendar.h"

@interface ViewController ()

@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    
    NTCalendar *calendar = [[NTCalendar alloc] initWithFrame:(CGRect){0, 44, [UIScreen mainScreen].bounds.size.width, 240}];
    calendar.didSelectDateHandler = ^(NSInteger y, NSInteger m, NSInteger d, UILabel * _Nonnull textLb) {
        NSLog(@"%@", [NSString stringWithFormat:@"当前日期：%ld-%ld-%ld", y, m, d]);
        textLb.text = [NSString stringWithFormat:@"新日程(%d)", arc4random_uniform(10)];
    };
    [self.view addSubview:calendar];
}


@end
