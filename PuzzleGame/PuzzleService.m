//
//  PuzzleService.m
//  PuzzleGame
//
//  Created by Karen Ghandilyan on 5/17/17.
//  Copyright © 2017 Wagawin. All rights reserved.
//

#import "PuzzleService.h"
#import "PuzzleGameView.h"
#define IMAGE_URL_STRING @"https://s3-eu-west-1.amazonaws.com/wagawin-ad-platform/media/testmode/banner-landscape.jpg"

@interface PuzzleService()

@property (nonatomic, strong) UIView *mainView;
@property (nonatomic, strong) PuzzleGameView *gameView;

@end

@implementation PuzzleService

- (instancetype)initForView:(UIView *)view {
    self = [super init];
    if (self) {
        self.mainView = view;
        [self startProcessing];
    }
    return self;
}

- (void)startProcessing {
    NSURL *bannerImageUrl = [NSURL URLWithString:IMAGE_URL_STRING];
    [self downloadBannerImageForURL:bannerImageUrl withCompletion:^(UIImage *image) {
        self.gameView = [[PuzzleGameView alloc] initForView:self.mainView puzzleImage:image];
        [self.mainView addSubview:self.gameView];
    }];
}

// 1st Step - Download Image
- (void)downloadBannerImageForURL:(NSURL *)imageUrl withCompletion:(void (^)(UIImage *))completion{
    NSURLSession *urlSession = [NSURLSession sharedSession];
    NSURLSessionDataTask *dataTask = [urlSession dataTaskWithURL:imageUrl completionHandler:^(NSData * _Nullable data, NSURLResponse * _Nullable response, NSError * _Nullable error) {
        dispatch_async(dispatch_get_main_queue(), ^{
            if (data != nil) {
                UIImage *responseImage = [UIImage imageWithData:data];
                completion(responseImage);
            } else {
                completion(nil);
            }
        });
    }];
    [dataTask resume];
}

@end
