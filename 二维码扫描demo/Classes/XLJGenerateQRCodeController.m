//
//  XLJGenerateQRCodeController.m
//  二维码扫描demo
//
//  Created by m on 2017/1/3.
//  Copyright © 2017年 XLJ. All rights reserved.
//

#import "XLJGenerateQRCodeController.h"
@interface XLJGenerateQRCodeController ()

@property (nonatomic, strong) UIImageView *imageView;

@end

@implementation XLJGenerateQRCodeController

- (UIImageView *)imageView
{
    if (!_imageView) {
        _imageView = [[UIImageView alloc] initWithFrame:CGRectMake((self.view.frame.size.width-200)/2, (self.view.frame.size.height-200)/2, 200, 200)];

        [self.view addSubview:_imageView];
    }
    
    return _imageView;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    self.view.backgroundColor = [UIColor whiteColor];
    self.title = @"生成二维码";
    //创建二维码
    [self creatQRCodeImage];
    
}

- (void)creatQRCodeImage
{
    //1.创建滤镜
    CIFilter *filter = [CIFilter filterWithName: @"CIQRCodeGenerator"];
    
    //2.还原滤镜的默认设置
    [filter setDefaults];
    
    //3.设置滤镜输入的内容
    //将传进来的字符串转换成NSData数据
    NSData *stringData = [self.inputString dataUsingEncoding:NSUTF8StringEncoding];
    
    [filter setValue:stringData forKey:@"inputMessage"];
    
    //4.设置二维码的容错率
    //纠错率等级: L--7%, M--15%, Q--25%, H--30%
    [filter setValue:@"H" forKey:@"inputCorrectionLevel"];
    
    //5.从滤镜中获取生成的二维码
    //5.1获取二维码图片
    CIImage *image = [filter outputImage];
    
    //将图片转换成高清图
    UIImage *newImage = [self creatNormalHDImageWithCIImage:image withSize:400];
    
    //添加图片到二维码--(图片合并)
//    newImage = [self creatSyntheticImage:newImage iconImage:[UIImage imageNamed:self.imageName]];
    newImage = [self creatSyntheticImage:newImage iconImage:[UIImage imageNamed:self.imageName] red:168 green:168 blue:168];
    //显示在页面上
    self.imageView.image = newImage;
    
    //存沙盒方便识别的时候读取
    NSString *documentsDirectory = [NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES) objectAtIndex:0];
    NSData *imageData = UIImagePNGRepresentation(newImage);
    //路径拼接
    NSString *fullPath = [documentsDirectory stringByAppendingString:@"/imageName"];
    //保存到沙盒
   BOOL isOK =  [imageData writeToFile:fullPath atomically:NO];
    if (isOK) {
        NSLog(@"成功");
    }else{
        NSLog(@"失败");
    }
    
}
//将得到的文本数据转化为高清图片
//由于生成的二维码是CIImage类型，如果直接转换成UIImage，大小不好控制，图片模糊
//高清方法：CIImage->CGImageRef->UIImage
/**将图片转换成高清图*/
- (UIImage *)creatNormalHDImageWithCIImage:(CIImage *)CiImage withSize:(CGFloat)size
{
    
    CGRect extent = CGRectIntegral(CiImage.extent);
    CGFloat scale = MIN(size/CGRectGetWidth(extent), size/CGRectGetHeight(extent));
    
    //1.创建bitmap
    size_t width = CGRectGetWidth(extent) * scale;
    size_t height = CGRectGetHeight(extent) * scale;
    
    CGColorSpaceRef cs = CGColorSpaceCreateDeviceGray();
    CGContextRef bitmapRef = CGBitmapContextCreate(nil, width, height, 8, 0, cs,  (CGBitmapInfo)kCGImageAlphaNone);
    
    CIContext *context = [CIContext contextWithOptions:nil];
    CGImageRef bitMapImage = [context createCGImage:CiImage fromRect:extent];
    
    CGContextSetInterpolationQuality(bitmapRef, kCGInterpolationNone);
    
    CGContextScaleCTM(bitmapRef, scale, scale);
    CGContextDrawImage(bitmapRef, extent, bitMapImage);

    //2.保存bitmatp图片
    CGImageRef scaledImage = CGBitmapContextCreateImage(bitmapRef);
    
    return [UIImage imageWithCGImage:scaledImage];



}

/** 添加图片到二维码-- (图片合并)*/
- (UIImage *)creatSyntheticImage:(UIImage *)bigImage iconImage:(UIImage *)iconImage red:(CGFloat) red green:(CGFloat)green blue:(CGFloat)blue
{
    //1.开启图片上下文
    UIGraphicsBeginImageContext(bigImage.size);
    
    //2.绘制背景
    [bigImage drawInRect:CGRectMake(0, 0, bigImage.size.width, bigImage.size.height)];
    
    //可以修改默认的颜色
//    [bigImage drawInRect:CGRectMake(0, 0, bigImage.size.width, bigImage.size.height) blendMode:(kCGBlendModeColorDodge) alpha:0.5];
    
    //3.绘制图标中心小图标
    CGFloat iconW = 70;
    CGFloat iconH = iconW;
    CGFloat iconX = (bigImage.size.width - iconW)*0.5;
    CGFloat iconY = iconX;
    [iconImage drawInRect:CGRectMake(iconX, iconY, iconW, iconH)];
    /*
    int width = bigImage.size.width;
    int height = bigImage.size.height;
    
    //修改二维码的默认颜色
    //遍历像素，改变像素点的颜色
    int pixelNum = (int)(width * height);
    
    size_t bytesPrerRow = width * 4;
    uint32_t *rgbImageBuf = (uint32_t *)malloc(bytesPrerRow * height);
    uint32_t *pCurrPtr = rgbImageBuf;
    CGColorSpaceRef colorSpaceRef = CGColorSpaceCreateDeviceRGB();
    for (int i = 0; i < pixelNum; i++, pCurrPtr++) {
        if ((*pCurrPtr & 0xFFFFFF00) < 0x99999900) {
            uint8_t* ptr = (uint8_t*)pCurrPtr;
            ptr[3] = red*255;
            ptr[2] = green*255;
            ptr[1] = blue*255;
        }else{
            uint8_t* ptr = (uint8_t*)pCurrPtr;
            ptr[0] = 0;
        }
    }
    
    
    //取出图片
    CGDataProviderRef dataProvider = CGDataProviderCreateWithData(NULL, rgbImageBuf, bytesPrerRow * height, ProviderReleaseData);
    CGImageRef imageRef = CGImageCreate(width, height, 8, 32, bytesPrerRow, colorSpaceRef,
                                        kCGImageAlphaLast | kCGBitmapByteOrder32Little, dataProvider,
                                        NULL, true, kCGRenderingIntentDefault);
    CGDataProviderRelease(dataProvider);
    UIImage *resultImage = [UIImage imageWithCGImage:imageRef];
    
    CGColorSpaceRelease(colorSpaceRef);
*/
    
    //4.取出绘制好的图片
    UIImage *newImage = UIGraphicsGetImageFromCurrentImageContext();
    
    //5.关闭图片上下文
    UIGraphicsEndImageContext();
    
    return newImage;
    
}

void ProviderReleaseData (void *info, const void *data, size_t size){
    free((void*)data);
}

@end
