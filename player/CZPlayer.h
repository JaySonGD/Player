//
//  CZPlayer.h
//  BaiSibuDeMei
//
//  Created by czljcb on 16/2/17.
//  Copyright © 2016年 czljcb. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <AVFoundation/AVFoundation.h>

@interface CZPlayer : UIView


@property(nonatomic,copy) NSString *videoURLStr;

@property (nonatomic, copy) void (^playButtonDidClick) (void);

@property (nonatomic, copy) void (^fullButtonDidClick) (void);

@property (nonatomic, copy) void (^closeButtonDidClick) (void);

@property (nonatomic, copy) void (^finishedPlayMedia) (void);

@property (nonatomic, assign) BOOL autoFullSreen;

+ (instancetype)viewFromXib;
@end
