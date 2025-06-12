import Foundation


@available(macOS 13.0, *)
struct ConfirmationResultBox<R> {
    var value: R?
    var confirmed: Bool = false
    
    func getValue() throws -> R {
        guard let value else {
            throw RunnerError.noResult
        }
        
        if confirmed {
            return value
        }
        
        throw RunnerError.noResultNoConfirmation
    }
    
    func updatedValue(_ newValue: R) -> Self {
        var copy = self
        copy.value = newValue
        return copy
    }
    
    func updatedConfirmed() -> Self {
        var copy = self
        copy.confirmed = true
        return copy
    }
}

enum ConfirmationResult<R> {
    case none
    case value(R)
    case confirmedValue(R)
    case confirmed
    
    func merge(_ other: Self) -> Self {
        switch (self, other) {
        case (.value(let val), .none):
                self
        case (.none, .value(let val)):
                other
        case (.value(let val), .confirmed):
                .confirmedValue(val)
        case (.confirmed, .value(let val)):
                .confirmedValue(val)
        
        default: self
            
        }
    }

}
