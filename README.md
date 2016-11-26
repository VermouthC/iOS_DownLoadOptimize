# iOS_DownLoadOptimize
　　Demo主要iOS下载网络资源的优化，在开始学习的方法中，下载的数据放在内存中，
内存负载过高。  
　　iOS优化下载主要是实现了`NSURLSessionDownloadDelegate`代理里面的方法，解决
内存问题。  
　　下载任务准备（标配,你懂的）  
```
NSURL *url = [NSURL URLWithString:@"http://192.168.0.215/jereh.zip"];
NSURLSessionConfiguration *configuation = [NSURLSessionConfiguration defaultSessionConfiguration];
NSURLSession *session = [NSURLSession sessionWithConfiguration:configuation delegate:self delegateQueue:[NSOperationQueue mainQueue]];
```
然后通过`self.task = [session downloadTaskWithURL:url];`开启任务  
注：`/**下载任务*/
@property(nonatomic,strong)NSURLSessionDownloadTask *task;`  
　　1.`NSURLSessionDownloadDelegate`代理方法  
　　`- (void)URLSession:(NSURLSession *)session downloadTask:(NSURLSessionDownloadTask *)downloadTask
      didWriteData:(int64_t)bytesWritten
 totalBytesWritten:(int64_t)totalBytesWritten
totalBytesExpectedToWrite:(int64_t)totalBytesExpectedToWrite`  
　　这个方法主要是在在在任务过程中，不断调用，文件的上传和下载主要是以二进制文件的
格式，所以在方法里面可以检测实时下载的字节数数（NSLog一下，你懂的！）  
　　参数一：`(int64_t)bytesWritten` 本次下载的字节数  
　　参数二：`(int64_t)totalBytesWritten`截止到本次已下载的字节数  
　　参数三：`(int64_t)totalBytesExpectedToWrite`文件总大小的字节数  
　　这样就可以通过这些参数计算进度，如果你有漂亮的进度条，设置一下，你懂的！  
　　代码如下：
```
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
```
注：`/** UIActivityIndicatorView */
@property(nonatomic,strong)UIActivityIndicatorView *loading;`  
　　2.`NSURLSessionDownloadDelegate`代理方法  
　　`- (void)URLSession:(NSURLSession *)session downloadTask:(NSURLSessionDownloadTask *)downloadTask
didFinishDownloadingToURL:(NSURL *)location`  
　　这个代理方法是在下载成功后调用，他并不是经下载的文件直接存储到目标路径，
而是一个虚拟存储位置，该方法是将存在虚拟位置的下载文件存到沙盒中
```
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
```
注意url 是获取本地的url，`path`是获取的沙盒路径。  
　　3.停止下载，前面讲到使用该代理可以控制下载（想停就停）  
　　声明一个标志`/**回复标识（保存当前下载进度）*/
@property(nonatomic,strong)NSData *resumeData;`  
　　那么在开启任务的时候就需要判断一下，标识是否为nil，不为nil说明之前有未下载的
任务，可继续下载。
```
//根据下载标识选择下载任务
    if (self.resumeData == nil) {
        self.task = [session downloadTaskWithURL:url];
    }else{
        //通过保存的进度信息初始化下载任务
        self.task = [session downloadTaskWithResumeData:self.resumeData];
    }
    [self.task resume];
```
　　那么之后就可以通过一个方法暂停任务
```
//创建一个对当前对象的弱引用 解决循环引用
    __weak typeof(self) cell = self;
    //取消下载，并保存当前进度
    [self.task cancelByProducingResumeData:^(NSData * _Nullable resumeData) {
        cell.resumeData = resumeData;
    }];
```
　　这就可以控制下载了！以上代理方法介绍是我自己的理解，具体可以参考Apple官方文档，你懂
的。
************************
　　网络监测，主要是判断在下载任务的时候，需要判断网络的类型：2g/3g/4g、WIFI、
未连接网络，给出提示，如果不是WIFI，你懂的！  
　　首先`#import "Reachability.h"`，之后创建`/** 网络监测类*/
@property(nonatomic,strong)Reachability *reach;`  
　　初始化网络加载类的属性使用懒加载，提高效率。  
```
//懒加载
-(Reachability *)reach{
    if (_reach  == nil) {
        _reach = [Reachability reachabilityForInternetConnection];
    }
    return _reach;
}
```
　　实现一个监测方法
```
#pragma mark - 网络监测
-(void)monitorNet{
    //初始化一个网络监测类
    if (self.reach.currentReachabilityStatus == NotReachable) {
        //此时没有网络
        NSLog(@"没有网络");
    }else if(self.reach.currentReachabilityStatus == ReachableViaWiFi){
        NSLog(@"WIFI链接");
    }else{
        NSLog(@"您正在使用2g/3g/4g");
    }
}
```
那么在开启下载任务前需要调用该方法`//首先监测网络
    [self monitorNet];`  
　　实时监测，主要通过注册通知来实现
在viewDidLoad中注册通知  
```
//注册通知，进行网络监测
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(monitorNet) name:kReachabilityChangedNotification object:nil];
    [self.reach startNotifier];
```
注：参数`name:kReachabilityChangedNotification`是在网络监测类中声明定义的  
`NSString *const kReachabilityChangedNotification`
最后移除通知  
```
//移除通知
-(void)dealloc{
    [[NSNotificationCenter defaultCenter] removeObserver:self name:kReachabilityChangedNotification object:nil];
}
```
实现这个网络监测需要加入一个framework，
在设置general-->Linked Framework and libraries--> + -->输入SystemConfiguration.framework
添加即可。
*********************
复习知识点  
```
#pragma mark - 切换storyboard
- (IBAction)enterAction:(UIButton *)sender {
    //实例化Storyboard
    UIStoryboard *storyboard = [UIStoryboard storyboardWithName:@"ImageStoryboard" bundle:nil];
    //取出storyboard的控制器
    UIViewController *vc  = [storyboard instantiateInitialViewController];
    //获取窗口实例(单例)
   UIWindow *win =  [UIApplication sharedApplication].keyWindow;
    win.rootViewController = vc;
}
```

