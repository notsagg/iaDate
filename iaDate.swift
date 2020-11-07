//
//  iaDate.swift
//
//
//  Crée par Gaston Pelletier le 29/04/20.
//

import UIKit

// MARK: - Enumerations
enum monthNumber: Int {
    case january = 1, february, march, april, may, june, july, august, september, october, november, december
}
enum weekDaysNumber: Int {
    case sunday = 1, monday, tuesday, wednesday, thursday, friday, saturday
}
enum CalendarFormat {
    case number // case for all date numbers and ia time stamp
    case text // case for all dates as `Date`s and dates as `String`s
}
enum CustomCalendarComponent {
    case fiveMinute, minute, hour, day, week, month, year, automatic
}

// MARK: - Structs
struct monthName {
    let date = DateFormatter()
    let component = NSDateComponents()

    init(locale: String = iaDate.Localization.english) {
        date.dateFormat = iaDate.DateFormatAsString.month // use full month format
        date.locale = NSLocale(localeIdentifier: locale) as Locale // set locale
    }
    func nameOf(month: Int) -> String {
        component.month = month
        return date.string(from: NSCalendar.current.date(from: component as DateComponents)!)
    }
}
struct weekDaysName {
    let date = DateFormatter()
    let component = NSDateComponents()

    init(locale: String = iaDate.Localization.english) {
        date.dateFormat = iaDate.DateFormatAsString.month // use full month format
        date.locale = NSLocale(localeIdentifier: locale) as Locale // set locale
    }
    private func nameOf(weekDay: Int) -> String {
        component.weekday = weekDay
        return date.string(from: NSCalendar.current.date(from: component as DateComponents)!)
    }
}

// MARK: - Classes
class iaDate {
    // MARK: Class attributes
    private var iaTimeStamp: Int? // IA time stamp (timestamp in five minutes starting from 1/1/2001)
    // MARK: - Initializer
    // ia time stamp corresponds to a multiplier of 5 minutes since 01-01-2001
    init(date: Date = Date()) {
        self.iaTimeStamp = toIATimeStampFrom(date: date)
    }
    init(iaTimeStamp: Int) {
        self.iaTimeStamp = iaTimeStamp
    }
    init(dateString: String) {
        let date = DateFormatter()
        date.dateFormat = iaTime.smallDateFormat
        // create date from handled string
        if let newDate = date.date(from: dateString) {
            self.iaTimeStamp = toIATimeStampFrom(date: newDate) // convert newDate to ia time stamp
        } else {
            precondition(false, "error: incorrect format for given date") // fail if newDate is nil
        }
    }
    private func getIAOriginDate() -> String {
        // 01-01-2001 corresponds to ia origin date
        return iaTime.originDate + " " + iaTime.originTime + " " + iaTime.originTimeZone
    }

    // MARK: - Getters
    /**
     Returns ia time stamp using specified format
     Available formats are: **.fiveMinute**, **.minute**, **.hour**, **.day**, **.week**, **.month**, and **.year**
     - parameter withFormat: The value used to format ia date
     - returns: ia date using format
     # Notes: #
     1. Parameters must be **CustomCalendarComponent** type
     2. Default format is **.fiveMinute** (if none is specified)
     # Example #
    ```
     let iadate =  iaDate()
     let iaDateInDays = iadate.getIATimeStamp(withFormat: .day)
     print(iaDateInDays)
     ```
    */
    func getIATimeStamp(withFormat: CustomCalendarComponent = .fiveMinute) -> Int {
        switch withFormat {
        // default case of groups of five minutes
        case .fiveMinute:
            return self.iaTimeStamp! // return number of 5 minutes since 01-01-2001
        // case of minutes
        case .minute:
            // ia time stamp * 5 = minutes
            return self.iaTimeStamp! * iaTime.everyFiveMinutes
        // case of hours
        case .hour:
            // minutes / 60 = hours
            return getIATimeStamp(withFormat: .minute) / Hour.numberOfMinutes
        // case of days
        case .day: // return number of days in ia time format
            // hours / 24 = days
            return getIATimeStamp(withFormat: .hour) / Day.numberOfHours
        // case of weeks
        case .week:
            // days / 7
            return getIATimeStamp(withFormat: .day) / Week.numberOfDays
        // case of months
        case .month:
            return Int(CGFloat(getIATimeStamp(withFormat: .day)) / Month.numberOfDays)
        // case of years
        case .year:
            return getIATimeStamp(withFormat: .month) / Year.numberOfMonths
        case .automatic:
            return getIATimeStamp(withFormat: .fiveMinute) // return default format style
        }
    }

    /**
     Returns ia time stamp as **Date**
     Conversion can be made manually be using **toDate(from:)** method
     - parameter withFormat: The value used to format ia date
     - returns: ia date in **Date** type
     # Example #
    ```
     let iadate =  iaDate()
     let iaDateAsDate = iadate.getIATimeStampAsDate()
     print(iaDateAsDate) // prints ia date as a `Date`
     ```
    */
    func getIATimeStampAsDate() -> Date {
        // get self.iaTimeStamp as Date
        return toDate(from: self.iaTimeStamp!) // convert ia time stamp to date
    }

    /**
     Returns ia time stamp as **Date** formatted using **style** and **locale** parameters
     Available formats are: **.none**, **.short**, **.medium**, **.long**, and **.full**
     - parameter style: **DateFormatter.Style** type style used to format output
     - parameter locale: Specify a locale (this is not mandatory)
     - returns: ia date as a **Date** formatted using **style**
     # Notes: #
     1. **style** is of type **DateFormatter.Style**
     2. **.none**: Specifies no style
     3. **.short**: Specifies a short style, typically numeric only, such as “11/23/37” or “3:30 PM”
     4. **.medium**: Specifies a medium style, typically with abbreviated text, such as “Nov 23, 1937” or “3:30:32 PM”
     5. **.long**: Specifies a long style, typically with full text, such as “November 23, 1937” or “3:30:32 PM PST”
     6. **.full**: Specifies a full style with complete details, such as “Tuesday, April 12, 1952 AD” or “3:30:42 PM Pacific Standard Time”
     7. Default locale is **en_US** (american english)
     # Example #
    ```
     let iadate =  iaDate()
     let iaDateAsDate = iadate.getDate(style: .full)
     print(iaDateAsDate) // prints ia date as a `Date` using `.full` as a format
     ```
    */
    func getDate(style: DateFormatter.Style, timeStyle: DateFormatter.Style = .none, locale: String = Localization.english) -> String {
        let dateFormatter = DateFormatter()
        dateFormatter.dateStyle = style // use handled style for date
        dateFormatter.timeStyle = timeStyle
        // set locale
        dateFormatter.locale = NSLocale(localeIdentifier: locale) as Locale
        return dateFormatter.string(from: getIATimeStampAsDate())
    }

    /**
     Returns ia time stamp as **Date** formatted using **customFormat** and **locale** parameters
     This method offers the most flexibility in formatting a date
     - parameter customFormat: Custom format string
     - parameter locale: Specify a locale (this is not mandatory)
     - returns: ia date formatted using custom format string
     - warning: **customFormat** must be compliant to unicode date format patterns.
                Please read [this](http://unicode.org/reports/tr35/tr35-6.html#Date_Format_Patterns)
                for more details.
     # Notes: #
     1. **customFormat** must be compliant to unicode date format patterns
     2. Check the following example to get you started
     7. Default locale is **en_US** (american english)
     # Example #
    ```
     // to get you started, use these:
     public struct DateFormatAsNumber {
         static let minute: String = "mm"
         static let hour: String = "HH"
         static let day: String = "dd"
         static let weekOfMonth: String = "WW"
         static let weekOfYear: String = "ww"
         static let month: String = "MM"
         static let year: String = "yyyy"
     }
     public struct DateFormatAsString {
         static let day: String = "EEEE"
         static let month: String = "MMMM"
     }
     /* */
     let iadate =  iaDate()
     let iaDateAsDate = iadate.getDate(style: "MM-dd-YYYY hh:mm")
     print(iaDateAsDate) // displays month-day-year hour:minute
     ```
    */
    func getDate(customFormat: String, locale: String = Localization.english) -> String {
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = customFormat // use handled custom style
        // set locale if given
        dateFormatter.locale = NSLocale(localeIdentifier: locale) as Locale
        return dateFormatter.string(from: getIATimeStampAsDate())
    }

    /**
     Returns extracted unit from ia time stamp as **Date**, as a **String?**
     This method uses custom date formatter strings to extract identified unit from ia time stamp as **Date**
     - parameter date: is of type **Calendar.Component**
     - parameter format: dictates whether the method should return extract information as a number or as a text.
                        For example, 02 or "February".
     - returns: extracted information from ia time stamp as **Date**, as an optional string
     # Notes: #
     1. **date** is of type **Calendar.Component**
     2.  **.hour**: Identifier for the hour unit
     3. **.day**: Identifier for the day unit
     4. **.weekOfMonth**: Identifier for the week of the month calendar unit
     5. **.weekOfYear**: Identifier for the week of the year unit
     6. **.month**: Identifier for the month unit
     7. **.year**: Identifier for the year unit
     # Example #
    ```
     let iadate =  iaDate()
     let iaDateAsDate = iadate.get(date: .hour)
     print(iaDateAsDate!) // prints `hour` unit of date
     ```
    */
    func get(date: Calendar.Component, format: CalendarFormat = .number) -> String? {
        var displayStyle: String?
        switch date {
        case .hour:
            return getDate(customFormat: DateFormatAsNumber.hour)
        case .day:
            if format == .number { displayStyle = DateFormatAsNumber.day }
            else { displayStyle = DateFormatAsString.day }
            return getDate(customFormat: displayStyle!)
        case .weekOfMonth:
            return getDate(customFormat: DateFormatAsNumber.weekOfMonth)
        case .weekOfYear:
            return getDate(customFormat: DateFormatAsNumber.weekOfYear)
        case .month:
            if format == .number { displayStyle = DateFormatAsNumber.month }
            else { displayStyle = DateFormatAsString.month }
            return getDate(customFormat: displayStyle!)
        case .year:
            return getDate(customFormat: DateFormatAsNumber.year)
        default: return nil
        }
    }

    // return date in the future
    func getNext(component: Calendar.Component, format: CalendarFormat = .number) -> String? {
        switch component {
        // case of hours
        case .hour:
             // return current ia time + 60 minutes
            return String(self.iaTimeStamp! + Hour.numberOfFiveMinutes)
        // case of days
        case .day:
            // return current ia time + 288 minutes
            return String(self.iaTimeStamp! + (Day.numberOfMinutes / iaTime.everyFiveMinutes))
        // case of weeks
        case .weekOfMonth:
            return String(self.iaTimeStamp! + (Day.numberOfMinutes / iaTime.everyFiveMinutes * Week.numberOfDays))

        // case of week of year, months, and years
        case .weekOfYear, .month, .year:
            let date = getIATimeStampAsDate()
            let newDate = Calendar.current.date(byAdding: component, value: 1, to: date)
            let componentDateNumber = Calendar.current.component(component, from: newDate!)

            if component == .month && format == .text {
                return monthName().nameOf(month: componentDateNumber)
            }
            return String(componentDateNumber)

        // defautl case where a none supported component is handled
        default:
            print("Calendar.Component.\(component) is not yet supported")
            return nil
        }
    }
    
    // MARK: - Setters
    func setToBeginningOfDay() { // set ia time to the beginning of the day
        
    }
    func setToEndOfDay() { // set ia time to the end of the day
        
    }
    
    // MARK: - Incrementers
    // add minutes, days, months or years to IA time
    func add(fiveMinutes: Int) { // add `minutes` to IA time
        self.iaTimeStamp! += fiveMinutes
    }
    func add(hours: Int) { // add `hours` to IA time
        self.iaTimeStamp! += (hours * Hour.numberOfFiveMinutes) // add hours * 12 (hours * (60 / 5 minutes))
    }
    func add(days: Int) { // add `days` to IA time
        self.iaTimeStamp! += (days * Day.numberOfFiveMinutes) // add days * 288 (days * (1440 / 5 minutes))
    }
    func add(weeks: Int) { // add `weeks` to IA time
        self.iaTimeStamp! += (weeks * Week.numberOfDays * Day.numberOfFiveMinutes) // add weeks * 7 * 288
    }
    func add(months: Int) { // add `months` to IA time
        
    }
    func add(years: Int) { // add `years` to IA time
        
    }
    
    // MARK: - Conversions
    func toDate(from iaTimeStamp: Int) -> Date { // return ia time stamp as date
        let timeReferenceAsDate = Date(timeIntervalSince1970: Date.timeIntervalBetween1970AndReferenceDate)
        let timeStampAsDate = TimeInterval(iaTimeStamp * iaTime.everyFiveMinutes * Minute.numberOfSeconds)
        return timeReferenceAsDate + timeStampAsDate
    }
    // return time in 5 minutes in between 01-01-2001 and `_date`
    func toIATimeStampFrom(date: Date) -> Int {
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = iaTime.dateFormat
        // get date from 01-01-2001
        let originDate = dateFormatter.date(from: getIAOriginDate())
        return Int(date.timeIntervalSince(originDate!)) / Hour.numberOfFiveMinutes
    }
    func toIAFrom(unix: Int) -> Int { // convert UNIX time to ia time
        // from unix to ia in seconds
        let iaInSeconds = unix - Int(Date.timeIntervalBetween1970AndReferenceDate)
        // from ia in seconds to ia time stamp
        return iaInSeconds / Hour.numberOfFiveMinutes
    }
    func toUnixFrom(ia: Int) -> Int { // convert ia time to UNIX time
        // convert ia to seconds
        let iaInSeconds = ia * iaTime.everyFiveMinutes * Hour.numberOfMinutes
        // add time between 01-01-1970 and 01-01-2001 to ia in seconds
        return Int(Date.timeIntervalBetween1970AndReferenceDate) + iaInSeconds
    }
    func toUnixFromIA() -> Int {
        return toUnixFrom(ia: getIATimeStamp())
    }
    // return relative ia time using `style` date format
    func relativeIATime(from iaTimeStamp: Int, style: CustomCalendarComponent = .automatic) -> String {
        switch style {
        // return relative ia time using automatic date format
        case .automatic:
            if iaTimeStamp >= Hour.numberOfFiveMinutes {
                if iaTimeStamp >= Day.numberOfFiveMinutes {
                    if iaTimeStamp >= Week.numberOfFiveMinutes {
                        if iaTimeStamp >= Month.numberOfFiveMinutes {
                            if iaTimeStamp >= Year.numberOfFiveMinutes {
                                return relativeIATime(from: iaTimeStamp, style: .year)
                            } else {
                                return relativeIATime(from: iaTimeStamp, style: .month)
                            }
                        } else {
                            return relativeIATime(from: iaTimeStamp, style: .week)
                        }
                    } else {
                        return relativeIATime(from: iaTimeStamp, style: .day)
                    }
                } else {
                    return relativeIATime(from: iaTimeStamp, style: .hour)
                }
            } else {
                return relativeIATime(from: iaTimeStamp, style: .minute)
            }

        // all other cases
        case .fiveMinute:
            return String(iaTimeStamp) + " five minutes"
        case .minute:
            return String(iaTimeStamp * iaTime.everyFiveMinutes) + " minutes"
        case .hour:
            return String(iaTimeStamp / Hour.numberOfFiveMinutes) + " hours"
        case .day:
            return String(iaTimeStamp / Day.numberOfFiveMinutes) + " days"
        case .week:
            return String(iaTimeStamp / Week.numberOfFiveMinutes) + " weeks"
        case .month:
            return String(iaTimeStamp / Month.numberOfFiveMinutes) + " months"
        case .year:
            return String(iaTimeStamp / Year.numberOfFiveMinutes) + " years"
        }
    }

    // MARK: - Comparators
    // TODO: Make those three work
    func isSameDay(as compare: iaDate) -> Bool {
        if let timeStamp = iaTimeStamp {
            if let compareTime = compare.iaTimeStamp {
                return (timeStamp/Day.numberOfFiveMinutes) == compareTime/Day.numberOfFiveMinutes
            }
        }
        return false
    }
    func timeUntil(date: Date, style: CustomCalendarComponent = .automatic) -> String {
        // convert iaTimeStamp to Date
        let iaAsDate = getIATimeStampAsDate()
        return timeBetween(iaAsDate, and: date, style: style)
    }
    func timeBetween(_ date1: Date, and date2: Date, style: CustomCalendarComponent = .automatic) -> String {
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = iaTime.dateFormat

        // if date > iaTimeStamp as Date
        var newDate: TimeInterval?
        if date2 > date1 {
            newDate = date2 - date1 // then substract iaTimStamp as Date from `date`
        } else {
            newDate = date1 - date2 // else do the opposite
        }

        // convert resulting date back to ia time stamp
        let relativeDate = dateFormatter.date(from: getIAOriginDate())! + newDate!
        let relativeIA = toIATimeStampFrom(date: relativeDate)
        // return relativeIATime(from: ia)
        return relativeIATime(from: relativeIA, style: style)
    }
    func whenIs(date: Date) {
        // return relative date by reference to self.iaTimeStamp
        
    }
}

// MARK: - Extension
extension iaDate {
    // MARK: IA Time Stamp
    private struct iaTime {
        static let originDate: String = "01-01-2001" // January 1, 2001
        static let originTime: String = "00:00" // at midnight
        static let originTimeZone: String = "GMT" // timezone
        static let dateFormat: String = "dd-MM-yyyy HH:mm zzz" // date format
        static let smallDateFormat: String = "dd-MM-yyyy" // small date format
        static let everyFiveMinutes: Int = 5 // make groups of 5 minutes
    }
    // MARK: Year
    private struct Year {
        static let numberOfDays: CGFloat = 365.25 // number of days in a year
        static let numberOfMonths: Int = 12 // there are 12 months in a single year
        static let daysInFourYears: Int = 1461 // 1 year = 365.25 days --> 4 years = 1461 days
        // 103680 fiveMinutes in a year
        static let numberOfFiveMinutes: Int = Year.numberOfMonths * Month.numberOfFiveMinutes
        
        struct Filter {
            static let firstYear: Int = .zero // first year
            static let yearLength: Int = 4 // four digits in a year
        }
    }
    // MARK: Month
    private struct Month {
        static let numberOfDays: CGFloat = 30.4375 // in average there are 365.25/12 days in a month
        // 8640 fiveMinutes in a month
        static let numberOfFiveMinutes: Int = Int(Month.numberOfDays * CGFloat(Day.numberOfFiveMinutes))
    }
    private struct Week {
        static let numberOfDays: Int = 7 // seven days in a week
        // 2016 fiveMinutes in a week
        static let numberOfFiveMinutes: Int = Week.numberOfDays * Day.numberOfFiveMinutes
    }
    // MARK: Day
    private struct Day  {
        static let numberOfMinutes: Int = 1440 // number of minutes in a single day
        static let numberOfHours: Int = 24 // number of hours in a single day
        // 288 fiveMinutes in a day
        static let numberOfFiveMinutes: Int = Day.numberOfHours * Hour.numberOfFiveMinutes
    }
    // MARK: Hour
    private struct Hour {
        static let numberOfMinutes: Int = 60 // number of minutes in a single hour
        static let numberOfSeconds: Int = 3600 // number of seconds in a single hour
        // 12 fiveMinutes in an hour
        static let numberOfFiveMinutes: Int = Hour.numberOfMinutes / iaTime.everyFiveMinutes
    }
    // MARK: Minutes
    private struct Minute {
        static let numberOfSeconds: Int = Hour.numberOfMinutes // number of minutes in a single minute
    }
    // MARK: Date Formater
    public struct DateFormatAsNumber {
        static let minute: String = "mm"
        static let hour: String = "HH"
        static let day: String = "dd"
        static let weekOfMonth: String = "WW"
        static let weekOfYear: String = "ww"
        static let month: String = "MM"
        static let year: String = "yyyy"
    }
    public struct DateFormatAsString {
        static let day: String = "EEEE"
        static let month: String = "MMMM"
    }
    // MARK: Localization
    public struct Localization {
        static let english: String = "en_US" // default localization is US english
    }
}
extension Date {
    static func -(lhs: Date, rhs: Date) -> TimeInterval {
        return lhs.timeIntervalSinceReferenceDate - rhs.timeIntervalSinceReferenceDate
    }
    static func +(lhs: Date, rhs: Date) -> TimeInterval {
        return lhs.timeIntervalSinceReferenceDate + rhs.timeIntervalSinceReferenceDate
    }
}

/*
 Todo:
 1. Calcule le nombre de jour restant avant une date puis indique une heure en se rapprochant de ce jour
 2. Calcule le nombre de jour entre deux dates
 3. Calcule le nombre d’heures/minutes entre deux dates
 4. Calculer si une date est au jour prochain, à la semaine prochaine, au mois prochain ou à l'année prochaine par rapport à la date actuelle
 */
