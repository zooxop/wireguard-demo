//
//  PublicIPAPI.swift
//  SwiftPublicIP
//
//  Created by HackingGate on 2019/05/13.
//  Copyright © 2019 SwiftPublicIP. All rights reserved.
//
//  Original source code from : https://github.com/HackingGate/Swift-Public-IP

import Foundation

#if canImport(FoundationNetworking)
import FoundationNetworking
#endif

typealias CompletionHandler = (String?, Error?) -> Void

/// Get public IP address from specified API. Including icanhazip, ipv6-test...
///
/// - parameter url:            The API URL. Use `PublicIPAPIURLs` class. `ipv4` for IPv4 only,
/// `ipv6` for IPv6 only, `hybrid` for both IPv4 or IPv6. You can use custom API URL but make sure
/// it returns vilidate IP address.
/// - parameter completion:     The result. IP address in a String.
///
public func getPublicIP(url: String, completion: @escaping (String?, Error?) -> Void) {

    guard let url: URL = URL(string: url) else {
        fatalError("URL is not validate")
    }
    
    getPublicIPAddress(requestURL: url) { (result, error) in
        completion(result, error)
    }
}

func getPublicIPAddress(requestURL: URL, completion: @escaping CompletionHandler) {
    URLSession.shared.dataTask(with: requestURL) { (data, response, error) in
        if let error = error {
            completion(nil, CustomError.error(error))
            return
        }
        guard let data = data else {
            completion(nil, CustomError.noData)
            return
        }
        guard let result = String(data: data, encoding: .utf8) else {
            completion(nil, CustomError.undecodeable)
            return
        }
        let ipAddress = String(result.filter { !" \n\t\r".contains($0) })
        completion(ipAddress, nil)
    }.resume()
}

enum CustomError: LocalizedError {
    case noData
    case error(Error)
    case undecodeable

    public var errorDescription: String? {
        switch self {
        case .noData:
            return "No data response."
        case .error(let err):
            return err.localizedDescription
        case .undecodeable:
            return "Data undecodeable."
        }
    }
}
