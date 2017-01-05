//
//  ViewController.m
//  二维码扫描demo
//
//  Created by m on 2017/1/3.
//  Copyright © 2017年 XLJ. All rights reserved.
//

#import "ViewController.h"
#import "XLJGenerateQRCodeController.h"
#import "XLJScanController.h"
#import "XLJScanQRCController.h"
#import "XLJwebVController.h"

@interface ViewController ()<UITextFieldDelegate>

@property (weak, nonatomic) IBOutlet UITextField *inputTextString;

@property (nonatomic, strong) UIImage *imgScan;
@end

@implementation ViewController

//生成二维码
- (IBAction)generateButtonAction:(id)sender {
    XLJGenerateQRCodeController *vc = [XLJGenerateQRCodeController new];
    
    if (self.inputTextString.text.length == 0) {
        vc.inputString = @"http://www.jianshu.com/u/d310bc03c7cc";
    }else{
        vc.inputString = self.inputTextString.text;
    }
    
    vc.imageName = @"1024";
   
    [self.navigationController pushViewController:vc animated:YES];
}

//识别二维码
- (IBAction)identifyButtonAction:(id)sender {
    
    XLJScanController *vc = [XLJScanController new];
    
    [self.navigationController pushViewController:vc animated:YES];
    
}

//扫描二维码
- (IBAction)scanButtonAction:(id)sender {
    
    XLJScanQRCController *vc = [XLJScanQRCController new];
    
    [self.navigationController pushViewController:vc animated:YES];
    
}
//封装库使用
- (IBAction)encapsulationLibButtonAction:(id)sender {

    [[UIApplication sharedApplication] openURL:[NSURL URLWithString:@"http://www.jianshu.com/u/d310bc03c7cc"]];
}


- (void)viewDidLoad {
    [super viewDidLoad];
 
    self.inputTextString.delegate = self;
    
    
}

- (BOOL)textFieldShouldReturn:(UITextField *)textField
{
    self.inputTextString = textField;
    
    return YES;
}


@end
