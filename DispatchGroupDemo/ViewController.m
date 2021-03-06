//
//  ViewController.m
//  DispatchGroupDemo
//
//  Created by 苑心刚 on 2017/7/5.
//  Copyright © 2017年 YXG. All rights reserved.
//

#import "ViewController.h"

@interface ViewController ()

@property (weak, nonatomic) IBOutlet UIImageView *combinedImage;
@property (strong, nonatomic) NSMutableArray *images;
@property (strong, nonatomic) UIActivityIndicatorView *loading;

@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view, typically from a nib.
    [self initDatas];
    [self initViews];
    [self requestImages];
}

#pragma mark - Init
- (void)initDatas {
    self.images = @[].mutableCopy;
}

- (void)initViews {
    self.loading = [[UIActivityIndicatorView alloc] initWithFrame:self.view.frame];
    self.loading.activityIndicatorViewStyle = UIActivityIndicatorViewStyleGray;
    [self.view addSubview:self.loading];
}

#pragma mark - loading
- (void)showLoading {
    [self.loading startAnimating];
}

- (void)hideLoading {
    [self.loading stopAnimating];
}

#pragma mark - Request
- (void)requestImages {
    
    [self showLoading];
    dispatch_group_t group = dispatch_group_create();
    // group one
    dispatch_group_enter(group);
    dispatch_async(dispatch_get_global_queue(0, 0), ^{
        NSLog(@"group one start");
        NSURLSessionTask *task1 = [[NSURLSession sharedSession] dataTaskWithURL:[NSURL URLWithString:@"http://img05.tooopen.com/images/20150202/sy_80219211654.jpg"] completionHandler:^(NSData * _Nullable data, NSURLResponse * _Nullable response, NSError * _Nullable error) {
            UIImage *image = [UIImage imageWithData:data];
            if (image) {
                [self.images addObject:image];
            }
            NSLog(@"group one finish");
            dispatch_group_leave(group);
        }];
        [task1 resume];
    });
    
    // group two
    dispatch_group_enter(group);
    dispatch_async(dispatch_get_global_queue(0, 0), ^{
        NSLog(@"group two start");
        NSURLSessionTask *task2 = [[NSURLSession sharedSession] dataTaskWithURL:[NSURL URLWithString:@"http://img04.tooopen.com/images/20130701/tooopen_10055061.jpg"] completionHandler:^(NSData * _Nullable data, NSURLResponse * _Nullable response, NSError * _Nullable error) {
            UIImage *image = [UIImage imageWithData:data];
            if (image) {
                [self.images addObject:image];
            }
            NSLog(@"group two finish");
            dispatch_group_leave(group);
        }];
        [task2 resume];
    });
    
    //group last
    dispatch_group_enter(group);
    dispatch_async(dispatch_get_global_queue(0, 0), ^{
        NSLog(@"group last start");
        NSURLSessionTask *task3 = [[NSURLSession sharedSession]dataTaskWithURL:[NSURL URLWithString:@"http://img05.tooopen.com/images/20150202/sy_80219211654.jpg"] completionHandler:^(NSData * _Nullable data, NSURLResponse * _Nullable response, NSError * _Nullable error) {
            UIImage *image = [UIImage imageWithData:data];
            if (image) {
                [self.images addObject:image];
            }
            NSLog(@"group last finish");
            dispatch_group_leave(group);
        }];
        [task3 resume];
    });
    
    // group notify
    dispatch_group_notify(group, dispatch_get_global_queue(0, 0), ^{
        NSLog(@"group finished");
        if (self.images.count >= 3) {
            UIImage *image1 = self.images[0];
            UIImage *image2 = self.images[1];
            UIImage *image3 = self.images[2];
            UIImage *combineImage = [self combineWithTopImage:image1 bottomImage:image2 lastImage:image3];
            dispatch_async(dispatch_get_main_queue(), ^{
                self.combinedImage.image = combineImage;
                [self hideLoading];
            });
        }
    });
}

#pragma mark - Combine Images
- (UIImage *)combineWithTopImage:(UIImage *)topImage bottomImage:(UIImage *)bottomImage lastImage:(UIImage *)lastImage{
    CGFloat width = topImage.size.width ;
    CGFloat height = topImage.size.height * self.images.count;
    CGSize offScreenSize = CGSizeMake(width, height);
    
    UIGraphicsBeginImageContext(offScreenSize);
    
    CGRect rect = CGRectMake(0, 0, width, height / self.images.count);
    [topImage drawInRect:rect];
    
    rect.origin.y += height / 3;
    [bottomImage drawInRect:rect];
    
    rect.origin.y += height / 3;
    [lastImage drawInRect:rect];
    
    UIImage* imagez = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    
    return imagez;
}

@end
