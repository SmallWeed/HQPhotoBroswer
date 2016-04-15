//
//  HQPhotoBroswer.m
//
//  Created by HQ on 15/12/14.
//  Copyright © 2015年 CloudSpider Inc. All rights reserved.
//

#import "HQPhotoBroswer.h"

// 宽度
#define Width                             [UIScreen mainScreen].bounds.size.width
// 高度
#define Height                            [UIScreen mainScreen].bounds.size.height

// 颜色
#define HexRGBA(rgbValue,a) [UIColor colorWithRed:((float)((rgbValue & 0xFF0000) >> 16))/255.0 green:((float)((rgbValue & 0xFF00) >> 8))/255.0 blue:((float)(rgbValue & 0xFF))/255.0 alpha:(a)]

@interface HQPhotoBroswer ()<UIScrollViewDelegate>
@property (nonatomic,strong) UIScrollView *scrollView;          /**< 总的ScrollView */
@property (nonatomic,strong) UILabel      *numberLabel;         /**< 当前照片的数字 */
@property (nonatomic,strong) UILabel      *lineView;            /**< 线 */
@property (nonatomic,strong) UILabel      *sumLabel;            /**< 总的照片数 */
@end

@implementation HQPhotoBroswer

- (void)viewDidLoad {
    [super viewDidLoad];
    
    [self initComponent];
    
    [self initScorllView];
    
    [self initTitle];
}

- (void)initTitle
{
    self.numberLabel.text = [NSString stringWithFormat:@"%d/%lu",((int)self.scrollView.contentOffset.x / (int)self.view.frame.size.width)+1,(unsigned long)self.photos.count];
}

- (void)initScorllView
{
    self.scrollView.contentSize = CGSizeMake(Width * self.photos.count, 0);

    if (self.scrollView.subviews.count) {
        for (UIView *img in self.scrollView.subviews) {
            [img removeFromSuperview];
        }
    }
    
    for (int i = 0; i < self.photos.count; i ++) {
        
        if (self.type == 0) {
            
            UIImageView *imageView = [[UIImageView alloc] init];
            UIImage     *image     = self.photos[i];
            image                  = [self imageCompressForWidth:image targetWidth:Width];
            imageView.frame        = CGRectMake(i * Width, 0, image.size.width, image.size.height);
            imageView.center       = CGPointMake(i * Width + Width / 2.0, Height / 2.0 - 64);
            imageView.image        = image;
            [self.scrollView addSubview:imageView];
        }
        else{
            UIImageView *imageView = [[UIImageView alloc]init ];
            
            [[SDWebImageManager sharedManager] downloadImageWithURL:[NSURL URLWithString:self.photos[i]] options:SDWebImageRetryFailed|SDWebImageContinueInBackground progress:nil completed:^(UIImage *image, NSError *error, SDImageCacheType cacheType, BOOL finished, NSURL *imageURL) {
                
                if (!error) {
                    UIImage *Image = [Tool imageCompressForWidth:image targetWidth:Width];
                    imageView.image        = Image;
                    [self.scrollView addSubview:imageView];
                    imageView.frame        = CGRectMake(i * Width, 0, image.size.width, image.size.height);
                    imageView.center       = CGPointMake(i * Width + Width / 2.0, Height / 2.0 - 64);
                }
            }];
        }
    }
}

- (void)initComponent{
    
    [self.view setBackgroundColor:[UIColor colorWithRed:0.0 / 255.0 green:0.0 / 255.0 blue:0.0 / 255.0 alpha:1.0]];
    
    // 页数
    self.numberLabel               = [[UILabel alloc]initWithFrame:CGRectMake(0, 0, 50, 30)];
    self.numberLabel.textAlignment = 1;
    self.numberLabel.textColor     = [UIColor whiteColor];
    self.numberLabel.font          = [UIFont systemFontOfSize:20];
    self.navigationItem.titleView = self.numberLabel;
    
    self.scrollView                                = [[UIScrollView alloc]initWithFrame:CGRectMake(0, 0, Width,Height)];
    self.scrollView.delegate                       = self;
    self.scrollView.bounces                        = NO;
    self.scrollView.pagingEnabled                  = YES;
    self.scrollView.alwaysBounceHorizontal         = NO;
    self.scrollView.alwaysBounceVertical           = NO;
    self.scrollView.showsHorizontalScrollIndicator = NO;
    self.scrollView.showsVerticalScrollIndicator   = NO;
    [self.view addSubview:self.scrollView];
    
    [self initScorllView];
    
    [self.scrollView setContentOffset:CGPointMake(_currentPage * Width, 0)];
    
    if ([self.delegate respondsToSelector:@selector(deletePhoto:)]){
        [self setDeteBtn];
    }
}

- (void)setDeteBtn{
    
    for (int i = 0; i < self.photos.count; i ++) {
        UIView *blackView = [[UIView alloc]initWithFrame:CGRectMake(0 + i* Width, Height - 64 - 50, Width, 50)];
        blackView.backgroundColor = HexRGBA(0x161616, 0.7);
        [self.view addSubview:blackView];
        
        UIButton * deleteButton = [[UIButton alloc]init];
        deleteButton.frame = CGRectMake(i * Width + Width - 80, Height - 64 - 50,  50, 50);
        [deleteButton setBackgroundImage:[UIImage imageNamed:@"image_preview_deleticon_press"] forState:UIControlStateNormal];
        deleteButton.tag = i;
        [deleteButton addTarget:self action:@selector(deleteButton:) forControlEvents:UIControlEventTouchUpInside];
        [self.view addSubview:deleteButton];
    }
}

//删除方法
- (void)deleteButton:(UIButton *)button{
    
    if (((int)self.scrollView.contentOffset.x / (int)self.view.frame.size.width) == self.photos.count - 1) {
        _currentPage = self.photos.count - 2;
    }
    
    [self.photos removeObjectAtIndex:((int)self.scrollView.contentOffset.x / (int)self.view.frame.size.width)];
    
    [self.delegate deletePhoto:self.photos];
    
    if (self.photos.count == 0) {
        
        [self.navigationController popViewControllerAnimated:YES];
    }
    
    [self.scrollView setContentOffset:CGPointMake(_currentPage * Width, 0)];
    
    [self initScorllView];
    [self initTitle];
}

/**
 *  图片按宽度缩放
 */
- (UIImage *)imageCompressForWidth:(UIImage *)sourceImage targetWidth:(CGFloat)defineWidth{
    UIImage *newImage = nil;
    CGSize imageSize = sourceImage.size;
    CGFloat width = imageSize.width;
    CGFloat height = imageSize.height;
    CGFloat targetWidth = defineWidth;
    CGFloat targetHeight = height / (width / targetWidth);
    CGSize size = CGSizeMake(targetWidth, targetHeight);
    CGFloat scaleFactor = 0.0;
    CGFloat scaledWidth = targetWidth;
    CGFloat scaledHeight = targetHeight;
    CGPoint thumbnailPoint = CGPointMake(0.0, 0.0);
    if(CGSizeEqualToSize(imageSize, size) == NO){
        CGFloat widthFactor = targetWidth / width;
        CGFloat heightFactor = targetHeight / height;
        if(widthFactor > heightFactor){
            scaleFactor = widthFactor;
        }
        else{
            scaleFactor = heightFactor;
        }
        scaledWidth = width * scaleFactor;
        scaledHeight = height * scaleFactor;
        if(widthFactor > heightFactor){
            thumbnailPoint.y = (targetHeight - scaledHeight) * 0.5;
        }else if(widthFactor < heightFactor){
            thumbnailPoint.x = (targetWidth - scaledWidth) * 0.5;
        }
    }
    UIGraphicsBeginImageContext(size);
    CGRect thumbnailRect = CGRectZero;
    thumbnailRect.origin = thumbnailPoint;
    thumbnailRect.size.width = scaledWidth;
    thumbnailRect.size.height = scaledHeight;
    
    [sourceImage drawInRect:thumbnailRect];
    
    newImage = UIGraphicsGetImageFromCurrentImageContext();
    if(newImage == nil){
        NSLog(@"scale image fail");
    }
    
    UIGraphicsEndImageContext();
    return newImage;
}

- (void)scrollViewDidScroll:(UIScrollView *)scrollView
{
    _numberLabel.text = [NSString stringWithFormat:@"%d/%lu",((int)self.scrollView.contentOffset.x / (int)self.view.frame.size.width)+1,(unsigned long)self.photos.count];
}

@end
