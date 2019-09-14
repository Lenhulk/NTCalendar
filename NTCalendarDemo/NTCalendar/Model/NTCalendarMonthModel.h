//
//  月份模型类
//

#import <Foundation/Foundation.h>

@interface NTCalendarMonthModel : NSObject

@property (nonatomic, assign) NSInteger totalDays; //!< 当前月的天数
@property (nonatomic, assign) NSInteger firstWeekday; //!< 标示第一天是星期几（0代表周日，1代表周一，以此类推）
@property (nonatomic, assign) NSInteger year; //!< 所属年份
@property (nonatomic, assign) NSInteger month; //!< 所属月份
@property (nonatomic, assign) NSInteger day;  //!< 所属日

- (instancetype)initWithDate:(NSDate *)date;


@end
