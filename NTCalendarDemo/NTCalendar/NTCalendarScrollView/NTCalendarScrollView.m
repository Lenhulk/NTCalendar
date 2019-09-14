

#import "NTCalendarScrollView.h"
#import "NTCalendarCell.h"
#import "NTCalendarMonthModel.h"
#import "NSDate+NTCalendar.h"

#define kNTCellNibName NSStringFromClass([NTCalendarCell class])
#define kNTCellNib [UINib nibWithNibName:kNTCellNibName bundle:nil]

@interface NTCalendarScrollView () <UICollectionViewDataSource, UICollectionViewDelegate>
//上个月日历
@property (nonatomic, strong) UICollectionView *collectionViewL;
//当前月日历
@property (nonatomic, strong) UICollectionView *collectionViewM;
//下个月日历
@property (nonatomic, strong) UICollectionView *collectionViewR;
//当前日期
@property (nonatomic, strong) NSDate *currentMonthDate;

@property (nonatomic, strong) NSMutableArray *monthArray;
//选中遮罩
@property (nonatomic, strong) UIView *currentDayHud;

@end

@implementation NTCalendarScrollView


#pragma mark - Lazy Load
- (UIView *)currentDayHud{
    if (!_currentDayHud) {
        _currentDayHud = [[UIView alloc] initWithFrame:CGRectMake(0, 0, 28, 28)];
        _currentDayHud.layer.cornerRadius = 13;
        _currentDayHud.layer.backgroundColor = [UIColor colorWithRed:253/255.0 green:76/255.0 blue:126/255.0 alpha:0.5].CGColor;
        [self insertSubview:_currentDayHud atIndex:0];
    }
    return _currentDayHud;
}

- (NSMutableArray *)monthArray {
    if (_monthArray == nil) {
        _monthArray = [NSMutableArray arrayWithCapacity:4];
        
        NSDate *previousMonthDate = [_currentMonthDate previousMonthDate];
        NSDate *nextMonthDate = [_currentMonthDate nextMonthDate];
        
        [_monthArray addObject:[[NTCalendarMonthModel alloc] initWithDate:previousMonthDate]];
        [_monthArray addObject:[[NTCalendarMonthModel alloc] initWithDate:_currentMonthDate]];
        [_monthArray addObject:[[NTCalendarMonthModel alloc] initWithDate:nextMonthDate]];
        [_monthArray addObject:[self previousMonthDaysForPreviousDate:previousMonthDate]]; // 存储左边的月份的前一个月份的天数，用来填充左边月份的首部
        
        // 发通知，更改当前月份标题
        [self notifyToChangeCalendarHeader];
    }
    
    return _monthArray;
}

- (NSNumber *)previousMonthDaysForPreviousDate:(NSDate *)date {
    return [[NSNumber alloc] initWithInteger:[[date previousMonthDate] totalDaysInMonth]];
}


#pragma mark - Initialiaztion
- (instancetype)initWithFrame:(CGRect)frame {
    if ([super initWithFrame:frame]) {
        
        self.backgroundColor = [UIColor clearColor];
        self.showsHorizontalScrollIndicator = NO;
        self.showsVerticalScrollIndicator = NO;
        self.pagingEnabled = YES;
        self.bounces = NO;
        self.delegate = self;
        
        self.contentSize = CGSizeMake(3 * self.bounds.size.width, self.bounds.size.height);
        [self setContentOffset:CGPointMake(self.bounds.size.width, 0.0) animated:NO];
        
        _currentMonthDate = [NSDate date];
        _seletedDay = [[NSDate date] dateDay];
        [self setupCollectionViews];
        
    }
    return self;
}

- (void)setupCollectionViews {
    
    UICollectionViewFlowLayout *flowLayout = [[UICollectionViewFlowLayout alloc] init];
    flowLayout.itemSize = CGSizeMake(self.bounds.size.width / 7.0, self.bounds.size.height / 6.0);
    flowLayout.minimumLineSpacing = 0.0;
    flowLayout.minimumInteritemSpacing = 0.0;
    
    CGFloat selfWidth = self.bounds.size.width;
    CGFloat selfHeight = self.bounds.size.height;
    
    _collectionViewL = [[UICollectionView alloc] initWithFrame:CGRectMake(0.0, 0.0, selfWidth, selfHeight) collectionViewLayout:flowLayout];
    _collectionViewL.dataSource = self;
    _collectionViewL.delegate = self;
    _collectionViewL.backgroundColor = [UIColor clearColor];
    [_collectionViewL registerNib:kNTCellNib forCellWithReuseIdentifier:kNTCellNibName];
    [self addSubview:_collectionViewL];
    
    _collectionViewM = [[UICollectionView alloc] initWithFrame:CGRectMake(selfWidth, 0.0, selfWidth, selfHeight) collectionViewLayout:flowLayout];
    _collectionViewM.dataSource = self;
    _collectionViewM.delegate = self;
    _collectionViewM.backgroundColor = [UIColor clearColor];
    [_collectionViewM registerNib:kNTCellNib forCellWithReuseIdentifier:kNTCellNibName];
    [self addSubview:_collectionViewM];
    
    _collectionViewR = [[UICollectionView alloc] initWithFrame:CGRectMake(2 * selfWidth, 0.0, selfWidth, selfHeight) collectionViewLayout:flowLayout];
    _collectionViewR.dataSource = self;
    _collectionViewR.delegate = self;
    _collectionViewR.backgroundColor = [UIColor clearColor];
    [_collectionViewR registerNib:kNTCellNib forCellWithReuseIdentifier:kNTCellNibName];
    [self addSubview:_collectionViewR];
    
    [_collectionViewL reloadData];
    [_collectionViewM reloadData];
    [_collectionViewR reloadData];
}


#pragma mark - Private Func
/**
 日期切换发送通知
 */
- (void)notifyToChangeCalendarHeader {
    
    NTCalendarMonthModel *currentMonthInfo = self.monthArray[1];
    
    NSMutableDictionary *userInfo = [NSMutableDictionary dictionaryWithCapacity:3];
    
    [userInfo setObject:[[NSNumber alloc] initWithInteger:currentMonthInfo.year] forKey:@"year"];
    [userInfo setObject:[[NSNumber alloc] initWithInteger:currentMonthInfo.month] forKey:@"month"];
    [userInfo setObject:[[NSNumber alloc] initWithInteger:_seletedDay] forKey:@"day"];
    
    NSNotification *notify = [[NSNotification alloc] initWithName:@"NTCalendar.ChangeCalendarHeaderNotification" object:nil userInfo:userInfo];
    [[NSNotificationCenter defaultCenter] postNotification:notify];
}

/**
 回到当前
 */
- (void)refreshToCurrentMonth {
    
    NTCalendarMonthModel *currentMonthInfo = self.monthArray[1];
    if ((currentMonthInfo.month == [[NSDate date] dateMonth]) && (currentMonthInfo.year == [[NSDate date] dateYear])) {
        return;
    }
    
    _currentMonthDate = [NSDate date];
    
    NSDate *previousMonthDate = [_currentMonthDate previousMonthDate];
    NSDate *nextMonthDate = [_currentMonthDate nextMonthDate];
    
    [self.monthArray removeAllObjects];
    [self.monthArray addObject:[[NTCalendarMonthModel alloc] initWithDate:previousMonthDate]];
    [self.monthArray addObject:[[NTCalendarMonthModel alloc] initWithDate:_currentMonthDate]];
    [self.monthArray addObject:[[NTCalendarMonthModel alloc] initWithDate:nextMonthDate]];
    [self.monthArray addObject:[self previousMonthDaysForPreviousDate:previousMonthDate]];
    
    // 刷新数据
    [_collectionViewM reloadData];
    [_collectionViewL reloadData];
    [_collectionViewR reloadData];
    
}


#pragma mark - UICollectionDataSource
- (NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section {
    return 42; // 7 * 6
}

- (__kindof UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath {
    
    NTCalendarCell *cell = [collectionView dequeueReusableCellWithReuseIdentifier:kNTCellNibName forIndexPath:indexPath];
    
    if (collectionView == _collectionViewL) {
        
        NTCalendarMonthModel *monthInfo = self.monthArray[0];
        NSInteger firstWeekday = monthInfo.firstWeekday;
        NSInteger totalDays = monthInfo.totalDays;
        
        // 当前月
        if (indexPath.row >= firstWeekday && indexPath.row < firstWeekday + totalDays) {
            cell.textLb.text = [NSString stringWithFormat:@"%ld", indexPath.row - firstWeekday + 1];
            cell.cellType = NTDateCellTypeNormalDay;
            
            // 标识今天
            if ((monthInfo.month == [[NSDate date] dateMonth]) && (monthInfo.year == [[NSDate date] dateYear])) {
                if (indexPath.row == [[NSDate date] dateDay] + firstWeekday - 1) {
                    cell.cellType = NTDateCellTypeSelctedDay;
                }
            }
            
        }
        // 补上前后月的日期，淡色显示
        else if (indexPath.row < firstWeekday) {
            int totalDaysOflastMonth = [self.monthArray[3] intValue];
            cell.textLb.text = [NSString stringWithFormat:@"%ld", totalDaysOflastMonth - (firstWeekday - indexPath.row) + 1];
            cell.cellType = NTDateCellTypeOtherMonsDay;
        } else if (indexPath.row >= firstWeekday + totalDays) {
            cell.textLb.text = [NSString stringWithFormat:@"%ld", indexPath.row - firstWeekday - totalDays + 1];
            cell.cellType = NTDateCellTypeOtherMonsDay;
        }
        
        cell.userInteractionEnabled = NO;
        
    }
    else if (collectionView == _collectionViewM) {
        
        NTCalendarMonthModel *monthInfo = self.monthArray[1];
        NSInteger firstWeekday = monthInfo.firstWeekday;
        NSInteger totalDays = monthInfo.totalDays;
        
        // 当前月
        if (indexPath.row >= firstWeekday && indexPath.row < firstWeekday + totalDays) {
            cell.textLb.text = [NSString stringWithFormat:@"%ld", indexPath.row - firstWeekday + 1];
            cell.cellType = NTDateCellTypeNormalDay;
            cell.userInteractionEnabled = YES;
            
            // 标识今天
            if ((monthInfo.month == [[NSDate date] dateMonth]) && (monthInfo.year == [[NSDate date] dateYear])) {
                if (indexPath.row == [[NSDate date] dateDay] + firstWeekday - 1) {
                    cell.cellType = NTDateCellTypeSelctedDay;
                    [UIView animateWithDuration:0.3 animations:^{
                        self.currentDayHud.center = CGPointMake(self.bounds.size.width+cell.center.x, cell.center.y);
                    }];
                }
            }
            
        }
        // 补上前后月的日期，淡色显示
        else if (indexPath.row < firstWeekday) {
            NTCalendarMonthModel *lastMonthInfo = self.monthArray[0];
            NSInteger totalDaysOflastMonth = lastMonthInfo.totalDays;
            cell.textLb.text = [NSString stringWithFormat:@"%ld", totalDaysOflastMonth - (firstWeekday - indexPath.row) + 1];
            cell.cellType = NTDateCellTypeOtherMonsDay;
            cell.userInteractionEnabled = NO;
        } else if (indexPath.row >= firstWeekday + totalDays) {
            cell.textLb.text = [NSString stringWithFormat:@"%ld", indexPath.row - firstWeekday - totalDays + 1];
            cell.cellType = NTDateCellTypeOtherMonsDay;
            cell.userInteractionEnabled = NO;
        }
        
    }
    else if (collectionView == _collectionViewR) {
        
        NTCalendarMonthModel *monthInfo = self.monthArray[2];
        NSInteger firstWeekday = monthInfo.firstWeekday;
        NSInteger totalDays = monthInfo.totalDays;
        
        // 当前月
        if (indexPath.row >= firstWeekday && indexPath.row < firstWeekday + totalDays) {
            
            cell.textLb.text = [NSString stringWithFormat:@"%ld", indexPath.row - firstWeekday + 1];
            cell.cellType = NTDateCellTypeNormalDay;
            
            // 标识今天
            if ((monthInfo.month == [[NSDate date] dateMonth]) && (monthInfo.year == [[NSDate date] dateYear])) {
                if (indexPath.row == [[NSDate date] dateDay] + firstWeekday - 1) {
                    cell.cellType = NTDateCellTypeSelctedDay;
                }
            }
            
        }
        // 补上前后月的日期，淡色显示
        else if (indexPath.row < firstWeekday) {
            NTCalendarMonthModel *lastMonthInfo = self.monthArray[1];
            NSInteger totalDaysOflastMonth = lastMonthInfo.totalDays;
            cell.textLb.text = [NSString stringWithFormat:@"%ld", totalDaysOflastMonth - (firstWeekday - indexPath.row) + 1];
            cell.cellType = NTDateCellTypeOtherMonsDay;
        } else if (indexPath.row >= firstWeekday + totalDays) {
            cell.textLb.text = [NSString stringWithFormat:@"%ld", indexPath.row - firstWeekday - totalDays + 1];
            cell.cellType = NTDateCellTypeOtherMonsDay;
        }
        
        cell.userInteractionEnabled = NO;
        
    }
    
    return cell;
    
}


#pragma mark - UICollectionViewDeleagate

- (void)collectionView:(UICollectionView *)collectionView didSelectItemAtIndexPath:(NSIndexPath *)indexPath {

    if (self.didSelectDayHandler != nil) {
        
        NSCalendar *calendar = [NSCalendar currentCalendar];
        NSDateComponents *components = [calendar components:(NSCalendarUnitYear | NSCalendarUnitMonth) fromDate:_currentMonthDate];
        NSDate *currentDate = [calendar dateFromComponents:components];
        
        NTCalendarCell *cell = (NTCalendarCell *)[collectionView cellForItemAtIndexPath:indexPath];
        [UIView animateWithDuration:0.3 animations:^{
            self.currentDayHud.center = CGPointMake(self.bounds.size.width+cell.center.x, cell.center.y);
        }];
        
        NSInteger year = [currentDate dateYear];
        NSInteger month = [currentDate dateMonth];
        NSInteger day = [cell.textLb.text integerValue];
        
        _seletedDay = day;
        self.didSelectDayHandler(year, month, day);
    }
    
}

#pragma mark - UIScrollViewDelegate

- (void)scrollViewDidEndDecelerating:(UIScrollView *)scrollView {
    if (scrollView != self) {
        return;
    }
    [self scrollAndResetCalendars:scrollView];
    [self notifyToChangeCalendarHeader];
//    [self judgeAndSendNotice];

}

- (void)scrollViewDidEndScrollingAnimation:(UIScrollView *)scrollView{
    if (scrollView != self) {
        return;
    }
    [self scrollAndResetCalendars:scrollView];

}

- (void)scrollAndResetCalendars:(UIScrollView *)scrollView{
    // 向右滑动
    if (scrollView.contentOffset.x < self.bounds.size.width) {
        
        _currentMonthDate = [_currentMonthDate previousMonthDate];
        NSDate *previousDate = [_currentMonthDate previousMonthDate];
        
        // 数组中最左边的月份现在作为中间的月份，中间的作为右边的月份，新的左边的需要重新获取
        NTCalendarMonthModel *currentMothInfo = self.monthArray[0];
        NTCalendarMonthModel *nextMonthInfo = self.monthArray[1];
        
        
        NTCalendarMonthModel *olderNextMonthInfo = self.monthArray[2];
        
        // 复用 GFCalendarMonth 对象
        olderNextMonthInfo.totalDays = [previousDate totalDaysInMonth];
        olderNextMonthInfo.firstWeekday = [previousDate firstWeekDayInMonth];
        olderNextMonthInfo.year = [previousDate dateYear];
        olderNextMonthInfo.month = [previousDate dateMonth];
        NTCalendarMonthModel *previousMonthInfo = olderNextMonthInfo;
        
        NSNumber *prePreviousMonthDays = [self previousMonthDaysForPreviousDate:[_currentMonthDate previousMonthDate]];
        
        [self.monthArray removeAllObjects];
        [self.monthArray addObject:previousMonthInfo];
        [self.monthArray addObject:currentMothInfo];
        [self.monthArray addObject:nextMonthInfo];
        [self.monthArray addObject:prePreviousMonthDays];
        
    }
    // 向左滑动
    else if (scrollView.contentOffset.x > self.bounds.size.width) {
        
        _currentMonthDate = [_currentMonthDate nextMonthDate];
        NSDate *nextDate = [_currentMonthDate nextMonthDate];
        
        // 数组中最右边的月份现在作为中间的月份，中间的作为左边的月份，新的右边的需要重新获取
        NTCalendarMonthModel *previousMonthInfo = self.monthArray[1];
        NTCalendarMonthModel *currentMothInfo = self.monthArray[2];
        
        
        NTCalendarMonthModel *olderPreviousMonthInfo = self.monthArray[0];
        
        NSNumber *prePreviousMonthDays = [[NSNumber alloc] initWithInteger:olderPreviousMonthInfo.totalDays]; // 先保存 olderPreviousMonthInfo 的月天数
        
        // 复用 GFCalendarMonth 对象
        olderPreviousMonthInfo.totalDays = [nextDate totalDaysInMonth];
        olderPreviousMonthInfo.firstWeekday = [nextDate firstWeekDayInMonth];
        olderPreviousMonthInfo.year = [nextDate dateYear];
        olderPreviousMonthInfo.month = [nextDate dateMonth];
        NTCalendarMonthModel *nextMonthInfo = olderPreviousMonthInfo;
        
        
        [self.monthArray removeAllObjects];
        [self.monthArray addObject:previousMonthInfo];
        [self.monthArray addObject:currentMothInfo];
        [self.monthArray addObject:nextMonthInfo];
        [self.monthArray addObject:prePreviousMonthDays];
        
    }
    
    
    [_collectionViewM reloadData]; // 中间的 collectionView 先刷新数据
    [scrollView setContentOffset:CGPointMake(self.bounds.size.width, 0.0) animated:NO]; // 然后变换位置
    [_collectionViewL reloadData]; // 最后两边的 collectionView 也刷新数据
    [_collectionViewR reloadData];
    
    
    // 移动HUD
    NTCalendarMonthModel *monthInfo = self.monthArray[1];
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(0.2 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
        for (NSInteger i=monthInfo.firstWeekday; i<monthInfo.totalDays; i++) {
            NTCalendarCell *cell = (NTCalendarCell *)[self->_collectionViewM cellForItemAtIndexPath:[NSIndexPath indexPathForRow:i inSection:0]];
            if (cell.textLb.text.integerValue == self->_seletedDay){
                [UIView animateWithDuration:0.3 animations:^{
                    self.currentDayHud.center = CGPointMake(self.bounds.size.width+cell.center.x, cell.center.y);

                }];
            }
        }
    });
}


// 移动HUD的位置到对应的日期
//- (void)judgeAndSendNotice{
//
//    //超出月份，给提示
//    NTCalendarMonthModel *monthInfo = self.monthArray[1];
//    if (monthInfo.month > [[NSDate date] dateMonth] || monthInfo.year > [[NSDate date] dateYear]) {
//        [self setContentOffset:CGPointZero animated:YES];
//        NSLog(@"你已滚动到数据的边缘啦");
//        return ;
//    }
//
//    //发通知，更改当前月份和日期
//    [self notifyToChangeCalendarHeader];
//}


@end
