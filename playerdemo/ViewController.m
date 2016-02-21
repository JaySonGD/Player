//
//  ViewController.m
//  playerdemo
//
//  Created by czljcb on 16/2/17.
//  Copyright © 2016年 czljcb. All rights reserved.
//

#import "ViewController.h"
#import "UIView+Frame.h"
#import "CZPlayer.h"

@interface ViewController ()
/** <##> */
@property (nonatomic, weak) CZPlayer *player;
@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view, typically from a nib.
    
    CZPlayer *playerView = [CZPlayer viewFromXib];
    //playerView.center = self.view.center;
    _player = playerView;
    [self.view addSubview:playerView];
    playerView.width = self.view.width;
    playerView.height = self.view.width*9/16;
    //playerView.autoFullSreen = YES;
    playerView.videoURLStr = @"http://wvideo.spriteapp.cn/video/2016/0215/56c18a0715221_wpd.mp4";
    
    playerView.finishedPlayMedia = ^{
      NSLog(@"%s", __func__);
    };

    playerView.closeButtonDidClick = ^{
        NSLog(@"%s", __func__);
    };
    playerView.playButtonDidClick = ^{
      NSLog(@"%s", __func__);
    };
    playerView.fullButtonDidClick = ^{
      NSLog(@"%s", __func__);
    };
}




- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end
