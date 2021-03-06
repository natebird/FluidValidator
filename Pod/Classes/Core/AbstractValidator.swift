//
//  AbstractValidator.swift
//  TestValidator
//
//  Created by FrogRain on 31/01/16.
//  Copyright © 2016 FrogRain. All rights reserved.
//

import Foundation

open class AbstractValidator<T:AnyObject> : ValidationBase {
    fileprivate var validations:Array<Validation<T>> = Array<Validation<T>>()
    
    public override init() {
        super.init()
    }
    
    open func validate(object target: AnyObject?) -> Bool {
        var result = true
        for validation in self.validations {
            guard let target = target as? T else {
                continue
            }
            let validationResult = self.validate(property: validation.validationName, context: target)
            result = result && validationResult
        }
        return result
    }
    
    func validate(property name:String, context: T) -> Bool {
        let validations = self.validations.filter({(validation) -> Bool in
            validation.validationName == name
        })
        var validationResult = true
        for validation in validations {
            let result = validation.runValidation(context)
            validationResult = validationResult && result
        }
        return validationResult
    }
    
    @discardableResult open func addValidation(withName name:String, targetGetter:@escaping (_ context:T)->(Any?)) -> Validation<T> {
        let validation = Validation(name: name, targetGetter: targetGetter)
        self.validations.append(validation)
        return validation
    }
    
    open func addValidation(forProperty property: Selector) -> Void {
        let name = String(describing: property)
        addValidation(withName: name) { (context) -> (AnyObject?) in
            
            guard let nsContext = context as? NSObject else {
                return nil
            }
            return nsContext.perform(property) as AnyObject
        }
    }
    
    open var allErrors: FailMessage {
        let error = FailMessage()
        let validationNames = self.validations.map({(validation) -> String in
            validation.validationName
        })
        for name in validationNames {
            let failMessage = self.errorsForValidation(name)
            if(failMessage.errors.count == 0 && failMessage.failingFields().count == 0) {
                continue
            }
            error.setObject(failMessage, forKey: name)
        }
        return error
    }
    
    
    func errorsForValidation(_ name:String) -> FailMessage {
        let validations = self.validations.filter { (validation) -> Bool in
            validation.validationName == name
        }
        
        let failMessage = validations.first?.allErrors ?? FailMessage()
        for validation in validations {
            let validationFail = validation.allErrors
            let joinedArrays = failMessage.errors + validationFail.errors
            failMessage.errors = Array(Set<ErrorMessage>(joinedArrays))
        }
        return failMessage
    }
    
    // override ValidationBase (which implements Validatable)
    override open func performValidation(onObject object:AnyObject?) -> Bool {
        if let object = object as? T {
            return self.validate(object: object)
        }
        return false
    }
    
    override open func hydrateError(withFailMessage message: FailMessage, localizedSubject: String, failValue: AnyObject?, context: AnyObject) {
        let error = ErrorMessage()
        error.compact = self.errorMessage(localizedSubject, failValue: failValue, context: context)
        error.extended = self.errorMessageExtended(localizedSubject, failValue: failValue, context: context)
        message.errors.append(error)
        
        for validation in self.validations {
            message.setObject(validation.allErrors, forKey: validation.validationName)
        }
    }
    
    override func errorTextLocalized() -> String {
        var message = super.errorTextLocalized()
        let className = String(describing: type(of: self).self)
        var key = String(format: "%@.error.message", className)
        if(message == key) {
            key = "AbstractValidator.error.message"
            message = LocalizationHelper.localizeThis(key)
        }
        return message
    }
    
    override func errorTextExtendedLocalized() -> String {
        var message = super.errorTextExtendedLocalized()
        let className = String(describing: type(of: self).self)
        var key = String(format: "%@.error.message.extended", className)
        if(message == key) {
            key = "AbstractValidator.error.message.extended"
            message = LocalizationHelper.localizeThis(key)
        }
        return message
    }
}
