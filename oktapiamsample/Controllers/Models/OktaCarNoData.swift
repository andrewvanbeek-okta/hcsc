//
//  OktaCarNoData.swift
//  oktapiamsample
//
//  Created by Joe Burgett on 1/19/18.
//  Copyright © 2018 Joe Burgett. All rights reserved.
//

// Define Custom Okta No Data Placeholder for Inventory Collection View

import HGPlaceholders

extension PlaceholdersProvider {
    static var oktaNoData: PlaceholdersProvider {
        var commonStyle = PlaceholderStyle()
        commonStyle.backgroundColor = .clear
        commonStyle.actionBackgroundColor = .black
        commonStyle.actionTitleColor = .white
        commonStyle.titleColor = .white
        commonStyle.subtitleColor = .white
        commonStyle.isAnimated = true
        
        commonStyle.titleFont = UIFont(name: "AvenirNextCondensed-HeavyItalic", size: 19)!
        commonStyle.subtitleFont = UIFont(name: "AvenirNextCondensed-Italic", size: 19)!
        commonStyle.actionTitleFont = UIFont(name: "Avenir-Light", size: 14)!
        
        var loadingStyle = commonStyle
        loadingStyle.actionBackgroundColor = .white
        loadingStyle.actionTitleColor = UIColor(red: 7/255, green: 22/255, blue: 43/255, alpha: 1.0)
        
        let loadingData: PlaceholderData = .oktaNoCar
        let loading = Placeholder(data: loadingData, style: loadingStyle, key: .loadingKey)
        
        let errorData: PlaceholderData = .oktaNoCar
        let error = Placeholder(data: errorData, style: commonStyle, key: .errorKey)
        
        let noResultsData: PlaceholderData = .oktaNoCar
        let noResults = Placeholder(data: noResultsData, style: commonStyle, key: .noResultsKey)
        
        let noConnectionData: PlaceholderData = .oktaNoCar
        let noConnection = Placeholder(data: noConnectionData, style: commonStyle, key: .noConnectionKey)
        
        let placeholdersProvider = PlaceholdersProvider(loading: loading, error: error, noResults: noResults, noConnection: noConnection)
        
        return placeholdersProvider
    }
}
