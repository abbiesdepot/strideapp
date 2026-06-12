import Foundation

struct InviteCodeValidator {
    static func isValid(_ code: String) -> Bool {
        return code.count == 6 && code.allSatisfy { "ABCDEFGHIJKLMNOPQRSTUVWXYZ0123456789".contains($0) }
    }
}
