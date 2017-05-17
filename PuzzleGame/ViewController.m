//
//  ViewController.m
//  PuzzleGame
//
//  Created by Karen Ghandilyan on 5/17/17.
//  Copyright © 2017 Wagawin. All rights reserved.
//

#import "ViewController.h"
#import "PuzzleService.h"

@interface ViewController ()
@property (nonatomic, strong) PuzzleService *puzzleService;
@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view, typically from a nib.
    self.puzzleService = [[PuzzleService alloc] initForView:self.view];
}


- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}


@end
