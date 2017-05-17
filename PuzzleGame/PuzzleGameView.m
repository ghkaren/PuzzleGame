//
//  PuzzleGameView.m
//  PuzzleGame
//
//  Created by Karen Ghandilyan on 5/17/17.
//  Copyright © 2017 Wagawin. All rights reserved.
//

#import "PuzzleGameView.h"
#import "Utils.h"
#import "UICountingLabel.h"

@interface PuzzleGameView()

@property (nonatomic, strong) UIImage *puzzleImage;
@property (nonatomic, strong) UIImageView *previewImageView;
@property (nonatomic, strong) UICountingLabel *countingLabel;
@property (nonatomic, strong) UIView *puzzleGameView;
@property (nonatomic, strong) UIView *counterView;

@property (nonatomic, strong) NSMutableArray *puzzleViewsArray;

@property (nonatomic) int numberOfRows;
@property (nonatomic) int numberOfColumns;

@property (nonatomic) NSTimeInterval previewCountdown;
@property (nonatomic) NSTimeInterval initialStartDelay;
@property (nonatomic) NSTimeInterval gameInterval;

@property (nonatomic) CGPoint processingItemCenter;

@property (nonatomic, strong) NSTimer *gameTimer;
@property (nonatomic) float seconds;

@end

@implementation PuzzleGameView

- (instancetype)initForView:(UIView *)view puzzleImage:(UIImage *)image {
    self = [super init];
    if (self) {
        self.numberOfRows = 3;
        self.numberOfColumns = 4;
        self.previewCountdown = 3.0;
        self.initialStartDelay = 2.0;
        self.gameInterval = 21.0;
        self.frame = [self frameSizeForRect:view.bounds bannerImageSize:image.size];
        
        [self addGradientBackground];
        
        self.puzzleImage = image;
        self.puzzleGameView = [[UIView alloc] initWithFrame:[self gameViewFrameForRect:self.bounds]];
        [self addSubview:self.puzzleGameView];
        [self startProcessing];
        
    }
    return self;
}

- (void)addGradientBackground {
    CAGradientLayer *gradient = [CAGradientLayer layer];
    gradient.frame = self.bounds;
    gradient.colors = @[(id)[UIColor colorWithWhite:220.0/255.0 alpha:1].CGColor, (id)[UIColor colorWithWhite:220.0/255.0 alpha:1].CGColor, (id)[UIColor colorWithWhite:253.0/255 alpha:1].CGColor];
    
    // create coordinates
    float x = 0.25; // 45 degre
    float a = pow(sinf((2*M_PI*((x+0.75)/2))),2);
    float b = pow(sinf((2*M_PI*((x+0.0)/2))),2);
    float c = pow(sinf((2*M_PI*((x+0.25)/2))),2);
    float d = pow(sinf((2*M_PI*((x+0.5)/2))),2);
    
    [gradient setStartPoint:CGPointMake(a, b)];
    [gradient setEndPoint:CGPointMake(c, d)];
    
    [self.layer addSublayer:gradient];
}

- (void)startProcessing {
    [self showPreviewImage];
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(self.previewCountdown * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
        [self removePreviewImage];
        [self generatePuzzleViewForPuzzleImage:self.puzzleImage];
        [self addCloseButton];
        [self addCounterView];
        dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(self.initialStartDelay * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
            self.gameTimer = [NSTimer scheduledTimerWithTimeInterval:0.1 target:self selector:@selector(animateCounter:) userInfo:nil repeats:YES];

        });
    });
}

- (void)animateCounter:(NSTimer *)timer {
    self.seconds += 0.1;
    
    CGRect counterRect = self.counterView.frame;
    
    float fullHeight = self.counterView.superview.bounds.size.height - 2;
    float newHeight = fullHeight - (self.seconds/self.gameInterval) * fullHeight;
    
    counterRect.origin.y = fullHeight - newHeight;
    counterRect.size.height = newHeight;
    
    dispatch_async(dispatch_get_main_queue(), ^{
        self.counterView.frame = counterRect;
    });
    
    if (self.seconds >= self.gameInterval) {
        [self.gameTimer invalidate];
    }
}

// preview processing
- (void)showPreviewImage {
    self.previewImageView = [[UIImageView alloc] initWithFrame:self.bounds];
    self.previewImageView.image = self.puzzleImage;
    [self addSubview:self.previewImageView];
    
    UICountingLabel* countingLabel = [[UICountingLabel alloc] initWithFrame:CGRectMake(0, 0, 100, 200)];
    countingLabel.center = self.previewImageView.center;
    [countingLabel countFrom:self.previewCountdown + 1 to:1 withDuration:self.previewCountdown];
    countingLabel.format = @"%d";
    countingLabel.textAlignment = NSTextAlignmentNatural;
    countingLabel.method = UILabelCountingMethodLinear;
    countingLabel.font = [UIFont systemFontOfSize:180];
    self.countingLabel = countingLabel;
    [self addSubview:countingLabel];
}

- (void)removePreviewImage {
    [self.previewImageView removeFromSuperview];
    self.previewImageView = nil;
    [self.countingLabel removeFromSuperview];
}


// image generating
- (NSArray *)puzzleImagesForImage:(UIImage *)image rows:(int)rows columns:(int)columns {
    NSMutableArray *puzzleImages = [[NSMutableArray alloc] init];
    
    CGSize imageSize = image.size;
    CGSize cropedSize = CGSizeMake(imageSize.width/columns, imageSize.height/rows);
    
    for(int i = 0; i < rows; ++i) {
        for (int j = 0; j < columns; ++j) {
            CGPoint cropPoint = CGPointMake(cropedSize.width * j, cropedSize.height * i);
            CGRect cropRect  = CGRectMake(cropPoint.x, cropPoint.y, cropedSize.width, cropedSize.height);
            CGImageRef imageRef = CGImageCreateWithImageInRect([image CGImage], cropRect);
            UIImage *newImage   = [UIImage imageWithCGImage:imageRef];
            CGImageRelease(imageRef);
            [puzzleImages addObject:newImage];
        }
    }
    
    return [Utils shuffleArray:puzzleImages];
}

- (void)addCloseButton {
    UIButton *closeButton = [UIButton buttonWithType:UIButtonTypeCustom];
    [closeButton setImage:[UIImage imageNamed:@"cancel_button"] forState:UIControlStateNormal];
    closeButton.frame = CGRectMake(CGRectGetWidth(self.bounds) - 45, 10, 30, 30);
    [self addSubview:closeButton];
}

- (void)addCounterView {
    UIView *counterBackgroundView = [[UIView alloc] initWithFrame:CGRectMake(CGRectGetWidth(self.bounds) - 40, 45, 20, CGRectGetHeight(self.bounds) - 65)];
    counterBackgroundView.layer.borderColor = [UIColor colorWithRed:153.0/255.0 green:183.0/255.0 blue:237.0/255.0 alpha:0.8].CGColor;
    counterBackgroundView.layer.borderWidth = 1;
    [self addSubview:counterBackgroundView];
    
    CGRect frame = CGRectMake(2, 2, counterBackgroundView.bounds.size.width - 4, counterBackgroundView.bounds.size.height - 4);
    UIView *counterView = [[UIView alloc] initWithFrame:frame];
    counterView.backgroundColor = [UIColor colorWithRed:119.0/255.0 green:143.0/255.0 blue:213.0/255.0 alpha:1];
    [counterBackgroundView addSubview:counterView];
    self.counterView = counterView;
}

- (void)generatePuzzleViewForPuzzleImage:(UIImage *)puzzleImage {
    NSArray *puzzleImages = [self puzzleImagesForImage:self.puzzleImage rows:self.numberOfRows columns:self.numberOfColumns];
    self.puzzleViewsArray = [[NSMutableArray alloc] init];
    
    CGSize viewSize = self.puzzleGameView.bounds.size;
    CGSize itemSize = CGSizeMake(viewSize.width/self.numberOfColumns, viewSize.height/self.numberOfRows);
    
    
    for(int i = 0; i < self.numberOfRows; ++i) {
        for (int j = 0; j < self.numberOfColumns; ++j) {
            CGPoint viewPoint = CGPointMake(itemSize.width * j, itemSize.height * i);
            CGRect viewRect  = CGRectMake(viewPoint.x + 0.5, viewPoint.y + 0.5, itemSize.width - 0.5, itemSize.height - 0.5);
            UIImageView *imageView = [[UIImageView alloc] initWithFrame:viewRect];
            NSInteger imageIndex = (i * self.numberOfColumns) + j;
            imageView.image = puzzleImages[imageIndex];
            NSLog(@"index: %@", @(imageIndex));
            UIPanGestureRecognizer *gesture = [[UIPanGestureRecognizer alloc] initWithTarget:self action:@selector(panGesture:)];
            [imageView addGestureRecognizer:gesture];
            imageView.userInteractionEnabled = YES;
            [self.puzzleGameView addSubview:imageView];
            [self.puzzleViewsArray addObject:imageView];
        }
    }
    NSLog(@"%@", @(self.puzzleViewsArray.count));
}

- (void)panGesture:(UIPanGestureRecognizer *)sender {
    
    switch (sender.state) {
        case UIGestureRecognizerStateBegan: {
            [self.puzzleGameView bringSubviewToFront:sender.view];
            self.processingItemCenter = sender.view.center;
        }
            break;
        case UIGestureRecognizerStateChanged: {
            CGPoint translation = [sender translationInView:sender.view];
            sender.view.center = CGPointMake(sender.view.center.x + translation.x,
                                             sender.view.center.y + translation.y);
            [sender setTranslation:CGPointMake(0, 0) inView:sender.view];
        }
            break;
            
        default: {
            CGPoint point = sender.view.center;
            
            CGSize viewSize = self.puzzleGameView.bounds.size;
            CGSize itemSize = CGSizeMake(viewSize.width/self.numberOfColumns, viewSize.height/self.numberOfRows);
            
            NSInteger i = point.x/itemSize.width;
            NSInteger j = point.y/itemSize.height;
            
            NSInteger indexOfImage = j*self.numberOfColumns + i;
            UIImageView *imageView = self.puzzleViewsArray[indexOfImage];
            
            if (indexOfImage < self.puzzleViewsArray.count && imageView != sender.view) {
                NSInteger processingImageIndex = [self.puzzleViewsArray indexOfObject:sender.view];
                [self.puzzleGameView bringSubviewToFront:imageView];
                
                [self.puzzleViewsArray exchangeObjectAtIndex:indexOfImage withObjectAtIndex:processingImageIndex];
                [UIView animateWithDuration:0.2 delay:0 options:UIViewAnimationOptionCurveEaseOut animations:^{
                    sender.view.center = imageView.center;
                    imageView.center = self.processingItemCenter;
                    
                } completion:nil];
            } else {
                [UIView animateWithDuration:0.2 delay:0 options:UIViewAnimationOptionCurveEaseOut animations:^{
                    sender.view.center = self.processingItemCenter;
                } completion:nil];
            }
        }
            
            break;
    }
    
}

// frame size
- (CGRect)frameSizeForRect:(CGRect)superviewRect bannerImageSize:(CGSize)bannerSize {
    float imageAspectRatio = bannerSize.height/bannerSize.width;
    CGRect frame = CGRectZero;
    if (superviewRect.size.width < superviewRect.size.height) {
        frame.size = CGSizeMake(superviewRect.size.width, superviewRect.size.width * imageAspectRatio);
    } else {
        frame.size = CGSizeMake(superviewRect.size.width, superviewRect.size.height);
    }
    return frame;
}

- (CGRect)gameViewFrameForRect:(CGRect)mainRect {
    CGRect rect = CGRectZero;
    rect.origin = CGPointMake(20, 20);
    rect.size = CGSizeMake(mainRect.size.width - 80, mainRect.size.height - 40);
    return rect;
}

@end
