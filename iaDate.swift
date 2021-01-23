//
//  iaDate.swift
//
//
//  Crée par Gaston Pelletier le 29/04/20.
//

import UIKit
import Foundation

// MARK: - Enumerations
enum MonthNumber: Int, CaseIterable {
    case january = 1, february, march, april, may, june, july, august, september, october, november, december
}
enum WeekDaysNumber: Int, CaseIterable {
    case sunday = 1, monday, tuesday, wednesday, thursday, friday, saturday
}
enum WeeksInMonth: Int, CaseIterable {
    case first = 1, second, third, fourth // first, second, third, and fourth week in month
}
enum CalendarFormat: CaseIterable {
    case number // case for all date numbers and ia time stamp
    case text // case for all dates as `Date`s and dates as `String`s
}
enum CustomCalendarComponent: CaseIterable {
    case fiveMinute, minute, hour, day, week, month, year, automatic
}
enum IADateTypes: CaseIterable {
    case iaTimeStamp, date, unixTimeStamp
}
enum UnixTimeFormat {
	case seconds, milliseconds, microseconds, nanoseconds
}

// MARK: - Structs
struct MonthName {
    let date = DateFormatter()
    let component = NSDateComponents()

    init(locale: String = iaDate.Localization.english) {
        date.dateFormat = DateFormat.AsString.month // use full month format
        date.locale = NSLocale(localeIdentifier: locale) as Locale // set locale
    }
    func nameOf(month: Int) -> String {
        component.month = month
        return date.string(from: NSCalendar.current.date(from: component as DateComponents)!)
    }
}
struct WeekDaysName {
    let date = DateFormatter()
    let component = NSDateComponents()

    init(locale: String = iaDate.Localization.english) {
        date.dateFormat = DateFormat.AsString.month // use full month format
        date.locale = NSLocale(localeIdentifier: locale) as Locale // set locale
    }
    private func nameOf(weekDay: Int) -> String {
        component.weekday = weekDay
        return date.string(from: NSCalendar.current.date(from: component as DateComponents)!)
    }
}
// MARK: Date Formatter
struct DateFormat {
    public struct AsNumber {
        static let minute: String = "mm"
        static let hour: String = "HH"
        static let day: String = "dd"
        static let weekOfMonth: String = "WW"
        static let weekOfYear: String = "ww"
        static let month: String = "MM"
        static let year: String = "yyyy"
    }
    public struct AsString {
        static let day: String = "EEEE"
        static let month: String = "MMMM"
    }

    static func getDateFormat(component: Calendar.Component,
                              format: CalendarFormat) -> (format: String, identical: Bool)? {
        switch component {
        case .minute:
            return (format: AsNumber.minute, identical: true)
        case .hour:
            return (format: AsNumber.hour, identical: true)
        case .day:
            if format == .number { return (AsNumber.day, false) }
            else if format == .text { return (AsString.day, false) }
        case .weekOfMonth:
            return (format: AsNumber.weekOfMonth, identical: true)
        case .weekOfYear:
            return (format: AsNumber.weekOfYear, identical: true)
        case .month:
            if format == .number { return (AsNumber.month, false) }
            else if format == .text { return (AsString.month, false) }
        case .year:
            return (format: AsNumber.year, identical: true)
        default:
            print("Format \(component) has not yet been implemented")
            return nil
        }
        return nil
    }
}
// MARK: Custom Relative Date Text
fileprivate struct CustomRelativeDate {
    // TODO: Localize all cases
    static var CustomRelativeDateBridge: [String: String] = [
        "minute": "m", "minutes": "m", // minute
        "hour": "H", "hours": "H", // hour
        "day": "D", "days": "D", // day
        "week": "W", "weeks": "W", // week
        "month": "M", "months": "M", // month
        "year": "Y", "years": "Y" // year
    ]

    static func getRelativeDateTextIndicator(text: String?) -> String? {
        guard text != nil else { return nil } // return nil if input is nil
        var customRelativeDateTextIndicator: String = ""
        let prefix = "in"
        let suffix = "ago"
        var componentOnly = text!

        // get two first characters and prepend negative sign
        if text!.prefix(prefix.count) == prefix { // "in ... ..."
            // remove prefix
            let range = text!.startIndex..<text!.index(text!.startIndex, offsetBy: prefix.count+1)
            componentOnly.removeSubrange(range)
        } else if text!.suffix(suffix.count) == suffix { // "... ... ago"
            // remove suffix
            let range = text!.index(text!.endIndex, offsetBy: -suffix.count-1)..<text!.endIndex
            componentOnly.removeSubrange(range)

            // add negative prefix to custom relative date
            customRelativeDateTextIndicator = "-"
        } else { return nil }

        guard componentOnly != "0 seconds" else {
            customRelativeDateTextIndicator = "now"
            return customRelativeDateTextIndicator
        }

        // create custom relative text indicator
        customRelativeDateTextIndicator += String(Int.parse(from: text!)!) // add value part from `text`
        componentOnly = String.parse(from: componentOnly)! // extract text only (discard value)
        // search in dictionnary using extracted component
        if let componentFromBridge = CustomRelativeDate.CustomRelativeDateBridge[componentOnly] {
            customRelativeDateTextIndicator += componentFromBridge // append corresponding custom component
        }

        return customRelativeDateTextIndicator
    }
}

// MARK: - Classes
class iaDate {
    // MARK: Class attributes
    var iaTimeStamp: Int? // IA time stamp (timestamp in five minutes starting from 1/1/2001)
    // MARK: - Initializer
    // ia time stamp corresponds to a multiplier of 5 minutes since 01-01-2001
    init(date: Date?) {
        self.iaTimeStamp = toIAFrom(date: date ?? Date())
    }
    init(iaTimeStamp: Int) {
        self.iaTimeStamp = iaTimeStamp
    }
	init(unixTimeStamp: Double, format: UnixTimeFormat = .seconds) {
		var expo: Double
		switch format {
		case .seconds: expo = 10e-1
		case .milliseconds: expo = 10e-4
		case .microseconds: expo = 10e-7
		case .nanoseconds: expo = 10e-10
		}
		iaTimeStamp = toIAFrom(unix: Int(unixTimeStamp*expo))
	}
	convenience init(unixTimeStamp: Int, format: UnixTimeFormat = .seconds) {
		self.init(unixTimeStamp: Double(unixTimeStamp), format: format)
	}
    init(_ id: Int32) {
        self.iaTimeStamp = Int(id)
    }
    init(dateString: String) {
        let date = DateFormatter()
        date.dateFormat = iaTime.smallDateFormat
        // create date from handled string
        if let newDate = date.date(from: dateString) {
            self.iaTimeStamp = toIAFrom(date: newDate) // convert newDate to ia time stamp
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
        case .fiveMinute, .automatic:
            return self.iaTimeStamp! // return number of 5 minutes since 01-01-2001 (default format)
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
            return Int(Double(getIATimeStamp(withFormat: .day)) / Month.numberOfDays)
        // case of years
        case .year:
            return getIATimeStamp(withFormat: .month) / Year.numberOfMonths
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
        return toDateFrom(ia: self.iaTimeStamp!) // convert ia time stamp to date
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
    func getDate(style: DateFormatter.Style, timeStyle: DateFormatter.Style = .none,
                 locale: String = Localization.english) -> String {
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
        dateFormatter.timeZone = TimeZone.init(secondsFromGMT: .zero)
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
        let numberFormatter = NumberFormatter() // number formatter
        if format == .number { numberFormatter.numberStyle = .none }
        else if format == .text { numberFormatter.numberStyle = .spellOut }
        guard let formatPattern = DateFormat.getDateFormat(component: date, format: format)?.format else {
            return nil
        }

        let value = getDate(customFormat: formatPattern)
        if format == .number {
            return value
        } else {
            guard Int(value) != nil else { return value }
            return numberFormatter.string(from: NSNumber(value: Int(value)!))
        }
    }

    /**
     Returns a date in the future
     This method takes a **Calendar.Component** as its first argument to return the
     next date corresponding to the given component.
     - parameter component: is of type **Calendar.Component**
     - parameter type: dictates whether the method should return an **iaTimeStamp**, a **Date**, or a **unixTimeStamp**
     - parameter format: dictates whether the method should return extract information as a number or as a text.
                         For example, 02 or "February".
     - returns: an optional date string
     # Notes: #
     1. Three **type**s are available, which means that the returned date can be of three
     different formats (**iaTimeStamp** (default), **Date**, or **unixTimeStamp**)
     2.  Two **format**s are available, which means that the returned date can be formatted as a number or as text.
     # Example #
     ```
     let iadate =  iaDate()
     /*
     This example returns the current date plus one hour
     */
     let nextHour = iadate.getNext(.hour) // defaults to .iaTimeStamp and to .number
     print(nextHour!) // prints ia time stamp with one more hour
     ```
     */
    func getNext(component: Calendar.Component, type: IADateTypes = .iaTimeStamp, format: CalendarFormat = .number) -> String? {
        // formatters
        let dateFormatter = DateFormatter() // date formatter
        dateFormatter.timeZone = TimeZone.init(secondsFromGMT: .zero)
        let numberFormatter = NumberFormatter() // number formatter
        if format == .number { numberFormatter.numberStyle = .none }
        else if format == .text { numberFormatter.numberStyle = .spellOut }
        // dates
        let date = getIATimeStampAsDate()
        let newDate = Calendar.current.date(byAdding: component, value: 1, to: date)

        switch type {
        // ia time stamp
        case .iaTimeStamp:
            return numberFormatter.string(for: toIAFrom(date: newDate!))
        // date
        case .date:
            let format = DateFormat.getDateFormat(component: component, format: format)
            dateFormatter.dateFormat = format!.format
            let extractedDate = dateFormatter.string(from: newDate!)
            // return extractedDate or spelled out version of extractedDate
            if format!.identical == false {
                return extractedDate
            } else {
                return numberFormatter.string(from: NSNumber(value: Int(extractedDate)!))
            }
        // unix time stamp
        case .unixTimeStamp:
            return numberFormatter.string(for: toUNIXFrom(date: newDate!))
        }
    }

    // MARK: - Setters
    func set(to ia: Int) { // set ia time stamp to `iaTime`
        self.iaTimeStamp = ia
    }

    // MARK: - Incrementers
    // add minutes, days, months or years to IA time
    func add(fiveMinutes: Int) { // add `fiveMinutes` to IA time
        self.iaTimeStamp! += fiveMinutes
    }
    func add(hours: Int) { // add `hours` to IA time
        add(hours, .hour)
    }
    func add(days: Int) { // add `days` to IA time
        add(days, .day)
    }
    func add(weeks: Int) { // add `weeks` to IA time
        add(weeks, .weekOfYear)
    }
    func add(months: Int) { // add `months` to IA time
        add(months, .month)
    }
    func add(years: Int) { // add `years` to IA time
        add(years, .year)
    }
    // add `number` to `component`
    func add(_ number: Int, _ component: Calendar.Component) {
        let next = getNext(component: component, type: .iaTimeStamp, format: .number)!
        let single = Int(next)! - self.iaTimeStamp!
        // one `number` times `component`'s base unit
        for _ in .zero..<number {
            self.iaTimeStamp! += single
        }
    }

    // MARK: - Conversions
    func toDateFrom(ia iaTimeStamp: Int) -> Date { // return ia time stamp as date
        let timeReferenceAsDate = Date(timeIntervalSince1970: Date.timeIntervalBetween1970AndReferenceDate)
        let timeStampAsDate = TimeInterval(iaTimeStamp * iaTime.everyFiveMinutes * Minute.numberOfSeconds)
        return timeReferenceAsDate + timeStampAsDate
    }
    func toDateFrom(unix unixTimeStamp: Int) -> Date {
        return toDateFrom(ia: toIAFrom(unix: unixTimeStamp))
    }
    // return time in 5 minutes in between 01-01-2001 and `_date`
    func toIAFrom(date: Date) -> Int {
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = iaTime.dateFormat
        // get date from 01-01-2001
        let originDate = dateFormatter.date(from: getIAOriginDate())
        return Int(date.timeIntervalSince(originDate!)) / FiveMinute.numberOfSeconds
    }
    func toIAFrom(unix: Int) -> Int { // convert UNIX time to ia time
        // from unix to ia in seconds
        let iaInSeconds = unix - Int(Date.timeIntervalBetween1970AndReferenceDate)
        // from ia in seconds to ia time stamp
        return iaInSeconds / FiveMinute.numberOfSeconds
    }
    func toUNIXFrom(ia: Int) -> Int { // convert ia time to UNIX time
        // convert ia to seconds
        let iaInSeconds = ia * FiveMinute.numberOfSeconds
        // add time between 01-01-1970 and 01-01-2001 to ia in seconds
        return Int(Date.timeIntervalBetween1970AndReferenceDate) + iaInSeconds
    }
    func toUNIXFrom(date: Date) -> Int {
        return toUNIXFrom(ia: toIAFrom(date: date))
    }
    func toUnixFromIA() -> Int {
        return toUNIXFrom(ia: getIATimeStamp())
    }
    func relativeDate(from date: Date,
                      to relativeTo: Date? = nil,
                      format: CalendarFormat = .number) -> String? {
        let formatter = RelativeDateTimeFormatter()
        let relativeDate = formatter.localizedString(for: date,
                                                     relativeTo: relativeTo ?? getIATimeStampAsDate())
        switch format {
        case .number:
            guard let customRelativeDate = CustomRelativeDate.getRelativeDateTextIndicator(text: relativeDate) else {
                return nil
            }
            return customRelativeDate
        case .text:
            return relativeDate
        }
    }
    func relativeIATime(from iaTimeStamp: Int,
                        to relativeTo: Date? = nil,
                        format: CalendarFormat = .number) -> String? {
        return relativeDate(from: toDateFrom(ia: iaTimeStamp), to: relativeTo, format: format)
    }
    func relativeUNIXTime(from unixTimeStamp: Int,
                        to relativeTo: Date? = nil,
                        format: CalendarFormat = .number) -> String? {
        return relativeDate(from: toDateFrom(unix: unixTimeStamp), to: relativeTo, format: format)
    }
    func convertBetweenTimeZones(zone1: TimeZone, zone2: TimeZone) { }

    // MARK: - Comparators
    func isSameDayAs(ia: Int) -> Bool {
        return isSameDayAs(date: toDateFrom(ia: ia))
    }
    func isSameDayAs(date: Date) -> Bool {
        let formatter = DateFormatter()
        formatter.dateFormat = "yyyy-MM-dd"

        let referenceDate = formatter.string(from: getIATimeStampAsDate())
        let comparedDate = formatter.string(from: date)

        if referenceDate == comparedDate {
            return true
        } else {
            return false
        }
    }
    func timeUntil(date: Date, format: CalendarFormat = .number) -> String? {
        return timeBetween(getIATimeStampAsDate(), and: date, format: format)
    }
    func timeUntil(ia: Int, format: CalendarFormat = .number) -> String? {
        return timeBetween(getIATimeStampAsDate(), and: toDateFrom(ia: ia), format: format)
    }
    func timeBetween(_ date1: Date, and date2: Date, format: CalendarFormat = .number) -> String? {
        if date2 >= date1 {
            return relativeDate(from: date2, to: date1, format: format)
        } else {
            return relativeDate(from: date1, to: date2, format: format)
        }
    }
    func timeBetween(_ ia1: Int, and ia2: Int) -> String? {
        return timeBetween(toDateFrom(ia: ia1), and: toDateFrom(ia: ia2))
    }

    // MARK: - Live
    // Notification center to broadcast every five minutes new iaTimeStamp update
    func startLiveIATimeStamp() -> Int {
        // start background timer
        Timer.scheduledTimer(withTimeInterval: 300, repeats: true) { [weak self] _ in // every five minutes
            self?.postUpdate(name: Notifications.iaDateIANotification,
                             userInfo: [Notifications.iaTimeStamp: self!.getIATimeStamp()])
        }
        return getIATimeStamp()
    }
    // Notification center to broadcast every seconds new unixTimeStamp update
    func startLiveUNIXTimeStamp() -> Int {
        // start background timer
        Timer.scheduledTimer(withTimeInterval: 1, repeats: true) { [weak self] _ in // every seconds
            self?.postUpdate(name: Notifications.iaDateUNIXNotification,
                             userInfo: [Notifications.unixTimeStamp: self!.toUnixFromIA()])
        }
        return toUnixFromIA()
    }
    private func postUpdate(name: Notification.Name, userInfo: [AnyHashable : Any]?) {
        NotificationCenter.default.post(name: name, object: iaDate.self, userInfo: userInfo)
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
        static let numberOfDays: Double = 365.25 // number of days in a year
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
        static let numberOfDays: Double = 30.4375 // in average there are 365.25/12 days in a month
        // 8640 fiveMinutes in a month
        static let numberOfFiveMinutes: Int = Int(Month.numberOfDays * Double(Day.numberOfFiveMinutes))
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
    // MARK: Five Minutes
    private struct FiveMinute {
        static let numberOfSeconds: Int = Hour.numberOfMinutes * iaTime.everyFiveMinutes
    }
    // MARK: Minutes
    private struct Minute {
        static let numberOfSeconds: Int = Hour.numberOfMinutes // number of minutes in a single minute
    }
    // MARK: Localization
    struct Localization {
        static let english: String = "en_US" // default localization is US english
    }
    struct Notifications {
        static let iaDateIANotification = Notification.Name("iaDateIANotification")
        static let iaDateUNIXNotification = Notification.Name("iaDateUNIXNotification")
        static let iaTimeStamp: String = "iaTimeStamp"
        static let unixTimeStamp: String = "unixTimeStamp"
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
extension Int {
    static func parse(from string: String) -> Int? {
        return Int(string.components(separatedBy: CharacterSet.decimalDigits.inverted).joined())
    }
}
extension String {
    static func parse(from string: String) -> String? {
        return string.components(separatedBy: CharacterSet.lowercaseLetters.inverted).joined()
    }
}

/*
 Todo:
 1. Calcule le nombre de jour restant avant une date puis indique une heure en se rapprochant de ce jour
 2. Calcule le nombre de jour entre deux dates
 3. Calcule le nombre d’heures/minutes entre deux dates
 4. Calculer si une date est au jour prochain, à la semaine prochaine, au mois prochain ou à l'année prochaine par rapport à la date actuelle
 */
