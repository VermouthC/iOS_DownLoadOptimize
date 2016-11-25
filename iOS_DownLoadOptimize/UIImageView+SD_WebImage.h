//
//  UIImageView+SD_WebImage.h
//  iOS_DownLoadOptimize
//
//  Created by MasterChen on 16/11/25.
//  Copyright © 2016年 MasterChen. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface UIImageView (SD_WebImage)
/*
   复习通过多线程来加载网络图片。。 不能过多依赖第三方的封装 
   尽量通过基础内容进行封装
   该例子只是增加了分类完成图片的加载
 */
-(void)setWebImage:(NSString *)imageUrl;
@end
