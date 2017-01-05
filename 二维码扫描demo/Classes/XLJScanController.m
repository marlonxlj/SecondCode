//
//  XLJScanController.m
//  二维码扫描demo
//
//  Created by m on 2017/1/4.
//  Copyright © 2017年 XLJ. All rights reserved.
//

#import "XLJScanController.h"
#import "XLJGenerateQRCodeController.h"

@interface XLJScanController ()

@property (nonatomic, strong) UIImageView *imageView;

@property (nonatomic, strong) UIView *lineView;

@property (nonatomic, strong) UIImage *sourceImage;

@property (nonatomic, strong) UIImageView *imageViewNew;

@property (nonatomic, strong) UIImage *imageNew;

@property (nonatomic, copy) NSString *urlString;

@end

@implementation XLJScanController

- (UIImageView *)imageView
{
    if (!_imageView) {
        _imageView = [[UIImageView alloc] initWithFrame:CGRectMake((self.view.frame.size.width - 200)/2.0, 100, 200, 200)];
        
        //取出沙盒的图片
        NSString *myDir = [[NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES) objectAtIndex:0] stringByAppendingString:@"/imageName"];
        
        _imageView.image = [[UIImage alloc] initWithContentsOfFile:myDir];
        self.sourceImage = _imageView.image;
    }
    
    return _imageView;
}

- (UIView *)lineView
{
    if (!_lineView) {
        _lineView = [[UIView alloc] initWithFrame:CGRectMake(0, 310, self.view.frame.size.width, 2)];
        _lineView.backgroundColor = [UIColor brownColor];
        
    }
    
    return _lineView;
}

- (UIImageView *)imageViewNew
{
    if (!_imageViewNew) {
        _imageViewNew = [[UIImageView alloc] initWithFrame:CGRectMake((self.view.frame.size.width - 200)/2.0, 374, 200, 200)];
        
    }
    
    return _imageViewNew;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    self.view.backgroundColor = [UIColor whiteColor];
    self.title = @"识别二维码";
    
    [self.view addSubview:self.lineView];
    [self.view addSubview:self.imageView];
    [self.view addSubview:self.imageViewNew];
    
    //第一个按钮
    UIButton *button = [[UIButton alloc] initWithFrame:CGRectMake((self.view.frame.size.width - 100)/4.0, 320, 100, 44)];
    [button setTitle:@"开始识别" forState:UIControlStateNormal];
    [button setTitleColor:[UIColor blueColor] forState:UIControlStateNormal];
    
    button.backgroundColor = [UIColor orangeColor];
    [self.view addSubview:button];
    [button addTarget:self action:@selector(buttonAction) forControlEvents:UIControlEventTouchUpInside];
    
    //第二个按钮
    UIButton *button1 = [[UIButton alloc] initWithFrame:CGRectMake((self.view.frame.size.width - 100)/4.0*3, 320, 100, 44)];
    [button1 setTitle:@"识别二维码" forState:UIControlStateNormal];
    [button1 setTitleColor:[UIColor blueColor] forState:UIControlStateNormal];
    
    button1.backgroundColor = [UIColor yellowColor];
    [self.view addSubview:button1];
    [button1 addTarget:self action:@selector(openQRCodeUrl) forControlEvents:UIControlEventTouchUpInside];
    
}

- (void)openQRCodeUrl
{
    [[UIApplication sharedApplication] openURL:[NSURL URLWithString:self.urlString]];
}

- (void)buttonAction
{
    [self detectorQRCodeImageWithSourceImage:self.sourceImage isDrawCodeFrame:YES completeBlock:^(NSArray *resultArray, UIImage *resultImage) {
        
    }];
}

- (void)detectorQRCodeImageWithSourceImage:(UIImage *)sourceImage isDrawCodeFrame:(BOOL)isDrawCodeFrame completeBlock:(void(^)(NSArray *resultArray, UIImage *resultImage))completeBlock
{
    
    //1.创建上下文
    CIContext *context = [[CIContext alloc] init];
    
    //2.创建一个探测器
    CIDetector *detector = [CIDetector detectorOfType:@"CIDetectorTypeQRCode" context:context options:@{CIDetectorAccuracy: CIDetectorAccuracyLow}];
    
    //3.直接开始识别图片，获取图片特征
    CIImage *imageCI = [[CIImage alloc] initWithImage:self.sourceImage];
    NSArray <CIFeature *> *features = [detector featuresInImage:imageCI];
    
    //4.读取特征
    UIImage *tempImage = sourceImage;
    
    NSMutableArray *resultArray = @[].mutableCopy;
    
    for (CIFeature *feature in features) {
        
        CIQRCodeFeature *tempFeature = (CIQRCodeFeature *)feature;
        [resultArray addObject:tempFeature.messageString];
        //获取到二维码的东西
        self.urlString = tempFeature.messageString;
        
        if (isDrawCodeFrame) {
            tempImage = [self drawQRCodeFrameFeatre: tempFeature toImage: tempImage];
        }
    }
    
    //5.将数据传递给外界
    completeBlock(resultArray, tempImage);
    
    self.imageViewNew.image = tempImage;
    
}

- (UIImage *)drawQRCodeFrameFeatre:(CIQRCodeFeature *)feature toImage:(UIImage *)toImage
{
    CGRect bounds = feature.bounds;
    CGSize size = toImage.size;
    
    //1.开启图形上下文
    UIGraphicsBeginImageContext(size);
    
    //2.绘制图片
    [toImage drawInRect:CGRectMake(0, 0, size.width, size.height)];
    
    //3.反转上下文坐标系
    CGContextRef context = UIGraphicsGetCurrentContext();
    CGContextScaleCTM(context, 1, -1);
    CGContextTranslateCTM(context, 0, -size.height);
    
    //4.绘制边框
//    UIBezierPath *path = [UIBezierPath bezierPathWithRect:bounds];
    UIBezierPath *path = [UIBezierPath bezierPathWithRoundedRect:bounds cornerRadius:5];
    path.lineWidth = 12;

    [[UIColor orangeColor] setStroke];
    [path stroke];
    
    //5.取出图片
    UIImage *newImage = UIGraphicsGetImageFromCurrentImageContext();;
    
    //6.关闭上下文
    UIGraphicsEndImageContext();
    
    return newImage;
}




@end
