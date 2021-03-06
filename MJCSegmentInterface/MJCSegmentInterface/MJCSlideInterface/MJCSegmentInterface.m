//https://github.com/MJCIOS/MJCSegmentInterface
//如果觉得好,麻烦点个星,谢谢大家支持,有啥问题加我QQ: 292251588 一起交流,我是菜菜..求大神指教
//  MJCSegmentInterface.m
//  MJCSegmentInterface
//
//  Created by mjc on 16/10/7.
//  Copyright © 2016年 MJC. All rights reserved.

#import "MJCSegmentInterface.h"
#import "MJCChildMainView.h"
#import "MJCTitlesView.h"
#import "MJCTabItem.h"
#import "sys/utsname.h"
#import "UIView+MJCClassExtension.h"


#define DELAYTIMES (0.0005)
static CGFloat const defaultTitlesViewH = 50;

@interface MJCSegmentInterface ()<UIScrollViewDelegate>
@property (nonatomic, strong) MJCChildMainView *childMainView;
@property (nonatomic, strong) MJCTitlesView *titlesView;
@property (nonatomic,strong) NSArray *titlesArray;
@property (nonatomic,weak) UIViewController *hostController;
@property (nonatomic,weak) NSArray *childControllerArray;
@property (nonatomic,assign) BOOL isXibLayoutSetup;
@property (nonatomic,assign) BOOL isLoadDefaultChildVC;
@end
@implementation MJCSegmentInterface

+(instancetype)showInterfaceWithTitleBarFrame:(CGRect)frame Styles:(MJCTitleBarStyles)titleBarStyles;
{
    MJCSegmentInterface *interface = [[self alloc]initWithFrame:frame];
    interface.titleBarStyles = titleBarStyles;
    return interface;
}
-(instancetype)initWithFrame:(CGRect)frame
{
    if (self = [super initWithFrame:frame]) {
        [self setupBasicUI];
    }
    return self;
}
-(void)awakeFromNib
{
    [super awakeFromNib];
    _isXibLayoutSetup = YES;
    [self setupBasicUI];
    _titlesView.jc_width = self.jc_width;
}
-(void)layoutSubviews
{
    [super layoutSubviews];
    [self setupUIFrame];
}
-(void)setupBasicUI
{
    _titlesView = [[MJCTitlesView alloc]init];
    _titlesView.frame = CGRectMake(0,0,0,defaultTitlesViewH);
    [_titlesView tableItemClickBlock:^(MJCTabItem *tabItem) {
        _childMainView.titlesTabItem = tabItem;
        [_childMainView addChildVcView];
        if ([self.delegate respondsToSelector:@selector(mjc_ClickEvent:childViewController:segmentInterface:)]) {
            if ( tabItem.tag >=_hostController.childViewControllers.count) {
                [self.delegate mjc_ClickEvent:tabItem childViewController:nil segmentInterface:self];
            }else{
                [self.delegate mjc_ClickEvent:tabItem childViewController:_hostController.childViewControllers[tabItem.tag] segmentInterface:self];
            }
        }
    }];
    _childMainView = [[MJCChildMainView alloc]init];
    _childMainView.delegate = self;
    [self addSubview:_childMainView];
    [self addSubview:_titlesView];
}
-(void)setupUIFrame
{
    if (_titlesViewFrame.size.width == 0) {
        _titlesView.jc_width = self.jc_width;
    }else{
        _titlesView.jc_width = _titlesViewFrame.size.width;
    }
    if (_isPenetrationEffect) {
        _childMainView.frame =CGRectMake(0,0,self.jc_width,self.jc_height);
    }else{
        CGFloat titlesViewMaxY = CGRectGetMaxY(_titlesView.frame);
        _childMainView.frame =CGRectMake(0,titlesViewMaxY,self.jc_width,self.jc_height-titlesViewMaxY);
    }
    
    [_childMainView setupChildViewHeightisLoadDefaultChildVC:_isLoadDefaultChildVC];
}

-(void)intoChildControllerArray:(NSArray *)childControllerArray
{   _childControllerArray = childControllerArray;
    _childMainView.childControllerArray = childControllerArray;
}
-(void)intoTitlesArray:(NSArray *)titlesArray hostController:(UIViewController *)hostController
{   _titlesArray = titlesArray;
    hostController.automaticallyAdjustsScrollViewInsets = NO;
    _hostController = hostController;
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(DELAYTIMES * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
        _childMainView.hostController = hostController;
        _titlesView.hostController = hostController;
        if (!_isXibLayoutSetup) {
            [self layoutIfNeeded];
            [self setNeedsLayout];
        }
        [_childMainView setupContenSizeWithTitlesArr:titlesArray mainView:self];
        _titlesView.titlesArray = titlesArray;
        _isLoadDefaultChildVC = YES;
        _titlesView.selectedSegmentIndex = _selectedSegmentIndex;        
    });
}
-(void)scrollViewDidScroll:(UIScrollView *)scrollView
{
    [_titlesView jc_scrollViewDidScroll:scrollView isIndicatorFollow:_isIndicatorFollow];
}
- (void)scrollViewDidEndDragging:(UIScrollView *)scrollView willDecelerate:(BOOL)decelerate;
{
    [_titlesView jc_scrollViewDidEndDragging:scrollView itemTextNormalColor:_itemTextNormalColor];
}
- (void)scrollViewWillEndDragging:(UIScrollView *)scrollView withVelocity:(CGPoint)velocity targetContentOffset:(inout CGPoint *)targetContentOffset
{
    [_titlesView jc_scrollViewWillEndDragging:scrollView itemTextNormalColor:_itemTextNormalColor];
}
- (void)scrollViewDidEndDecelerating:(UIScrollView *)scrollView
{
    [_titlesView jc_scrollViewDidEndDecelerating:scrollView];
}
-(void)tabItemTitlezoomBigEnabled:(BOOL)zoomBigEnabled tabItemTitleMaxfont:(CGFloat)tabItemTitleMaxfont
{
    [_titlesView tabItemTitlezoomBigEnabled:zoomBigEnabled tabItemTitleMaxfont:tabItemTitleMaxfont];
}
-(void)setIndicatorFrame:(CGRect)indicatorFrame
{
    _indicatorFrame = indicatorFrame;
    _titlesView.indicatorFrame = indicatorFrame;
}
-(void)setIndicatorHidden:(BOOL)indicatorHidden
{
    _indicatorHidden = indicatorHidden;
    _titlesView.indicatorHidden = indicatorHidden;
}
-(void)setIndicatorColor:(UIColor *)indicatorColor
{
    _indicatorColor = indicatorColor;
    _titlesView.indicatorColor = indicatorColor;
}
-(void)setIndicatorImage:(UIImage *)indicatorImage
{
    _indicatorImage = indicatorImage;
    _titlesView.indicatorImage = indicatorImage;
}
-(void)setIsIndicatorsAnimals:(BOOL)isIndicatorsAnimals
{
    _isIndicatorsAnimals = isIndicatorsAnimals;
    _titlesView.isIndicatorsAnimals = isIndicatorsAnimals;
}
-(void)setDefaultShowItemCount:(NSInteger)defaultShowItemCount
{
    _defaultShowItemCount = defaultShowItemCount;
    _titlesView.defaultShowItemCount = defaultShowItemCount;
}
-(void)setTitlesViewFrame:(CGRect)titlesViewFrame
{
    _titlesViewFrame = titlesViewFrame;
    _titlesView.titlesViewFrame = titlesViewFrame;
}
-(void)setTitlesViewBackColor:(UIColor *)titlesViewBackColor
{
    _titlesViewBackColor = titlesViewBackColor;
    _titlesView.titlesViewBackColor = titlesViewBackColor;
}
-(void)setTitlesViewBackImage:(UIImage *)titlesViewBackImage
{
    _titlesViewBackImage = titlesViewBackImage;
    _titlesView.backgroudImage = titlesViewBackImage;
}
-(void)setIsChildScollEnabled:(BOOL)isChildScollEnabled
{
    _isChildScollEnabled = isChildScollEnabled;
    _childMainView.isChildScollEnabled = isChildScollEnabled;
}
-(void)setIsChildScollAnimal:(BOOL)isChildScollAnimal
{
    _isChildScollAnimal = isChildScollAnimal;
    _childMainView.isChildScollAnimal = isChildScollAnimal;
}
-(void)setItemBackColor:(UIColor *)itemBackColor
{
    _itemBackColor = itemBackColor;
    _titlesView.itemBackColor = itemBackColor;
}
-(void)setItemTextFontSize:(CGFloat)itemTextFontSize
{
    _itemTextFontSize = itemTextFontSize;
    _titlesView.itemTextFontSize = itemTextFontSize;
}
-(void)setItemTextNormalColor:(UIColor *)itemTextNormalColor
{
    _itemTextNormalColor = itemTextNormalColor;
    _titlesView.itemTextNormalColor = itemTextNormalColor;
}
-(void)setItemTextSelectedColor:(UIColor *)itemTextSelectedColor
{
    _itemTextSelectedColor = itemTextSelectedColor;
    _titlesView.itemTextSelectedColor = itemTextSelectedColor;
}
-(void)setItemImageNormal:(UIImage *)itemImageNormal
{
    _itemImageNormal = itemImageNormal;
    _titlesView.itemImageNormal = itemImageNormal;
}
-(void)setItemImageSelected:(UIImage *)itemImageSelected
{
    _itemImageSelected = itemImageSelected;
    _titlesView.itemImageSelected = itemImageSelected;
}
-(void)setItemImageNormalArray:(NSArray *)itemImageNormalArray
{
    _itemImageNormalArray = itemImageNormalArray;
    _titlesView.itemImageNormalArray = itemImageNormalArray;
}
-(void)setItemImageSelectedArray:(NSArray *)itemImageSelectedArray
{
    _itemImageNormalArray = itemImageSelectedArray;
    _titlesView.itemImageSelectedArray = itemImageSelectedArray;
}
-(void)setItemBackNormalImage:(UIImage *)itemBackNormalImage
{
    _itemBackNormalImage = itemBackNormalImage;
    _titlesView.itemBackNormalImage = itemBackNormalImage;
}
-(void)setItemBackSelectedImage:(UIImage *)itemBackSelectedImage
{
    _itemBackSelectedImage = itemBackSelectedImage;
    _titlesView.itemBackSelectedImage = itemBackSelectedImage;
}
-(void)setItemNormalBackImageArray:(NSArray *)itemNormalBackImageArray
{
    _itemNormalBackImageArray = itemNormalBackImageArray;
    _titlesView.itemNormalBackImageArray = itemNormalBackImageArray;
}
-(void)setItemSelectedBackImageArray:(NSArray *)itemSelectedBackImageArray
{
    _itemSelectedBackImageArray = itemSelectedBackImageArray;
    _titlesView.itemSelectedBackImageArray = itemSelectedBackImageArray;
}
-(void)setIsItemTitleTextHidden:(BOOL)isItemTitleTextHidden
{
    _isItemTitleTextHidden = isItemTitleTextHidden;
    _titlesView.isItemTitleTextHidden = isItemTitleTextHidden;
}
-(void)setItemImageSize:(CGSize)itemImageSize
{
    _itemImageSize = itemImageSize;
    _titlesView.itemImageSize = itemImageSize;
}
-(void)setItemTextsEdgeInsets:(UIEdgeInsets)itemTextsEdgeInsets
{
    _itemTextsEdgeInsets = itemTextsEdgeInsets;
    _titlesView.itemTextsEdgeInsets = itemTextsEdgeInsets;
}
-(void)setItemImagesEdgeInsets:(UIEdgeInsets)itemImagesEdgeInsets
{
    _itemImagesEdgeInsets = itemImagesEdgeInsets;
    _titlesView.itemImagesEdgeInsets = itemImagesEdgeInsets;
}
-(void)setIsFontGradient:(BOOL)isFontGradient
{
    _isFontGradient = isFontGradient;
    _titlesView.isFontGradient = isFontGradient;
}
-(void)setIndicatorStyles:(MJCIndicatorStyles)indicatorStyles
{
    _indicatorStyles = indicatorStyles;
    _titlesView.indicatorStyles = indicatorStyles;
}
-(void)setSelectedSegmentIndex:(NSInteger)selectedSegmentIndex
{
    _selectedSegmentIndex = selectedSegmentIndex;
    _titlesView.selectedSegmentIndex = selectedSegmentIndex;
}
-(void)setIsIndicatorFollow:(BOOL)isIndicatorFollow
{
    _isIndicatorFollow = isIndicatorFollow;
    _titlesView.isIndicatorFollow = isIndicatorFollow;
}
-(void)setTitleBarStyles:(MJCTitleBarStyles)titleBarStyles
{
    _titleBarStyles = titleBarStyles;
    _titlesView.titlesBarStyles = titleBarStyles;
}
-(void)setImageEffectStyles:(MJCImageEffectStyles)imageEffectStyles
{
    _imageEffectStyles = imageEffectStyles;
    _titlesView.imageEffectStyles = imageEffectStyles;
}

@end
