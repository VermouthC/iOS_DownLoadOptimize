//
//  ViewController.m
//  iOS_DownLoadOptimize
//
//  Created by MasterChen on 16/11/25.
//  Copyright © 2016年 MasterChen. All rights reserved.
//

#import "ViewController.h"

@interface ViewController ()<NSURLSessionDownloadDelegate>
/**下载任务*/
@property(nonatomic,strong)NSURLSessionDownloadTask *task;
/** UIActivityIndicatorView */
@property(nonatomic,strong)UIActivityIndicatorView *loading;
/**回复标识（保存当前进度）*/
@property(nonatomic,strong)NSData *resumeData;
@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    //初始化 UIActivityIndicatorView
    self.loading = [[UIActivityIndicatorView alloc] initWithFrame:CGRectMake([UIScreen mainScreen].bounds.size.width/2, 20, 10, 10)];
    self.loading.color = [UIColor redColor];
    [self.view addSubview:self.loading];
}

#pragma mark -开始下载
- (IBAction)clickStartBtn:(UIButton *)sender {
    //开始UIActivityIndicatorView动画
    [self.loading startAnimating];
    
    NSURL *url = [NSURL URLWithString:@"http://192.168.0.215/jereh.zip"];
    NSURLSessionConfiguration *configuation = [NSURLSessionConfiguration defaultSessionConfiguration];
    NSURLSession *session = [NSURLSession sessionWithConfiguration:configuation delegate:self delegateQueue:[NSOperationQueue mainQueue]];
    //创建下载任务
    
    //根据下载标识选择下载任务
    if (self.resumeData == nil) {
        self.task = [session downloadTaskWithURL:url];
    }else{
        //通过保存的进度信息初始化下载任务
        self.task = [session downloadTaskWithResumeData:self.resumeData];
    }
    [self.task resume];
}

- (IBAction)clickPauseBtn:(UIButton *)sender {
    [self.loading stopAnimating];
    /*
     块内为什么不可以修改块外面的属性？
     block是属性  当被强引用的时候，block的生命周期不确定，声明在块外的属性（非static 非__block 非全局）在块内修改，被修改的属性的生命周期可能已结束。
     解决方式：
     1.__block 声明
     __block NSInteger a = 10 改变属性生命周期
     2. static
     3. 全局
     */
    //创建一个对当前对象的弱引用 解决循环引用
    __weak typeof(self) cell = self;
    //取消下载，并保存当前进度
    [self.task cancelByProducingResumeData:^(NSData * _Nullable resumeData) {
        cell.resumeData = resumeData;
    }];
}

#pragma mark -NSURLSessionDownloadDelegate 代理方法
#pragma mark * 已经下载成功后调用
- (void)URLSession:(NSURLSession *)session downloadTask:(NSURLSessionDownloadTask *)downloadTask
didFinishDownloadingToURL:(NSURL *)location{
    //将虚拟的存储位置转存到沙盒
    NSString *path = [[NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES) firstObject] stringByAppendingPathComponent:@"my.zip"];
    NSLog(@"%@",path);
    //文件移动
    NSFileManager *manager = [NSFileManager defaultManager];
    //获取本地URL路径
    NSURL *url = [NSURL fileURLWithPath:path];
    //转存
    BOOL isMove = [manager moveItemAtURL:location toURL:url error:nil];
    if (isMove) {
        NSLog(@"Move  OK");
    }else{
        NSLog(@"Move  Not");
    }
}

#pragma mark *
- (void)URLSession:(NSURLSession *)session downloadTask:(NSURLSessionDownloadTask *)downloadTask
      didWriteData:(int64_t)bytesWritten
 totalBytesWritten:(int64_t)totalBytesWritten
totalBytesExpectedToWrite:(int64_t)totalBytesExpectedToWrite{
    //打印线程
    NSLog(@"%@",[NSThread currentThread]);
    //计算下载进度
    CGFloat process = totalBytesWritten*1.0/totalBytesExpectedToWrite;
    //根据加载进度判断UIActivityIndicatorView 是否继续
    if (process == 1.00) {
        [self.loading stopAnimating];
    }
    //打印进度
    NSLog(@"%g",process);
}


- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end
