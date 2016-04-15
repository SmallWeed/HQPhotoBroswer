//
//  HQPhotoBroswer.h
//
//  Created by HQ on 15/12/14.
//  Copyright © 2015年 CloudSpider Inc. All rights reserved.
//

#import <UIKit/UIKit.h>

@protocol HQPhotoBroswerDelegate <NSObject>
@optional
- (void)deletePhoto:(NSMutableArray *)array;
@end

@interface HQPhotoBroswer : UIViewController
@property (nonatomic,weak) id <HQPhotoBroswerDelegate> delegate;

/**
 *  图片数组
 */
@property (nonatomic,strong) NSMutableArray *photos;

/**
 *  图片数组数据类型
 */
@property (nonatomic,assign) NSInteger type;                 /**< 1:表示数组里为image图片 0:表示数组里是图片URL */

/**
 *  当前页 从0开始
 */
@property (nonatomic,assign) NSInteger currentPage;
@end
