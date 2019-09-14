

#import <UIKit/UIKit.h>

typedef void (^DidSelectDayHandler)(NSInteger, NSInteger, NSInteger);

@interface NTCalendarScrollView : UIScrollView
{
    NSInteger _seletedDay;//选中日
}
@property (nonatomic, copy) DidSelectDayHandler didSelectDayHandler;


/**
 刷新 calendar 回到当前日期月份
 */
- (void)refreshToCurrentMonth;


@end
