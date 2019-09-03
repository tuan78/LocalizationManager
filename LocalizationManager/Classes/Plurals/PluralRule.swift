import Foundation

/**
 Enum describing all (supported) plural rules.
 */
enum PluralRule: String {
    /** The rule for specific number handling of "0" in case this locale has special adaptations for "0". */
    case zero
    /** The rule for specific number handling of "1" in case this locale has special adaptations for "1". */
    case one
    /** The rule for specific number handling of "2" in case this locale has special adaptations for "2". */
    case two
    /** The rule for specific number handling of small numbers in case this locale has special adaptations for them. */
    case few
    /** The rule for specific number handling of large numbers in case this locale has special adaptations for them. */
    case many
    /**
     The rule for all other numbers.

     - Note: This rule is required for all languages / locales.
    */
    case other
}

/**
 The type of a function which is providing the correct plural rule for the given integer value.
 It usually refers to `PluralRuleClassifierFactory.pluralRule(for:)`.

 ## Rationale

 Proper plural handling (especially for languages with complex systems of numerals and related qualifiers e.g. polish)
 is a pretty challenging task. Luckily Apple's `Foundation` framework has built in support for that. Unfortunately, this
 logic is built in `NSLocalizedString` using 'Localizable.stringsdict' instead of the regular `.strings` files.
 As explained in `LocalizationService` we cannot use `NSLocalizedString` for our business case. Nevertheless, we found
 a way to use Foundation's plural logic without using `NSLocalizedString` for app's localization. This logic is
 encapsulated inside this plural rule classifier.
 */
typealias PluralRuleClassifier = (Int) -> PluralRule

/** The factory creating a `PluralRuleClassifier` for the given `Locale`. */
class PluralRuleClassifierFactory {

    /**
     The type of a (factory) method which creates a `String` object for the given arguments.
     Usually a reference to `String(format:locale:arguments)` and mainly exposed for (unit) testing purposes.

     ## Rationale

     While investigating Foundation's plural handling we realized that `String(format:locale:arguments)` differentiates
     between the locale of `NSLocalizedString` (which is needed to built the correct `format` string) and the locale
     which is passed into the initializer as `locale`. We use this possibility to provide the name of the plural rule
     which Foundation is applying for the given locale.

     Check [Plurals.md](Plurals.md) for further information.
     */
    typealias StringFactory = (_ format: String, _ locale: Locale, _ arguments: [CVarArg]) -> String

    /** The (private) type of a method providing the 'rawValue' of `PluralRule` for a given integer value. */
    private typealias RawPluralRuleClassifier = (Float) -> String

    /**
     The `RawPluralRuleClassifier` used to get the _raw_ plural rule for the given integer value.

     ## Implementation Details

     This function is encapsulating most of the logic we use to properly classify the plural rule for the given integer
     values. It's providing the (localized) String of `plural_quantifier` retrieved from `Localizable.stringsdict` which
     is transformed to `PluralRule` in `rule(for:)`.
     */
    private let rawClassifier: RawPluralRuleClassifier

    /**
     Designated initializer.

     - Parameters:
        - locale:           The locale for which this classifier is providing the correct plural rules.
        - stringFactory:    The type of a (factory) method which creates a `String` object for the given arguments.
                            Exposed for (unit) testing purposes.
     */
    init(locale: Locale, stringFactory: @escaping StringFactory = String.init) {
        let classBundle = Bundle(for: PluralRuleClassifierFactory.self)
        let format = classBundle.localizedString(forKey: "plural_quantifier", value: nil, table: nil)
        self.rawClassifier = { value in
            return stringFactory(format, locale, [value])
        }
    }

    /**
     The actual `PluralRuleClassifier`.

     - Parameters:
        - value: The integer value for which the correct `PluralRule` should be figured out and returned.

     - Returns: The `PluralRule` which should be applied for the given integer value.
     */
    func rule(for value: Float) -> PluralRule {
        guard let rule = PluralRule(rawValue: rawClassifier(value)) else {
            return .other
        }
        return rule
    }

}
