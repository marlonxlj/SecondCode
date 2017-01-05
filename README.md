##二维码扫描
####前言：
最近的项目中使用到了二维码，二维码这个模块功能也完成；觉得还是有必要总结一下用来做记录。好长时间没有写二维码了都忘记在差不多了，重新拾起来还是挻快的。

####二维码使用场景：
生活中有很多的地方都在使用，比如把它分享给朋友，通过扫描来关注平台。它的功能有生成二维码、扫描二维码、从相册中读取二维码。主要从这几个方面来讲二维码的使用，最后会封装一个方便快捷使用的库，供想快速集成的使用者。

###1.生成二维码
####![Alt Text](https://github.com/marlonxlj/SecondCode/blob/master/1.gif):

> #####1. 创建二维码滤镜--CIFilter
> #####1.1 恢复滤镜的默认属性
> #####1.2 设置滤镜的输入数据
> - 将传入的字符串转换成NSData数据
> - 通过KVC来设置输入的内容`inputMessage`

> #####1.3 二维码容错率
> - inputCorrectionLevel 是一个单字母（@"L", @"M", @"Q", @"H" 中的一个），表示不同级别的容错率，默认为 @"M".
 > - QR码有容错能力，QR码图形如果有破损，仍然可以被机器读取内容，最高可以到7%~30%面积破损仍可被读取,相对而言，容错率愈高，QR码图形面积愈大。所以一般折衷使用15%容错能力。
> - L水平 7%的字码可被修正.
> - M水平 15%的字码可被修正
> - Q水平 25%的字码可被修正
> - H水平 30%的字码可被修正
> - ``代码: [filter setValue:@"H" forKey:@"inputCorrectionLevel"];``

> #####1.4 获取滤镜输出的图片
> #####1.5 将CIImage转换成UIImage
> #####1.6 通过位图创建高清图片
> #####1.7 图片合成

####运行报错:

```
Jan  3 16:35:22  二维码扫描demo[4032] <Error>: CGContextSetInterpolationQuality: invalid context 0x0. If you want to see the backtrace, please set CG_CONTEXT_SHOW_BACKTRACE environmental variable.
Jan  3 16:35:22  二维码扫描demo[4032] <Error>: CGContextScaleCTM: invalid context 0x0. If you want to see the backtrace, please set CG_CONTEXT_SHOW_BACKTRACE environmental variable.
Jan  3 16:35:22  二维码扫描demo[4032] <Error>: CGContextDrawImage: invalid context 0x0. If you want to see the backtrace, please set CG_CONTEXT_SHOW_BACKTRACE environmental variable.
Jan  3 16:35:22  二维码扫描demo[4032] <Error>: CGBitmapContextCreateImage: invalid context 0x0. If you want to see the backtrace, please set CG_CONTEXT_SHOW_BACKTRACE environmental variable.
Jan  3 16:35:22  二维码扫描demo[4032] <Error>: CGContextSaveGState: invalid context 0x0. If you want to see the backtrace, please set CG_CONTEXT_SHOW_BACKTRACE environmental variable.
Jan  3 16:35:22  二维码扫描demo[4032] <Error>: CGContextSetBlendMode: invalid context 0x0. If you want to see the backtrace, please set CG_CONTEXT_SHOW_BACKTRACE environmental variable.
Jan  3 16:35:22  二维码扫描demo[4032] <Error>: CGContextSetAlpha: invalid context 0x0. If you want to see the backtrace, please set CG_CONTEXT_SHOW_BACKTRACE environmental variable.
Jan  3 16:35:22  二维码扫描demo[4032] <Error>: CGContextTranslateCTM: invalid context 0x0. If you want to see the backtrace, please set CG_CONTEXT_SHOW_BACKTRACE environmental variable.
Jan  3 16:35:22  二维码扫描demo[4032] <Error>: CGContextScaleCTM: invalid context 0x0. If you want to see the backtrace, please set CG_CONTEXT_SHOW_BACKTRACE environmental variable.
Jan  3 16:35:22  二维码扫描demo[4032] <Error>: CGContextDrawImage: invalid context 0x0. If you want to see the backtrace, please set CG_CONTEXT_SHOW_BACKTRACE environmental variable.
Jan  3 16:35:22  二维码扫描demo[4032] <Error>: CGContextRestoreGState: invalid context 0x0. If you want to see the backtrace, please set CG_CONTEXT_SHOW_BACKTRACE environmental variable.

```
####找到原因：
#####通过打断点的方式查到创建filter的时候，filter为空；是因为我在创建的时候使用了宏定义;
#####错误的方式：
```
//1.创建滤镜
    CIFilter *filter = [CIFilter filterWithName: CIFILETERNAME];
```
####正确的方式:
#####备注：filter的名字只能是这个不能是别的：`CIQRCodeGenerator `
```
//1.创建滤镜
    CIFilter *filter = [CIFilter filterWithName: @"CIQRCodeGenerator"];
    
```
 
###2.扫描二维码
####![Alt Text](https://github.com/marlonxlj/SecondCode/blob/master/2.gif):

> 1. 创建上下文
> 2. 创建一个探测器
> 3. 直接开始识别图片，获取图片特征
> `` CIImage *imageCI = [[CIImage alloc] initWithImage:self.sourceImage];
    NSArray <CIFeature *> *features = [detector featuresInImage:imageCI];``
    
> 

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

> ######4. 读取特征

###3.生成二维码
####![Alt Text](https://github.com/marlonxlj/SecondCode/blob/master/3.gif):

> 1. 判断输入输出能否加入当前会话

 > - 添加一个视频预览图层
> 2. 设置输出数据媒体类型
> 3. 添加预栏图层，放在最底层
> 4. 添加绘图图层到预栏图层上面
> 5. 开始扫描

> #####代理
> ```
> #pragma mark - AVCaptureMetadataOutputObjectsDelegate代理
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

> ```

####封装的还没有做好，做好了之后再更新。
####🐼🐶🐶如果对你有帮助，或觉得可以。请右上角star一下，这是对我一种鼓励，让我知道我写的东西有人认可，我才会后续不断的进行完善。

###有任何问题或建议请及时issues me，以便我能更快的进行更新修复。

####Email: marlonxlj@163.com

