# oktacarrental_ios
Okta API AM Example App (Swift)

[![CI Status](http://img.shields.io/travis/okta/okta-sdk-appauth-ios.svg?style=flat)](https://travis-ci.org/okta/okta-sdk-appauth-ios)
[![Version](https://img.shields.io/cocoapods/v/OktaAuth.svg?style=flat)](http://cocoapods.org/pods/OktaAuth)
[![License](https://img.shields.io/cocoapods/l/OktaAuth.svg?style=flat)](http://cocoapods.org/pods/OktaAuth)
[![Platform](https://img.shields.io/cocoapods/p/OktaAuth.svg?style=flat)](http://cocoapods.org/pods/OktaAuth)

## Overview
This project is meant to demonstrate the value and functionality Okta API AM.  It is a iOS (Swift) app enabled by
the [okta-sdk-appauth-ios](https://github.com/okta/okta-sdk-appauth-ios). 

This project currently supports:
  - [OAuth 2.0 Authorization Code Flow](https://tools.ietf.org/html/rfc6749#section-4.1) using the [PKCE extension](https://tools.ietf.org/html/rfc7636)
  
The following iOS native app offers an example of how Okta API AM can provide authentication and authorize through support of OAuth 2.0 and ODIC flows.  To illustrate this support the app was developed to support live API calls to a resource server protected by an OAuth 2.0 capable gateway.

### Initial Diagram
