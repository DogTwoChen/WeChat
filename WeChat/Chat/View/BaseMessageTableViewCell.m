//
//  ChatroomTableViewCell.m
//  WeChat
//
//  Created by Siegrain on 16/4/4.
//  Copyright © 2016年 siegrain. weChat. All rights reserved.
//

#import "BaseMessageTableViewCell.h"
#import "ChatModel.h"
#import "DateUtil.h"
#import "InsetsTextField.h"
#import "Masonry/Masonry/Masonry.h"

static NSInteger const kAvatarSize = 40;
static NSInteger const kAvatarMarginH = 10;

@interface
BaseMessageTableViewCell ()
@property (strong, nonatomic) InsetsTextField* sendTimeField;
@property (strong, nonatomic) UIImageView* avatarImageView;
@end

@implementation BaseMessageTableViewCell
#pragma mark - init
- (MessageAlignement)alignement
{
  if (_alignement == MessageAlignementUndefined) {
    _alignement =
      arc4random() % 2 == 0 ? MessageAlignementLeft : MessageAlignementRight;
  }
  return _alignement;
}
- (instancetype)initWithStyle:(UITableViewCellStyle)style
              reuseIdentifier:(NSString*)reuseIdentifier
{
  if (self = [super initWithStyle:style reuseIdentifier:reuseIdentifier]) {
    self.backgroundColor = [UIColor clearColor];
    self.selectionStyle = UITableViewCellSelectionStyleNone;

    [self buildCell];
    [self bindConstraints];
    [self bindGestureRecognizer];
  }
  return self;
}
- (void)setModel:(ChatModel*)model
{
  /*
   NMB啊，在setModel的时候才调用buildCell或bindConstraints的话
   尼玛systemFittingSize是算不出大小的
   尼玛啊。
   你麻痹吧。。。

   还有啊，尼玛不能在这里判断model !=
   nil就return，那样只能算出第一行的高度
   卧槽尼玛。
   */
  _model = model;
  self.avatarImageView.image = self.alignement == MessageAlignementRight
                                 ? [UIImage imageNamed:@"siegrain_avatar"]
                                 : [UIImage imageNamed:@"robot"];

  UIImage* bubbleImage = self.alignement == MessageAlignementRight
                           ? [UIImage imageNamed:@"SenderTextNodeBkg"]
                           : [UIImage imageNamed:@"ReceiverTextNodeBkgHL"];
  //设置图片有哪些地方是不能被拉伸的，以像素为单位
  UIEdgeInsets insets = UIEdgeInsetsMake(30, 15, 30, 15);
  bubbleImage = [bubbleImage resizableImageWithCapInsets:insets];
  self.bubbleView.image = bubbleImage;

  /*
   一定要两个判断都修改约束
   因为缓存会认为每一行都有时间条

   玛德坑死人了。
   */
  if (model.sendTime != nil) {
    self.sendTimeField.text = [DateUtil dateString:model.sendTime
                                        withFormat:@"yyyy年MM月dd日 "
                                                    "HH:mm"];
    self.sendTimeField.hidden = false;
    [self.avatarImageView mas_updateConstraints:^(MASConstraintMaker* make) {
      make.top.offset(40);
    }];
  } else {
    self.sendTimeField.hidden = true;
    [self.avatarImageView mas_updateConstraints:^(MASConstraintMaker* make) {
      make.top.offset(5);
    }];
  }
}

- (void)buildCell
{
  self.sendTimeField = [[InsetsTextField alloc] init];
  self.sendTimeField.backgroundColor = [UIColor colorWithWhite:.83 alpha:1];
  self.sendTimeField.textColor = [UIColor whiteColor];
  self.sendTimeField.font = [UIFont systemFontOfSize:12];
  self.sendTimeField.textAlignment = NSTextAlignmentCenter;
  self.sendTimeField.layer.cornerRadius = 5;
  self.sendTimeField.textFieldInset = CGPointMake(3, 3);
  self.sendTimeField.userInteractionEnabled = false;
  [self.contentView addSubview:self.sendTimeField];

  self.avatarImageView = [[UIImageView alloc] init];
  [self.contentView addSubview:self.avatarImageView];

  self.bubbleView = [[UIImageView alloc] init];
  self.bubbleView.userInteractionEnabled = true;
  [self.contentView addSubview:self.bubbleView];
}

- (void)bindConstraints
{
  [self.sendTimeField mas_makeConstraints:^(MASConstraintMaker* make) {
    make.bottom.equalTo(self.avatarImageView.mas_top).offset(-10);
    make.centerX.offset(0);
  }];
  [self.avatarImageView mas_makeConstraints:^(MASConstraintMaker* make) {
    make.top.offset(0);
    make.width.height.offset(kAvatarSize);
    if (self.alignement == MessageAlignementLeft)
      make.leading.offset(kAvatarMarginH);
    else
      make.trailing.offset(-kAvatarMarginH);

  }];
  [self.bubbleView mas_makeConstraints:^(MASConstraintMaker* make) {
    make.bottom.offset(-5);
    make.top.equalTo(self.avatarImageView).offset(-2);
    make.width.lessThanOrEqualTo(self.contentView);
    if (self.alignement == MessageAlignementLeft) {
      //指view的左边在avatar的右边，边距为5
      make.left.equalTo(self.avatarImageView.mas_right).offset(5);
      make.right.lessThanOrEqualTo(self.contentView).offset(-100);
    } else {
      make.right.equalTo(self.avatarImageView.mas_left).offset(-5);
      make.left.greaterThanOrEqualTo(self.contentView).offset(100);
    }
  }];
}

#pragma mark - gesture
- (void)bindGestureRecognizer
{
  UILongPressGestureRecognizer* bubblelongPress =
    [[UILongPressGestureRecognizer alloc]
      initWithTarget:self
              action:@selector(longPressOnBubble:)];
  [self.bubbleView addGestureRecognizer:bubblelongPress];
}

- (void)longPressOnBubble:(UILongPressGestureRecognizer*)press
{
}
#pragma mark -
- (BOOL)canBecomeFirstResponder
{
  return true;
}

- (BOOL)canPerformAction:(SEL)action withSender:(id)sender
{
  return false;
}
@end
