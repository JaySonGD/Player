//
//  CZPlayer.m
//  BaiSibuDeMei
//
//  Created by czljcb on 16/2/17.
//  Copyright © 2016年 czljcb. All rights reserved.
//

#import "CZPlayer.h"

@interface CZPlayer ()
@property (weak, nonatomic) IBOutlet UIView *playView;
@property (weak, nonatomic) IBOutlet UIButton *closeBtn;
@property (weak, nonatomic) IBOutlet UIButton *playBtn;
@property (weak, nonatomic) IBOutlet UIButton *fullBtn;
@property (weak, nonatomic) IBOutlet UISlider *progress;
@property (weak, nonatomic) IBOutlet UILabel *slider;

@property (nonatomic, strong) NSTimer *durationTimer;
@property (nonatomic, strong) NSTimer *autoDismissTimer;
//加载指示器
@property(nonatomic,strong)UIActivityIndicatorView *indicator;

@property (weak, nonatomic) IBOutlet UILabel *totalTime;
@property (weak, nonatomic) IBOutlet UILabel *curTime;

/* playItem */
@property (nonatomic, strong) AVPlayerItem *currentItem;
/**
 *  播放器player
 */
@property(nonatomic,strong)AVPlayer *player;
/**
 *playerLayer,可以修改frame
 */
@property(nonatomic,strong)AVPlayerLayer *playerLayer;


@property (nonatomic, assign) double lastValue;
@property (weak, nonatomic) IBOutlet UIView *bottomView;

@end

@implementation CZPlayer

#pragma mark - getPlayItemWithURLString
-(AVPlayerItem *)getPlayItemWithURLString:(NSString *)urlString
{
    if ([urlString containsString:@"http"])
    {
       // AVPlayerItem *playerItem=[AVPlayerItem playerItemWithURL:[NSURL URLWithString:[urlString stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding]]];
        AVPlayerItem *playerItem= [AVPlayerItem playerItemWithURL:[NSURL URLWithString:[urlString stringByAddingPercentEncodingWithAllowedCharacters:[NSCharacterSet characterSetWithCharactersInString:urlString]]]];
        
        return playerItem;
    }
    else
    {
        AVAsset *movieAsset  = [[AVURLAsset alloc]initWithURL:[NSURL fileURLWithPath:urlString] options:nil];
        AVPlayerItem *playerItem = [AVPlayerItem playerItemWithAsset:movieAsset];
        return playerItem;
    }
    
}
#pragma mark **************************************************************************************************
#pragma mark events
- (IBAction)closePlayer
{
    if (_closeButtonDidClick)
    {
        _closeButtonDidClick();
    }
}
- (IBAction)playPlayer:(UIButton *)sender
{
//    if (self.durationTimer==nil) {
//        self.durationTimer = [NSTimer timerWithTimeInterval:0.2 target:self selector:@selector(finishedPlay:) userInfo:nil repeats:YES];
//        [[NSRunLoop currentRunLoop] addTimer:self.durationTimer forMode:NSDefaultRunLoopMode];
//    }
    sender.selected = !sender.selected;
    if (self.player.rate != 1.f) {
//        if ([self currentTime] == [self duration])
//            [self setCurrentTime:0.f];
        [self.player play];
    } else {
        [self.player pause];
    }
    
    if (_playButtonDidClick)
    {
        _playButtonDidClick();
    }
}
- (IBAction)fullPlayer:(UIButton *)sender
{
    if (_autoFullSreen == YES)
    {
        [self toFullScreenWithInterfaceOrientation:UIInterfaceOrientationLandscapeLeft];
        
    }
    else if(_fullButtonDidClick)
    {
        _fullButtonDidClick();
    }
}


-(void)toNormal{
    [UIView animateWithDuration:0.25f animations:^{
//        self.transform = CGAffineTransformIdentity;
//        self.frame =CGRectMake(_playerFrame.origin.x, _playerFrame.origin.y, _playerFrame.size.width, _playerFrame.size.height);
//
//        [_wmPlayer.bottomView mas_remakeConstraints:^(MASConstraintMaker *make) {
//            make.left.equalTo(_wmPlayer).with.offset(0);
//            make.right.equalTo(_wmPlayer).with.offset(0);
//            make.height.mas_equalTo(40);
//            make.bottom.equalTo(_wmPlayer).with.offset(0);
//        }];
//        [_wmPlayer.closeBtn mas_remakeConstraints:^(MASConstraintMaker *make) {
//            make.left.equalTo(_wmPlayer).with.offset(5);
//            make.height.mas_equalTo(30);
//            make.width.mas_equalTo(30);
//            make.top.equalTo(_wmPlayer).with.offset(5);
//        }];
//        
//    }completion:^(BOOL finished) {
//        _wmPlayer.isFullscreen = NO;
//        _wmPlayer.fullScreenBtn.selected = NO;
//        [UIApplication sharedApplication].statusBarHidden = NO;
//        
   }];
}


-(void)toFullScreenWithInterfaceOrientation:(UIInterfaceOrientation )interfaceOrientation
{
    self.transform = CGAffineTransformIdentity;
    
    [UIApplication sharedApplication].statusBarHidden = YES;
    if (interfaceOrientation==UIInterfaceOrientationLandscapeLeft)
    {
        self.transform = CGAffineTransformMakeRotation(-M_PI_2);
    }else if(interfaceOrientation==UIInterfaceOrientationLandscapeRight)
    {
        self.transform = CGAffineTransformMakeRotation(M_PI_2);
    }
    self.frame = CGRectMake(0, 0, [UIScreen mainScreen].bounds.size.width,[UIScreen mainScreen].bounds.size.height);
    
    
}




#pragma mark - 设置播放的视频
- (void)setVideoURLStr:(NSString *)videoURLStr
{
    _videoURLStr = videoURLStr;
    
    if (self.currentItem)
    {
        [[NSNotificationCenter defaultCenter] removeObserver:self name:AVPlayerItemDidPlayToEndTimeNotification object:_currentItem];
        [self.currentItem removeObserver:self forKeyPath:@"status"];
        [self.currentItem removeObserver:self forKeyPath:@"loadedTimeRanges"];

        
    }
    
    self.currentItem = [self getPlayItemWithURLString:videoURLStr];

    [self.currentItem addObserver:self
                       forKeyPath:@"status"
                          options:NSKeyValueObservingOptionInitial | NSKeyValueObservingOptionNew
                          context:nil];
    [self.currentItem addObserver:self forKeyPath:@"loadedTimeRanges" options:NSKeyValueObservingOptionNew context:nil];
    [self.player replaceCurrentItemWithPlayerItem:self.currentItem];
    
    
    // 添加视频播放结束通知
    [[NSNotificationCenter defaultCenter]addObserver:self selector:@selector(moviePlayDidEnd:) name:AVPlayerItemDidPlayToEndTimeNotification object:_currentItem];
    
}

- (void)moviePlayDidEnd:(NSNotification *)noti
{
    if (_finishedPlayMedia)
    {
        _finishedPlayMedia();
    }
}

- (void)dealloc
{
    [self.player pause];
    self.autoDismissTimer = nil;
    self.durationTimer = nil;
    self.player = nil;
    [self.currentItem removeObserver:self forKeyPath:@"status"];
    [self.currentItem removeObserver:self forKeyPath:@"loadedTimeRanges"];
    [[NSNotificationCenter defaultCenter] removeObserver:self name:AVPlayerItemDidPlayToEndTimeNotification object:_currentItem];
    
}


- (CMTime)playerItemDuration
{
    AVPlayerItem *playerItem = [self.player currentItem];
    if (playerItem.status == AVPlayerItemStatusReadyToPlay)
    {
        return([playerItem duration]);
    }
    
    return(kCMTimeInvalid);
}


- (void)syncScrubber
{
    CMTime playerDuration = [self playerItemDuration];
    if (CMTIME_IS_INVALID(playerDuration))
    {
        self.progress.minimumValue = 0.0;
        return;
    }
    
    double duration = CMTimeGetSeconds(playerDuration);
    if (isfinite(duration))
    {
        float minValue = [self.progress minimumValue];
        float maxValue = [self.progress maximumValue];
        double time = CMTimeGetSeconds([self.player currentTime]);
        
        _totalTime.text = [NSString stringWithFormat:@"%02zd:%02zd",(int)duration/60 , (int) duration%60];
        _curTime.text = [NSString stringWithFormat:@"%02zd:%02zd",(int)time / 60 , (int) time % 60];
        
        [self.progress setValue:(maxValue - minValue) * time / duration + minValue];
    }
    
}

-(void)initTimer
{
    double interval = .1f;
    
    CMTime playerDuration = [self playerItemDuration];
    if (CMTIME_IS_INVALID(playerDuration))
    {
        return;
    }
    double duration = CMTimeGetSeconds(playerDuration);
    if (isfinite(duration))
    {
        CGFloat width = CGRectGetWidth([self.progress bounds]);
        interval = 0.5f * duration / width;
    }
    NSLog(@"interva === %f",interval);
    
    __weak typeof(self) weakSelf = self;
    
    [weakSelf.player addPeriodicTimeObserverForInterval:CMTimeMakeWithSeconds(interval, NSEC_PER_SEC)  queue:NULL /* If you pass NULL, the main queue is used. */ usingBlock:^(CMTime time){
        [self syncScrubber];
    }];
    
}

- (void)observeValueForKeyPath:(NSString *)keyPath ofObject:(id)object change:(NSDictionary *)change context:(void *)context
{
    /* AVPlayerItem "status" property value observer. */
    if([keyPath isEqualToString:@"status"])
    {
        
        AVPlayerStatus status = [[change objectForKey:NSKeyValueChangeNewKey] integerValue];
        
        NSLog(@"%zd",status);
        switch (status)
        {
                /* Indicates that the status of the player is not yet known because
                 it has not tried to load new media resources for playback */
            case AVPlayerStatusUnknown:
            {
                
            }
                break;
                
            case AVPlayerStatusReadyToPlay:
            {
                
                /* Once the AVPlayerItem becomes ready to play, i.e.
                 [playerItem status] == AVPlayerItemStatusReadyToPlay,
                 its duration can be fetched from the item. */
                if (CMTimeGetSeconds(self.player.currentItem.duration))
                {
                    self.progress.maximumValue = CMTimeGetSeconds(self.player.currentItem.duration);
                }
                
                [self initTimer];
                if (self.durationTimer==nil)
                {
                    self.durationTimer = [NSTimer timerWithTimeInterval:0.2 target:self selector:@selector(finishedPlay:) userInfo:nil repeats:YES];
                    [[NSRunLoop currentRunLoop] addTimer:self.durationTimer forMode:NSDefaultRunLoopMode];
                }
                
                //5s dismiss bottomView
                if (self.autoDismissTimer==nil)
                {
                    self.autoDismissTimer = [NSTimer timerWithTimeInterval:5.0 target:self selector:@selector(autoDismissBottomView:) userInfo:nil repeats:YES];
                    [[NSRunLoop currentRunLoop] addTimer:self.autoDismissTimer forMode:NSDefaultRunLoopMode];
                }
                
                [_indicator stopAnimating];
                
                [_player play];

            }
                break;
                
            case AVPlayerStatusFailed:
            {
                [_indicator stopAnimating];

            }
                break;
        }
    }
    else if([keyPath isEqualToString:@"loadedTimeRanges"])
    {
        NSArray *array=_currentItem.loadedTimeRanges;
        CMTimeRange timeRange = [array.firstObject CMTimeRangeValue];//本次缓冲时间范围
        float startSeconds = CMTimeGetSeconds(timeRange.start);
        float durationSeconds = CMTimeGetSeconds(timeRange.duration);
        NSTimeInterval totalBuffer = startSeconds + durationSeconds;//缓冲总长度
        NSLog(@"共缓冲：%.2f",totalBuffer);
        //
    }
    
}

- (void)finishedPlay:(NSTimer *)timer
{
    NSLog(@"%s", __func__);
   
    if ( CMTimeGetSeconds([self.player currentTime])== _lastValue )
    {
        if (_playBtn.selected == YES)
        {
            [_indicator startAnimating];

        }
    }
    else
    {
        [_indicator stopAnimating];
    }
    _lastValue =     CMTimeGetSeconds([self.player currentTime]);;

}

-(void)autoDismissBottomView:(NSTimer *)timer
{
    
}
- (IBAction)ww:(UISlider *)sender
{
    NSLog(@"%s", __func__);
    
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(2.0 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
        [self.player play];
 
    });
    NSLog(@"%zd---%f", _player.status,_player.rate);
    
   // _player.status
}
- (IBAction)updateProgress:(UISlider *)sender
{
    [self.player seekToTime:CMTimeMakeWithSeconds(sender.value, 1)];
    
}

-(void)showIndicator
{
    _indicator=[[UIActivityIndicatorView alloc]initWithActivityIndicatorStyle:UIActivityIndicatorViewStyleWhiteLarge];
    _indicator.center = self.center;
    [self addSubview:_indicator];
    [_indicator startAnimating];
}

- (AVPlayer *)player
{
    if (_player == nil)
    {
        //AVPlayer
        _player = [AVPlayer playerWithPlayerItem:self.currentItem];
        
        //AVPlayerLayer
        _playerLayer = [AVPlayerLayer playerLayerWithPlayer:self.player];
        
        //_playerLayer.videoGravity = AVLayerVideoGravityResize;
        [self.playView.layer addSublayer:_playerLayer];
        
        
        //增加音量的手势
        UISwipeGestureRecognizer *increaseGesture=[[UISwipeGestureRecognizer alloc]initWithTarget:self action:@selector(increaseVolume:)];
        increaseGesture.direction=UISwipeGestureRecognizerDirectionUp;
        [self.playView addGestureRecognizer:increaseGesture];
        
        //减小音量的手势
        UISwipeGestureRecognizer *decreaseGesture=[[UISwipeGestureRecognizer alloc]initWithTarget:self action:@selector(decreaseVolume:)];
        decreaseGesture.direction=UISwipeGestureRecognizerDirectionDown;
        [self.playView addGestureRecognizer:decreaseGesture];
        
        //快进
        UISwipeGestureRecognizer *stepForward=[[UISwipeGestureRecognizer alloc]initWithTarget:self action:@selector(stepForward10Seconds)];
        stepForward.direction=UISwipeGestureRecognizerDirectionRight;
        [self.playView addGestureRecognizer:stepForward];

        //快退
        UISwipeGestureRecognizer *stepBackward=[[UISwipeGestureRecognizer alloc]initWithTarget:self action:@selector(stepBackward10Senconds)];
        stepBackward.direction=UISwipeGestureRecognizerDirectionLeft;
        [self.playView addGestureRecognizer:stepBackward];
        
        
        // 单击的 Recognizer
        UITapGestureRecognizer* singleTap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(handleSingleTap)];
        singleTap.numberOfTapsRequired = 1; // 单击
        [self addGestureRecognizer:singleTap];
        
        // 双击的 Recognizer
        UITapGestureRecognizer* doubleTap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(handleDoubleTap)];
        doubleTap.numberOfTapsRequired = 2; // 双击
        [self addGestureRecognizer:doubleTap];
        
        [self showIndicator];
        
                self.durationTimer = [NSTimer timerWithTimeInterval:1.0 target:self selector:@selector(finishedPlay:) userInfo:nil repeats:YES];
                [[NSRunLoop currentRunLoop] addTimer:self.durationTimer forMode:NSDefaultRunLoopMode];

    }
    return _player;
}

#pragma mark
#pragma mark - 单击手势方法
- (void)handleSingleTap{
    [UIView animateWithDuration:0.5 animations:^{
        if (self.bottomView.alpha == 0.0) {
            self.bottomView.alpha = 1.0;
            self.closeBtn.alpha = 1.0;
            
        }else{
            self.bottomView.alpha = 0.0;
            self.closeBtn.alpha = 0.0;
            
        }
    } completion:^(BOOL finish){
        
    }];
}
#pragma mark
#pragma mark - 双击手势方法
- (void)handleDoubleTap{
    self.playBtn.selected = !self.playBtn.selected;
    if (self.player.rate != 1.f) {
        //if ([self currentTime] == self.duration)
          //  [self setCurrentTime:0.f];
        [self.player play];
    } else {
        [self.player pause];
    }
}
/**
  *  向上滑动增加音量
  *
  *  @param sender 滑动手势
  */
-(void)increaseVolume:(UISwipeGestureRecognizer *)sender
{
    if(sender.direction==UISwipeGestureRecognizerDirectionUp)
    {
        if(_player.volume>=1.0)
            return;
        _player.volume+=0.01;
        NSLog(@"+++++音量:%f++++++",10*_player.volume);
        
        __weak typeof(self) weakSelf = self;
        _slider.text=[NSString stringWithFormat:@"音量:%d%%",(int)ceilf(_player.volume*100)];
        [UIView animateWithDuration:1 animations:^{
            weakSelf.slider.alpha=1.0;
        } completion:^(BOOL finished) {
            [UIView animateWithDuration:0.2 animations:^{
                weakSelf.slider.alpha=0.0;
            }];
        }];
    }
}
/**
 *  向下滑动减小音量
 *
 *  @param sender 滑动手势对象
 */
-(void)decreaseVolume:(UISwipeGestureRecognizer *)sender
{
    if(sender.direction==UISwipeGestureRecognizerDirectionDown)
    {
        if(_player.volume<=0.0)
            return;
        _player.volume-=0.1;
        NSLog(@"------音量:%f------",10*_player.volume);
        
        __weak typeof(self) weakSelf = self;
        _slider.text=[NSString stringWithFormat:@"音量:%d%%",(int)ceilf(_player.volume*100)];
        [UIView animateWithDuration:1.0 animations:^{
            weakSelf.slider.alpha=1.0;
        } completion:^(BOOL finished) {
            [UIView animateWithDuration:0.3 animations:^{
                weakSelf.slider.alpha=0.0;
            }];
        }];
    }
}
#pragma mark -
#pragma mark - 快退快进
//@qustion:seekToTime和seekToTime:toleranceBefore:toleranceAfter的区别是什么？
//快进10秒
-(void)stepForward10Seconds
{
        //if(_isPlaying)
        {
            [_currentItem seekToTime:CMTimeMakeWithSeconds(_currentItem.currentTime.value/_currentItem.currentTime.timescale+10, _currentItem.currentTime.timescale) toleranceBefore:CMTimeMake(1, _currentItem.currentTime.timescale) toleranceAfter:CMTimeMake(1, _currentItem.currentTime.timescale)];
            __weak typeof(self) weakSelf=self;
            _slider.text=[NSString stringWithFormat:@"进度:%d%%",(int)(_progress.value/_progress.maximumValue * 100)];

            NSLog(@"%f",_progress.value);
            [UIView animateWithDuration:3.0 animations:^{
                weakSelf.slider.alpha=1.0;
            }completion:^(BOOL finished) {
                [UIView animateWithDuration:3.0 animations:^{
                    weakSelf.slider.alpha=0.0;
                }];
            }];
        }
}
//快退10秒
-(void)stepBackward10Senconds
{
        //if(_isPlaying)
        {
            [_currentItem seekToTime:CMTimeMakeWithSeconds(_currentItem.currentTime.value/_currentItem.currentTime.timescale-10, _currentItem.currentTime.timescale)];
            __weak typeof(self) weakSelf=self;
            
            _slider.text=[NSString stringWithFormat:@"进度:%d%%",(int)(_progress.value/_progress.maximumValue * 100)];
            [UIView animateWithDuration:0.3 animations:^{
                weakSelf.slider.alpha=1.0;
            }completion:^(BOOL finished) {
                [UIView animateWithDuration:0.3 animations:^{
                    weakSelf.slider.alpha=0.0;
                }];
            }];
        }
}





- (void)awakeFromNib
{
    _playBtn.showsTouchWhenHighlighted = YES;
    [_playBtn setImage:[UIImage imageNamed:@"player.bundle/play"] forState:UIControlStateNormal];
    [_playBtn setImage:[UIImage imageNamed:@"player.bundle/pause"] forState:UIControlStateSelected];

    [_closeBtn setImage:[UIImage imageNamed:@"player.bundle/close"] forState:UIControlStateNormal];

    [_fullBtn setImage:[UIImage imageNamed:@"player.bundle/nonfullscreen"] forState:UIControlStateNormal];
        [_fullBtn setImage:[UIImage imageNamed:@"player.bundle/fullscreen"] forState:UIControlStateSelected];

    _closeBtn.showsTouchWhenHighlighted = YES;
    _fullBtn.showsTouchWhenHighlighted = YES;
    
    [_progress setThumbImage:[UIImage imageNamed:@"player.bundle/dot"] forState:UIControlStateNormal];
    _progress.minimumTrackTintColor = [UIColor greenColor];
    
}


- (void)layoutSubviews
{
    [super layoutSubviews];

    self.playerLayer.frame = self.playView.bounds;
    NSLog(@"%@",NSStringFromCGRect(self.playView.bounds));
}


/*
 // Only override drawRect: if you perform custom drawing.
 // An empty implementation adversely affects performance during animation.
 - (void)drawRect:(CGRect)rect {
 // Drawing code
 }
 */

@end
