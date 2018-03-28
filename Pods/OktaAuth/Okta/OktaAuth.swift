/*
 * Copyright (c) 2017, Okta, Inc. and/or its affiliates. All rights reserved.
 * The Okta software accompanied by this notice is provided pursuant to the Apache License, Version 2.0 (the "License.")
 *
 * You may obtain a copy of the License at http://www.apache.org/licenses/LICENSE-2.0.
 * Unless required by applicable law or agreed to in writing, software
 * distributed under the License is distributed on an "AS IS" BASIS, WITHOUT
 * WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
 *
 * See the License for the specific language governing permissions and limitations under the License.
 */

import AppAuth
import SwiftyPlistManager

public struct OktaAuthorization {

    func authCodeFlow(_ config: [String: Any], view: UIViewController,
                      callback: @escaping (OktaTokenManager?, OktaError?) -> Void) {
        
        // Set locals for Okta Orgs
        
        guard let fetchedScopes = SwiftyPlistManager.shared.fetchValue(for: "scopes", fromPlistWithName: "Okta") else { return }
        guard let fetchedClientId = SwiftyPlistManager.shared.fetchValue(for: "clientId", fromPlistWithName: "Okta")else { return }
        guard let fetchedIssuer = SwiftyPlistManager.shared.fetchValue(for: "issuer", fromPlistWithName: "Okta") else { return }
        guard let fetchedRedirect = SwiftyPlistManager.shared.fetchValue(for: "redirectUri", fromPlistWithName: "Okta") else { return }
        
//        print("\n********** Okta Connection Information **********")
//        print(fetchedScopes)
//        print(fetchedClientId)
//        print(fetchedIssuer)
//        print(fetchedRedirect)
        
        // Discover Endpoints
        
        // ******************
        // getMetadataConfig(URL(string: config["issuer"] as! String)) { oidConfig, error in
        // ******************
        
        getMetadataConfig(URL(string: fetchedIssuer as! String)) { oidConfig, error in

            if error != nil {
                callback(nil, error!)
                return
            }

            // Build the Authentication request
            let request = OIDAuthorizationRequest(
                
                configuration: oidConfig!,
                
                // ******************
                //clientId: config["clientId"] as! String,
                // ******************
                
                clientId: fetchedClientId as! String,
                
                // ******************
                // scopes: try? Utils().scrubScopes(config["scopes"]),
                // ******************
                
                scopes: try? Utils().scrubScopes(fetchedScopes as! NSArray),
                
                // ******************
                //redirectURL: URL(string: config["redirectUri"] as! String)!,
                // ******************
                
                redirectURL: URL(string: fetchedRedirect as! String)!,
                
                responseType: OIDResponseTypeCode,
                additionalParameters: nil
            )
            
            // Start the authorization flow
            OktaAuth.currentAuthorizationFlow = OIDAuthState.authState(byPresenting: request, presenting: view){
                authorizationResponse, error in
                
                if authorizationResponse != nil {
                    // Return the tokens
                    callback(OktaTokenManager(authState: authorizationResponse), nil)
                } else {
                    callback(nil, .apiError(error: "Authorization Error: \(error!.localizedDescription)"))
                }
            }
        }
    }
    
    func passwordFlow(_ config: [String: Any], credentials: [String: String]?, view: UIViewController,
                      callback: @escaping (OktaTokenManager?, OktaError?) -> Void) {
        
        // Discover Endpoints
        getMetadataConfig(URL(string: config["issuer"] as! String)) {
            oidConfig, error in
            
            if error != nil {
                callback(nil, error!)
                return
            }

            // Build the Authentication request
            let request = OIDTokenRequest(
                           configuration: oidConfig!,
                               grantType: OIDGrantTypePassword,
                       authorizationCode: nil,
                             redirectURL: URL(string: config["redirectUri"] as! String)!,
                                clientID: config["clientId"] as! String,
                            clientSecret: (config["clientSecret"] as! String),
                                   scope: try? Utils().scrubScopes(config["scopes"]).joined(separator: " "),
                            refreshToken: nil,
                            codeVerifier: nil,
                    additionalParameters: credentials
                )
            
            // Start the authorization flow
            OIDAuthorizationService.perform(request) {
                authorizationResponse, responseError in
                
                if authorizationResponse != nil {
                    // Return the tokens
                    let authState = OIDAuthState(
                            authorizationResponse: nil,
                                    tokenResponse: authorizationResponse,
                             registrationResponse: nil
                        )
                    callback(OktaTokenManager(authState: authState), nil)
                } else {
                    callback(nil, .apiError(error: "Authorization Error: \(error!.localizedDescription)"))
                }
            }
            
        }
    }
    
    func getMetadataConfig(_ issuer: URL?, callback: @escaping (OIDServiceConfiguration?, OktaError?) -> Void) {
        // Get the metadata from the discovery endpoint
        
        OIDAuthorizationService.discoverConfiguration(forIssuer: issuer!) {
            oidConfig, error in
            
            var configError: OktaError?

            if oidConfig == nil {
                let responseError =
                    "Error returning discovery document:" +
                    "\(error!.localizedDescription) Please" +
                    //"check your PList configuration"
                    "check your configuration"
                
                configError = .apiError(error: responseError)
            }
            callback(oidConfig, configError)
        }
    }
}
