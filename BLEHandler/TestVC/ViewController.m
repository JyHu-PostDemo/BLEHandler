//
//  ViewController.m
//  BLEHandler
//
//  Created by 胡金友 on 16/5/2.
//  Copyright © 2016年 胡金友. All rights reserved.
//

#import "ViewController.h"
#import "AUUCentralManagerViewController.h"
#import "AUUPeripheralManagerViewController.h"

@interface ViewController ()

@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view, typically from a nib.
    
}

- (IBAction)turnToCentralVC:(id)sender
{
    [self.navigationController pushViewController:[[AUUCentralManagerViewController alloc] init] animated:YES];
}

- (IBAction)turnToPeripheralVC:(id)sender
{
    [self.navigationController pushViewController:[[AUUPeripheralManagerViewController alloc] init] animated:YES];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end
