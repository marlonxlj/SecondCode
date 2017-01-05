//
//  XLJScanQRCController.m
//  二维码扫描demo
//
//  Created by m on 2017/1/4.
//  Copyright © 2017年 XLJ. All rights reserved.
//

#import "XLJScanQRCController.h"
#import <AVFoundation/AVFoundation.h>

#define Height [UIScreen mainScreen].bounds.size.height
#define Width [UIScreen mainScreen].bounds.size.width
#define XCenter self.view.center.x
#define YCenter self.view.center.y

#define SHeight 20

#define SWidth (XCenter+30)
@interface XLJScanQRCController ()<AVCaptureMetadataOutputObjectsDelegate>
{
    NSTimer *_timer;
    int num;
    BOOL upOrDown;

}
/**输入设置*/
@property (nonatomic, strong) AVCaptureDeviceInput *captureDeviceInput;
/**数据输出*/
@property (nonatomic, strong) AVCaptureMetadataOutput *dataOutPut;
/**会话*/
@property (nonatomic, strong) AVCaptureSession *captureSeesion;
/**预栏图层*/
@property (nonatomic, strong) AVCaptureVideoPreviewLayer *previerLayer;
/**绘图图层*/
@property (nonatomic, strong) CALayer *drawLayer;
/**扫描框*/
@property (nonatomic, strong) UIImageView *scannerImageView;
/**扫描线*/
@property (nonatomic, strong) UIImageView *scannerLine;

@end

@implementation XLJScanQRCController

- (AVCaptureDeviceInput *)captureDeviceInput
{
    if (!_captureDeviceInput) {
        //获取一个视频捕捉设置
        AVCaptureDevice *device = [AVCaptureDevice defaultDeviceWithMediaType:AVMediaTypeVideo];
        //通过捕捉设置获取一个输入设备
        NSError *error = nil;
        _captureDeviceInput = [AVCaptureDeviceInput deviceInputWithDevice:device error:&error];
        if (!error) {
            NSLog(@"获取输入设备成功");
        }else{
            NSLog(@"获取输入设备失败");
        }
    }
    
    return _captureDeviceInput;
}
// 设置输出对象解析数据时感兴趣的范围
// 默认值是 CGRect(x: 0, y: 0, width: 1, height: 1)
// 通过对这个值的观察, 我们发现传入的是比例
// 注意: 参照是以横屏的左上角作为, 而不是以竖屏
// dataOutPut = CGRect(x: 0, y: 0, width: 0.5, height: 0.5)
- (AVCaptureMetadataOutput *)dataOutPut
{
    if (!_dataOutPut) {
        _dataOutPut = [[AVCaptureMetadataOutput alloc] init];
        //设置输出数据代理
        [_dataOutPut setMetadataObjectsDelegate:self queue:dispatch_get_main_queue()];
        
        //限制扫描的区域
        [_dataOutPut setRectOfInterest:[self rectInterstScanViewRect:self.scannerImageView.frame]];
    }
    
    return _dataOutPut;
}

- (AVCaptureSession *)captureSeesion
{
    if (!_captureSeesion) {
        _captureSeesion = [[AVCaptureSession alloc] init];
    }
    return _captureSeesion;
}

//- (AVCaptureVideoPreviewLayer *)previerLayer
//{
//    if (!_previerLayer) {
//        _drawLayer = [AVCaptureVideoPreviewLayer layerWithSession:self.captureSeesion];
//        
//        _previerLayer.frame = self.view.bounds;
//        _previerLayer.videoGravity = AVLayerVideoGravityResize;
//    }
//    
//    return _previerLayer;
//}

//preview
- (AVCaptureVideoPreviewLayer *)previerLayer
{
    if (_previerLayer == nil) {
        _previerLayer = [AVCaptureVideoPreviewLayer layerWithSession:self.captureSeesion];
    }
    return _previerLayer;
}


- (CALayer *)drawLayer
{
    if (!_drawLayer) {
        _drawLayer = [CALayer layer];
        _drawLayer.frame = self.previerLayer.bounds;
    }
    
    return _drawLayer;
}

- (CGRect)rectInterstScanViewRect:(CGRect)rect
{
    CGFloat width = CGRectGetWidth(self.view.frame);
    CGFloat height = CGRectGetHeight(self.view.frame);
    
    CGFloat x = (height - CGRectGetHeight(rect))/2.0/height;
    CGFloat y = (width - CGRectGetWidth(rect))/2.0/width;
    CGFloat w = CGRectGetHeight(rect)/height;
    CGFloat h = CGRectGetWidth(rect)/width;
    
    return CGRectMake(x, y, w, h);
}

- (void)viewDidLoad {
    [super viewDidLoad];
    self.title = @"扫描二维码";
    
    //1.添加扫描框
    [self addBgImageView];
    
    //1.1 添加背景模糊效果
    [self setBgOverView];
    
    //2.扫描动画
    [self addTimer];
    
    //3.开始扫描
    [self startScanning];

}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    
    
}

//添加背景模糊效果
- (void)setBgOverView
{
    CGFloat width = CGRectGetWidth(self.view.frame);
    CGFloat height = CGRectGetHeight(self.view.frame);
    
    CGFloat x = CGRectGetMinX(self.scannerImageView.frame);
    CGFloat y = CGRectGetMinY(self.scannerImageView.frame);
    CGFloat w = CGRectGetWidth(self.scannerImageView.frame);
    CGFloat h = CGRectGetHeight(self.scannerImageView.frame);

    [self creatView:CGRectMake(0, 0, width, y)];
    [self creatView:CGRectMake(0, y, x, h)];
    [self creatView:CGRectMake(0, y + h, width, height - y - h)];
    [self creatView:CGRectMake(x + w, y, width - x - w, h)];
}
//背景层
- (void)creatView:(CGRect)rect
{
    CGFloat alpha = 0.5;
    UIColor *backColor = [UIColor orangeColor];
    
    UIView *view = [[UIView alloc] initWithFrame:rect];

    view.backgroundColor = backColor;
    
    view.alpha = alpha;
    
    [self.view addSubview:view];
}
//添加扫描边框
- (void)addBgImageView
{
    self.scannerImageView = [[UIImageView alloc] initWithFrame:CGRectMake((Width - SWidth)/2.0, (Height - SWidth)/2.0, SWidth, SWidth)];
    //显示扫描框
    self.scannerImageView.image = [UIImage imageNamed:@"scanscanBg"];
    [self.view addSubview:self.scannerImageView];
    
    //扫描线
    self.scannerLine = [[UIImageView alloc] initWithFrame:CGRectMake(CGRectGetMinX(self.scannerImageView.frame)+5, CGRectGetMinY(self.scannerImageView.frame)+5, CGRectGetWidth(self.scannerImageView.frame), 3)];
    self.scannerLine.image = [UIImage imageNamed:@"scanLine"];
    [self.view addSubview:self.scannerLine];
}
- (void)startScanning
{
    //1.判断输入输出能否加入当前会话
    if ([self.captureSeesion canAddInput:self.captureDeviceInput] && [self.captureSeesion canAddOutput:self.dataOutPut]) {
        //可以加入当前会话
        [self.captureSeesion addInput:self.captureDeviceInput];
        [self.captureSeesion addOutput:self.dataOutPut];
        
    }else{
        return;
    }
    
    // 1.1 添加一个视频预览图层
    self.previerLayer.frame = self.view.bounds;

    //2.设置输出数据媒体类型
    [self.dataOutPut setMetadataObjectTypes:@[AVMetadataObjectTypeEAN13Code, AVMetadataObjectTypeEAN8Code, AVMetadataObjectTypeCode128Code, AVMetadataObjectTypeQRCode]];
    
    //2.1 高质量采集率
    [self.captureSeesion setSessionPreset:AVCaptureSessionPresetHigh];
    
    //3.添加预栏图层，放在最底层
    [self.view.layer insertSublayer:self.previerLayer atIndex:0];
    //4.添加绘图图层到预栏图层上面
    [self.previerLayer addSublayer:self.drawLayer];
    
    //6.开始扫描
    [self.captureSeesion startRunning];
    
    //7.停止扫描的方法
//    [self.captureSeesion stopRunning];
    
    [_timer setFireDate:[NSDate distantPast]];
    self.scannerLine.hidden = NO;
}

#pragma mark - AVCaptureMetadataOutputObjectsDelegate代理
//得到扫描结果
- (void)captureOutput:(AVCaptureOutput *)captureOutput didOutputMetadataObjects:(NSArray *)metadataObjects fromConnection:(AVCaptureConnection *)connection
{
    //1.移除之前的边框
    [self removeQRCodeFrame];

    if (metadataObjects == nil || metadataObjects.count == 0) {
        NSLog(@"未能识别");
    }
    
    [[UIApplication sharedApplication] openURL:[NSURL URLWithString:[metadataObjects.lastObject stringValue]]];
    
    for (AVMetadataObject *obj in metadataObjects) {
        //转换成机器可读的编码数据
        AVMetadataMachineReadableCodeObject *codeObj = (AVMetadataMachineReadableCodeObject *)[self.previerLayer transformedMetadataObjectForMetadataObject:obj];
        
        //绘制二维码边框
        [self drawQRBorderShape:codeObj];
    }
}

//绘制二维码边框
- (void)drawQRBorderShape:(AVMetadataMachineReadableCodeObject *)codeObj
{
    if (codeObj.corners.count == 0) {
        return;
    }
    
    NSLog(@"codeObj.conners=%@",codeObj.corners);
    
    //1.绘制白赛尔曲线图形一般和CAShapLayer配合使用
    //1.1 创建CAShapeLayer,设置画笔的颜色，线条宽度，填充颜色等
    CAShapeLayer *shapeLayer = [CAShapeLayer layer];
    shapeLayer.strokeColor = [UIColor greenColor].CGColor;
    shapeLayer.lineWidth = 1.0f;
    shapeLayer.fillColor = [UIColor clearColor].CGColor;
    
    //2.创建一个贝塞尔曲线
    UIBezierPath *path = [UIBezierPath bezierPath];
    NSInteger index = 0;
    CGPoint point = CGPointZero;
    
    //2.1 绘制线条
    CFDictionaryRef dictRef = (__bridge CFDictionaryRef)(codeObj.corners[index]);
    CGPointMakeWithDictionaryRepresentation(dictRef,&point);
    [path moveToPoint:point];
    
    while (index < codeObj.corners.count) {
        dictRef = (__bridge CFDictionaryRef)(codeObj.corners[index++]);
        CGPointMakeWithDictionaryRepresentation(dictRef, &point);
        [path addLineToPoint:point];
    }
    
    //关闭路径
    [path closePath];
    
    //3.将贝塞尔曲线赋值给CAShapeLayer
    shapeLayer.path = path.CGPath;
    [self.drawLayer addSublayer:shapeLayer];
    
}
//移除二维码边框
- (void)removeQRCodeFrame
{
    
    if (self.drawLayer.sublayers.count == 0) {
        return;
    }
    
    for (CALayer *layer in self.drawLayer.sublayers) {
        [layer removeFromSuperlayer];
    }

}

- (void)addTimer
{
    _timer = [NSTimer scheduledTimerWithTimeInterval:0.008 target:self selector:@selector(timerMethod) userInfo:nil repeats:YES];
}

//控制扫描线上下滚动
- (void)timerMethod
{
    if (upOrDown == NO) {
        num ++;
        self.scannerLine.frame = CGRectMake(CGRectGetMinX(self.scannerImageView.frame)+5, CGRectGetMinY(self.scannerImageView.frame)+5+num, CGRectGetWidth(self.scannerImageView.frame)-10, 3);
        if (num == (int)(CGRectGetHeight(self.scannerImageView.frame)-10)) {
            upOrDown = YES;
        }
    }
    else
    {
        num --;
        self.scannerLine.frame = CGRectMake(CGRectGetMinX(self.scannerImageView.frame)+5, CGRectGetMinY(self.scannerImageView.frame)+5+num, CGRectGetWidth(self.scannerImageView.frame)-10, 3);
        if (num == 0) {
            upOrDown = NO;
        }
    }
}

- (void)viewWillDisappear:(BOOL)animated
{
    [super viewWillDisappear:animated];
}

- (void)dealloc
{
    //视图退出，关闭扫描
    [self.captureSeesion stopRunning];
    //关闭定时器
    [_timer setFireDate:[NSDate distantFuture]];
    
}

@end
