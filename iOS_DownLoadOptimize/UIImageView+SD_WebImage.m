//
//  UIImageView+SD_WebImage.m
//  iOS_DownLoadOptimize
//
//  Created by MasterChen on 16/11/25.
//  Copyright © 2016年 MasterChen. All rights reserved.
//

#import "UIImageView+SD_WebImage.h"

@implementation UIImageView (SD_WebImage)
-(void)setWebImage:(NSString *)imageUrl{
    dispatch_queue_t globel = dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0);
    dispatch_async(globel, ^{
        NSData *data = [NSData dataWithContentsOfURL:[NSURL URLWithString:imageUrl]];
        UIImage *image = [UIImage imageWithData:data];
        //回到主线程刷新界面
        dispatch_sync(dispatch_get_main_queue(), ^{
            self.image = image;
        });
    });
}
@end
