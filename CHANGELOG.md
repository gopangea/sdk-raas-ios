# Changelog

All notable changes to this project will be documented in this file.

The format is based on [Keep a Changelog](https://keepachangelog.com/en/1.0.0/),
and this project adheres to [Semantic Versioning](https://semver.org/spec/v2.0.0.html).

## [Unreleased]
- No changes comming

## [1.0.4] - 2021-02-25
### Added
- A new method that will return a base64 encoded string which the RaaS partner will store in their database instead of the clientSessionId
```
getClientData()
```
### Changed
- The QueryResull has chaged to a generic type, in this way can it be use to wrap any type of reponse from the pagea sdk that could be added in the future, the refactored method is this one:

```
typealias QueryResult<T> = (T?, String?) -> Void
```
You can use it as the same as the previous one:
```
Pangea.sharedInstance.createToken(cardInfo: card, completion: {tokenResponse,error in
     guard let token = tokenResponse else { //invalid token }
})
        
Pangea.sharedInstance.getClientData(completion: {clientInfo,error in
     guard let clientData = clientInfo else { //invalid clientInfo }
})
```

## [1.0.3] - 2020-12-08
### Added
- A custom header x-pangea-user-agent that describes the version number, build number and OS 
### Changed
- The debug mode now shows the body, url and headers from the Http request

## [0.0.9] - 2020-09-29
### Changed
- Initial version of the SDK
