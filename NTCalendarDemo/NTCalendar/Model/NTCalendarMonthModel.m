

#import "NTCalendarMonthModel.h"
#import "NSDate+NTCalendar.h"

@interface NTCalendarMonthModel ()
@property (nonatomic, strong) NSDate *monthDate;
@end

@implementation NTCalendarMonthModel

- (instancetype)initWithDate:(NSDate *)date {
    if (self = [super init]) {
        _monthDate = date;
        _totalDays = [date totalDaysInMonth];
        _firstWeekday = [date firstWeekDayInMonth];
        _year = [date dateYear];
        _month = [date dateMonth];
        _day = [date dateDay];
    }
    return self;
}




@end
