

#import "NTCalendar.h"
#import "NTCalendarScrollView.h"
#import "NTCalendarConst.h"

#define kLeftView_W     (self.bounds.size.width*0.3)
#define kRightView_W    floorf(self.bounds.size.width*0.7)
#define kOneLine_H      ((self.bounds.size.height-20)/7.0)
#define kCellWidth      (kRightView_W/7.0)
#define kOffset         5

@interface NTCalendar ()
@property (nonatomic, strong) UIView *leftView;
@property (nonatomic, weak) UILabel *dayLabel;
@property (nonatomic, weak) UILabel *monLabel;
@property (nonatomic, weak) UILabel *yearLabel;
@property (nonatomic, weak) UILabel *daiban;

@property (nonatomic, strong) UIView *rightView;
@property (nonatomic, strong) NTCalendarScrollView *calendarScrollView;
@property (nonatomic, strong) UIView *weekView;

@end

@implementation NTCalendar

- (instancetype)initWithFrame:(CGRect)frame{
    self = [super initWithFrame:frame];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(changeCalendarLeftDate:) name:@"NTCalendar.ChangeCalendarHeaderNotification" object:nil];
    [self setupBackground];
    [self setupLeftViews];
    [self setupRightViews];
    return self;
}

- (void)dealloc {
    [[NSNotificationCenter defaultCenter] removeObserver:self name:@"NTCalendar.ChangeCalendarHeaderNotification" object:nil];
}

- (void)setupBackground {
    UIImageView *bgImgView = [[UIImageView alloc] initWithFrame:self.bounds];
    bgImgView.contentMode = UIViewContentModeScaleToFill;
    NSString *imgPath = [[NSBundle mainBundle] pathForResource:@"NTCalendarBgImg" ofType:@"png"];
    bgImgView.image = [UIImage imageWithContentsOfFile:imgPath];
    [self addSubview:bgImgView];
}

- (void)setupLeftViews {
    self.leftView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, self.bounds.size.width*0.3, self.bounds.size.height)];
    [self addSubview:self.leftView];
    
    UIView *leftBox = [[UIView alloc] initWithFrame:CGRectMake(0, 0, self.leftView.bounds.size.width*0.8, self.leftView.bounds.size.width*0.8)];
    leftBox.center = CGPointMake(self.leftView.center.x, self.leftView.center.y);
    leftBox.backgroundColor = [UIColor colorWithRed:17/255.0 green:129/255.0 blue:193/255.0 alpha:1.0];
    leftBox.layer.cornerRadius = self.leftView.bounds.size.width*0.75*0.5;
    leftBox.layer.masksToBounds = YES;
    
    UILabel *dayLabel = [[UILabel alloc] initWithFrame:CGRectMake(0, 12, leftBox.bounds.size.width, leftBox.bounds.size.height*0.5)];
    dayLabel.font = [UIFont fontWithName:@"Avenir-Heavy" size:44.0];
    dayLabel.textAlignment = NSTextAlignmentCenter;
    dayLabel.textColor = kMyWhiteColor;
    [leftBox addSubview:dayLabel];
    self.dayLabel = dayLabel;
    
    UILabel *monLabel = [[UILabel alloc] initWithFrame:CGRectMake(0, CGRectGetMaxY(dayLabel.frame), leftBox.bounds.size.width, 25)];
    monLabel.textAlignment = NSTextAlignmentCenter;
    monLabel.font = [UIFont fontWithName:@"Avenir-Heavy" size:18.0];
    monLabel.textColor = kMyWhiteColor;
    [leftBox addSubview:monLabel];
    self.monLabel = monLabel;
    
    UILabel *yearLabel = [[UILabel alloc] initWithFrame:CGRectMake(0, CGRectGetMinY(leftBox.frame)-30, self.leftView.bounds.size.width, 25)];
    yearLabel.textAlignment = NSTextAlignmentCenter;
    yearLabel.textColor = kMyWhiteColor;
    yearLabel.font = [UIFont fontWithName:@"Avenir-Heavy" size:19.0];
    yearLabel.text = @"1990";
    [self.leftView addSubview:yearLabel];
    self.yearLabel = yearLabel;
    
    UILabel *daiban = [[UILabel alloc] initWithFrame:CGRectMake(0, CGRectGetMaxY(leftBox.frame)+5, self.leftView.bounds.size.width, 25)];
    daiban.textAlignment = NSTextAlignmentCenter;
    daiban.textColor = kMyWhiteColor;
    daiban.font = [UIFont systemFontOfSize:12];
    daiban.text = [NSString stringWithFormat:@"待办事项(0)"];
    [self.leftView addSubview:daiban];
    self.daiban = daiban;
    
    [self.leftView addSubview:leftBox];
    
}

- (void)setupRightViews {
    self.rightView = [[UIView alloc] initWithFrame:CGRectMake(CGRectGetMaxX(self.leftView.frame)-2*kOffset, 0, self.bounds.size.width*0.7, self.bounds.size.height)];
    [self addSubview:self.rightView];
    
    self.weekView = [[UIView alloc] initWithFrame:CGRectMake(0, 10, self.rightView.bounds.size.width, kOneLine_H)];
    [self.rightView addSubview:self.weekView];
    NSArray *weeks = @[@"Sun",@"Mon",@"Tue",@"Wed",@"Thu",@"Fri",@"Sat"];
    for (int i=0; i<7; i++) {
        UILabel *weekLb = [[UILabel alloc] initWithFrame:CGRectMake(kCellWidth*i, 0, kCellWidth, kOneLine_H)];
        weekLb.textColor = [UIColor lightGrayColor];
        weekLb.adjustsFontSizeToFitWidth = YES;
        weekLb.textAlignment = NSTextAlignmentCenter;
        weekLb.font = [UIFont systemFontOfSize:12 weight:UIFontWeightMedium];
        weekLb.text = weeks[i];
        [self.weekView addSubview:weekLb];
    }
    
    [self.rightView addSubview:self.calendarScrollView];
}

- (NSArray *)monthArrayInEnglish{
    return @[@"JAN",@"FEB",@"MAR",@"APRI",@"MAY",@"JUNE",@"JULY",@"AUG",@"SEP",@"OCT",@"NOV",@"DEC"];
}

- (NTCalendarScrollView *)calendarScrollView{
    if (!_calendarScrollView) {
        NTCalendarScrollView *scrView = [[NTCalendarScrollView alloc] initWithFrame:CGRectMake(0, CGRectGetMaxY(self.weekView.frame), floorf(self.rightView.bounds.size.width), kOneLine_H*6)];
        // 选中日期的回调
        __weak typeof(self) wSelf = self;
        scrView.didSelectDayHandler = ^(NSInteger y, NSInteger m, NSInteger d) {
            wSelf.monLabel.text = [self monthArrayInEnglish][m-1];
            wSelf.dayLabel.text = [NSString stringWithFormat:@"%ld", d];
            wSelf.yearLabel.text = [NSString stringWithFormat:@"%ld", y];
            
            if (self.didSelectDateHandler) {
                self.didSelectDateHandler(y, m, d, self.daiban);
            }
        };
        _calendarScrollView = scrView;
    }
    return _calendarScrollView;
}


/**
 接收scrollerView的日期改变通知（非点击事件）

 @param noti 年月日字典
 */
- (void)changeCalendarLeftDate:(NSNotification *)noti{
    NSDictionary *dict = noti.userInfo;
    NSInteger day = [dict[@"day"] integerValue];
    NSInteger mon = [dict[@"month"] integerValue];
    NSInteger year = [dict[@"year"] integerValue];
    
    self.monLabel.text = [self monthArrayInEnglish][mon-1];
    self.dayLabel.text = [NSString stringWithFormat:@"%ld", day];
    self.yearLabel.text = [NSString stringWithFormat:@"%ld", year];
    
    if (self.didSelectDateHandler) {
        self.didSelectDateHandler(year, mon, day, self.daiban);
    }
}


/*
// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect {
    // Drawing code
}
*/

@end
